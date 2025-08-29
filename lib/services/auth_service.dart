import 'package:coursebuddy/utils/error_util.dart';
import 'package:coursebuddy/utils/user_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(
    BuildContext context, {
    bool mounted = true,
  }) async {
    try {
      // ✅ Force account selection
      await _auth.signOut();
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      final uid = user?.uid;
      final email = user?.email;

      if (email == null || uid == null) {
        if (!context.mounted || !mounted) return;
        showError(context, "Google account did not return a valid email/uid.");
        return;
      }

      final firestore = FirebaseFirestore.instance;
      String role = 'guest'; // Default role

      // ✅ Check known role collections
      if ((await firestore.collection('students').doc(email).get()).exists) {
        role = 'student';
      } else if ((await firestore.collection('parents').doc(email).get())
          .exists) {
        role = 'parent';
      } else if ((await firestore.collection('teachers').doc(email).get())
          .exists) {
        role = 'teacher';
      } else if ((await firestore.collection('admins').doc(email).get())
          .exists) {
        role = 'admin';
      }

      // ✅ Save/update user doc
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': user?.displayName ?? '',
        'fcmToken': fcmToken,
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ✅ Route user
      final target = await getDashboardForUser(email);
      if (!context.mounted || !mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => target));
    } catch (e, stack) {
      if (!context.mounted || !mounted) return;
      showError(context, e, stack);
    }
  }
}
