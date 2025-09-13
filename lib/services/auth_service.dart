/// AuthService.dart
///
/// Handles Google Sign-In using Firebase Auth (v7.x).
/// - Web: uses `signInWithPopup`
/// - Mobile: uses `signInWithProvider`
///
/// Also:
/// - Saves FCM token
/// - Stores login timestamp & device metadata
/// - Leaves routing to AuthGate + UserRouter (no duplicate logic)

import 'package:coursebuddy/widgets/error_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Maximum number of retries for sign-in
  static const int _maxRetries = 2;
  // Timeout duration for sign-in attempts
  static const Duration _timeoutDuration = Duration(seconds: 15);

  Future<void> signInWithGoogle(BuildContext context) async {
    int attempt = 0;

    while (attempt <= _maxRetries) {
      try {
        UserCredential userCredential;

        if (kIsWeb) {
          debugPrint('Google Sign-In on Web...');
          userCredential = await _auth
              .signInWithPopup(GoogleAuthProvider())
              .timeout(_timeoutDuration);
        } else {
          debugPrint('Google Sign-In on Mobile...');
          final googleProvider = GoogleAuthProvider()
            ..addScope('email')
            ..addScope('profile');

          // ✅ Updated to use try/catch instead of unsupported method
          try {
            userCredential = await _auth
                .signInWithProvider(googleProvider)
                .timeout(_timeoutDuration);
          } catch (e) {
            if (!context.mounted) return;
            showError(context, 'Google sign-in failed: $e');
            return;
          }
        }

        final user = userCredential.user;
        final uid = user?.uid;
        final email = user?.email;

        debugPrint('Auth success → UID: $uid, Email: $email');

        if (uid == null || email == null) {
          if (!context.mounted) return;
          showError(
            context,
            "Google account did not return a valid email/uid.",
          );
          return;
        }

        final userDocRef = _firestore.collection('users').doc(uid);
        final existingDoc = await userDocRef.get();

        // Get FCM Token
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        debugPrint('FCM Token: ${fcmToken ?? "null"}');

        // Get Device Info (only for mobile, optional on web)
        final deviceInfo = DeviceInfoPlugin();
        Map<String, dynamic> deviceData = {};
        if (!kIsWeb) {
          final android = await deviceInfo.androidInfo;
          deviceData = {
            'device': android.model,
            'osVersion': android.version.release,
          };
        }

        await userDocRef.set({
          'uid': uid,
          'email': email,
          'name': user?.displayName ?? '',
          'fcmToken': fcmToken ?? '',
          'lastLogin': FieldValue.serverTimestamp(),
          'deviceInfo': deviceData,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('User document updated/created');

        // ✅ DO NOT route here — AuthGate will handle routing
        return; // Success, exit loop
      } catch (e) {
        // stack) {
        attempt++;
        if (attempt > _maxRetries) {
          if (!context.mounted) return;
          debugPrint('Sign-In Error after $attempt attempts: $e');
          showError(context, e); //, stack);
          return;
        }
        debugPrint('Sign-In attempt $attempt failed, retrying... Error: $e');
      }
    }
  }

  /// Signs out the current user and resets navigation
  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  /// Deletes the user's Firebase account and user doc
  Future<void> deleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      await user.delete();

      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      debugPrint('Account deletion error: $e');
      if (!context.mounted) return;
      showError(context, 'Failed to delete account. Please try again later.');
    }
  }
}
