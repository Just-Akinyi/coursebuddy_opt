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
      // ✅ Sign out first to force account selection
      await _auth.signOut();
      await _googleSignIn.signOut();

      // Start Google Sign-In
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in flow
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase auth
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      final uid = user?.uid;
      final email = user?.email;

      if (email == null || uid == null) {
        if (!context.mounted || !mounted) return;
        showError(context, "Google account did not return a valid email/uid.");
        return;
      }

      // Request notification permission (best-effort; safe on Android/iOS/Web)
      try {
        await FirebaseMessaging.instance.requestPermission();
      } catch (_) {}

      // Determine role before saving FCM token and user info
      final firestore = FirebaseFirestore.instance;
      String role = "guest"; // Default role

      // Check role by querying known collections
      final studentDoc = await firestore
          .collection('students')
          .doc(email)
          .get();
      if (studentDoc.exists) {
        role = 'student';
      } else if (await firestore
          .collection('parents')
          .doc(email)
          .get()
          .then((doc) => doc.exists)) {
        role = 'parent';
      } else if (await firestore
          .collection('teachers')
          .doc(email)
          .get()
          .then((doc) => doc.exists)) {
        role = 'teacher';
      } else if (await firestore
          .collection('admins')
          .doc(email)
          .get()
          .then((doc) => doc.exists)) {
        role = 'admin';
      }

      // Save/update FCM token
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'email': email,
            'fcmToken': fcmToken,
            'updatedAt': FieldValue.serverTimestamp(),
            'role': role,
          }, SetOptions(merge: true));
        }
      } catch (_) {
        // Non-fatal if token save fails
      }

      // Compute target dashboard (no context used inside)
      final target = await getDashboardForUser(email);

      // ✅ Guard context right before using it
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
