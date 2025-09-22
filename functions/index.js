// functions/index.js
// Callable function: createUser
// - Only callable by authenticated users whose Firestore profile has roles containing 'admin'.
// - If an Auth user already exists with that email, returns existing uid and merges the requestedRole into:
//    1) the user's custom claims (so tokens include roles), and
//    2) the users/{uid} Firestore doc (roles array).
// - If not found, creates Auth user, sets custom claims (merging with any existing), and creates users/{uid}.
// - Returns { uid, created: boolean, mergedRoles: [...] }

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.createUser = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'You must be authenticated to call this function.');
  }

  const callerUid = context.auth.uid;
  const callerDoc = await admin.firestore().collection('users').doc(callerUid).get();
  if (!callerDoc.exists) {
    throw new functions.https.HttpsError('permission-denied', 'Caller does not have a profile.');
  }
  const callerData = callerDoc.data() || {};
  const callerRoles = Array.isArray(callerData.roles) ? callerData.roles : [];
  if (!callerRoles.includes('admin')) {
    throw new functions.https.HttpsError('permission-denied', 'Only admins can create or modify users.');
  }

  const email = (data.email || '').toString().trim().toLowerCase();
  const password = (data.password || '').toString();
  const requestedRole = (data.requestedRole || 'student').toString();

  if (!email || !password) {
    throw new functions.https.HttpsError('invalid-argument', 'Email and password are required.');
  }

  try {
    let userRecord;
    let created = false;

    try {
      userRecord = await admin.auth().getUserByEmail(email);
    } catch {
      userRecord = await admin.auth().createUser({
        email,
        password,
        displayName: email.split('@')[0],
      });
      created = true;
    }

    const uid = userRecord.uid;

    // Merge roles into Firestore users/{uid}
    const userRef = admin.firestore().collection('users').doc(uid);
    await userRef.set({
      email,
      username: uid,
      roles: admin.firestore.FieldValue.arrayUnion(requestedRole),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // Merge into custom claims
    const existingClaims = userRecord.customClaims || {};
    const existingRolesMap = existingClaims.roles && typeof existingClaims.roles === 'object'
      ? existingClaims.roles
      : {};

    existingRolesMap[requestedRole] = true;

    const latestUserDoc = await userRef.get();
    const fsRoles = (latestUserDoc.exists && latestUserDoc.data().roles) ? latestUserDoc.data().roles : [];
    if (Array.isArray(fsRoles)) {
      fsRoles.forEach(r => { existingRolesMap[r] = true; });
    }

    await admin.auth().setCustomUserClaims(uid, { ...existingClaims, roles: existingRolesMap });

    // 🔁 Short delay to allow propagation before client reads new token
    await new Promise(res => setTimeout(res, 2000));

    const mergedRoles = Object.keys(existingRolesMap);
    return { uid, created, mergedRoles };
  } catch (error) {
    console.error('createUser error:', error);
    throw new functions.https.HttpsError('unknown', error.message || 'Error creating user');
  }
});
