// import 'package:coursebuddy/widgets/error_dialog.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'role_manager.dart'; // NEW

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   static const int _maxRetries = 2;
//   static const Duration _timeoutDuration = Duration(seconds: 15);

//   Future<void> signInWithGoogle(BuildContext context) async {
//     int attempt = 0;

//     while (attempt <= _maxRetries) {
//       try {
//         UserCredential userCredential;

//         if (kIsWeb) {
//           debugPrint('Google Sign-In on Web...');
//           userCredential = await _auth
//               .signInWithPopup(GoogleAuthProvider())
//               .timeout(_timeoutDuration);
//         } else {
//           debugPrint('Google Sign-In on Mobile...');
//           final googleProvider = GoogleAuthProvider()
//             ..addScope('email')
//             ..addScope('profile');

//           userCredential = await _auth
//               .signInWithProvider(googleProvider)
//               .timeout(_timeoutDuration);
//         }

//         final user = userCredential.user;
//         final uid = user?.uid;
//         final email = user?.email;

//         if (uid == null || email == null) {
//           if (!context.mounted) return;
//           showError(context, "Google account did not return a valid email/uid.");
//           return;
//         }

//         final userDocRef = _firestore.collection('users').doc(uid);
//         final existingDoc = await userDocRef.get();
//         if (!existingDoc.exists) {
//           debugPrint('🆕 New user detected.');
//         } else {
//           debugPrint('🔁 Returning user.');
//         }

//         String? fcmToken = await FirebaseMessaging.instance.getToken();
//         final deviceInfo = DeviceInfoPlugin();
//         Map<String, dynamic> deviceData = {};

//         if (!kIsWeb) {
//           final android = await deviceInfo.androidInfo;
//           deviceData = {
//             'device': android.model,
//             'osVersion': android.version.release,
//           };
//         }

//         await userDocRef.set({
//           'uid': uid,
//           'email': email,
//           'name': user?.displayName ?? '',
//           'role': 'guest', // ✅ default single role
//           'fcmToken': fcmToken ?? '',
//           'lastLogin': FieldValue.serverTimestamp(),
//           'deviceInfo': deviceData,
//           'updatedAt': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));

//         debugPrint('User document updated/created');
//         return;
//       } catch (e) {
//         attempt++;
//         if (attempt > _maxRetries) {
//           if (!context.mounted) return;
//           debugPrint('Sign-In Error after $attempt attempts: $e');
//           showError(context, 'Google sign-in failed. Please try again later.');
//           return;
//         }
//         debugPrint('Sign-In attempt $attempt failed, retrying... Error: $e');
//         await Future.delayed(Duration(seconds: 2));
//       }
//     }
//   }

//   Future<void> logout(BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       await RoleManager.clearRole();

//       if (!context.mounted) return;
//       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//     } catch (e) {
//       debugPrint('Logout error: $e');
//       if (!context.mounted) return;
//       showError(context, 'Logout failed. Please try again later.');
//     }
//   }

//   Future<void> deleteAccount(BuildContext context) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .delete();
//       await user.delete();
//       await RoleManager.clearRole();

//       if (!context.mounted) return;
//       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//     } catch (e) {
//       debugPrint('Account deletion error: $e');
//       if (!context.mounted) return;
//       showError(context, 'Failed to delete account. Please try again later.');
//     }
//   }
// }

// // // AuthService.dart
// // //
// // // Handles Google Sign-In using Firebase Auth (v7.x).
// // // - Web: uses `signInWithPopup`
// // // - Mobile: uses `signInWithProvider`
// // //
// // // Also:
// // // - Saves FCM token
// // // - Stores login timestamp & device metadata
// // // - Leaves routing to AuthGate + UserRouter (no duplicate logic)
// // // - Clears persisted role on logout.

// // import 'package:coursebuddy/widgets/error_dialog.dart';
// // import 'package:flutter/foundation.dart' show kIsWeb;
// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:device_info_plus/device_info_plus.dart';
// // import 'role_manager.dart'; // NEW

// // class AuthService {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// //   static const int _maxRetries = 2;
// //   static const Duration _timeoutDuration = Duration(seconds: 15);

// //   Future<void> signInWithGoogle(BuildContext context) async {
// //     int attempt = 0;

// //     while (attempt <= _maxRetries) {
// //       try {
// //         UserCredential userCredential;

// //         // Handle Google Sign-In differently for web and mobile platforms
// //         if (kIsWeb) {
// //           debugPrint('Google Sign-In on Web...');
// //           userCredential = await _auth
// //               .signInWithPopup(GoogleAuthProvider())
// //               .timeout(_timeoutDuration);
// //         } else {
// //           debugPrint('Google Sign-In on Mobile...');
// //           final googleProvider = GoogleAuthProvider()
// //             ..addScope('email')
// //             ..addScope('profile');

// //           userCredential = await _auth
// //               .signInWithProvider(googleProvider)
// //               .timeout(_timeoutDuration);
// //         }

// //         final user = userCredential.user;
// //         final uid = user?.uid;
// //         final email = user?.email;

// //         // Ensure we have valid user data
// //         if (uid == null || email == null) {
// //           if (!context.mounted) return;
// //           showError(context, "Google account did not return a valid email/uid.");
// //           return;
// //         }

// //         final userDocRef = _firestore.collection('users').doc(uid);
// //         final existingDoc = await userDocRef.get();
// //         if (!existingDoc.exists) {
// //           debugPrint('🆕 New user detected.');
// //         } else {
// //           debugPrint('🔁 Returning user.');
// //         }

// //         // Optional: Add first-time user fields if needed
// //         String? fcmToken = await FirebaseMessaging.instance.getToken();
// //         final deviceInfo = DeviceInfoPlugin();
// //         Map<String, dynamic> deviceData = {};
        
// //         // Collect device info for non-web platforms
// //         if (!kIsWeb) {
// //           final android = await deviceInfo.androidInfo;
// //           deviceData = {
// //             'device': android.model,
// //             'osVersion': android.version.release,
// //           };
// //         }

// //         // Store user information in Firestore
// //         await userDocRef.set({
// //           'uid': uid,
// //           'email': email,
// //           'name': user?.displayName ?? '',
// //           'fcmToken': fcmToken ?? '',
// //           'lastLogin': FieldValue.serverTimestamp(),
// //           'deviceInfo': deviceData,
// //           'updatedAt': FieldValue.serverTimestamp(),
// //         }, SetOptions(merge: true));

// //         debugPrint('User document updated/created');
// //         return;

// //       } catch (e) {
// //         attempt++;
// //         if (attempt > _maxRetries) {
// //           if (!context.mounted) return;
// //           debugPrint('Sign-In Error after $attempt attempts: $e');
// //           showError(context, 'Google sign-in failed. Please try again later.');
// //           return;
// //         }
// //         debugPrint('Sign-In attempt $attempt failed, retrying... Error: $e');
// //         await Future.delayed(Duration(seconds: 2)); // Optional: slight delay between retries
// //       }
// //     }
// //   }

// //   /// Signs out the current user and clears persisted role
// //   Future<void> logout(BuildContext context) async {
// //     try {
// //       await FirebaseAuth.instance.signOut();
// //       await RoleManager.clearRole(); // NEW

// //       if (!context.mounted) return;
// //       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
// //     } catch (e) {
// //       debugPrint('Logout error: $e');
// //       if (!context.mounted) return;
// //       showError(context, 'Logout failed. Please try again later.');
// //     }
// //   }

// //   /// Deletes the user's Firebase account and user doc
// //   Future<void> deleteAccount(BuildContext context) async {
// //     try {
// //       final user = FirebaseAuth.instance.currentUser;
// //       if (user == null) return;

// //       // Delete user document and Firebase account
// //       await FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(user.uid)
// //           .delete();
// //       await user.delete();
// //       await RoleManager.clearRole(); // NEW

// //       if (!context.mounted) return;
// //       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
// //     } catch (e) {
// //       debugPrint('Account deletion error: $e');
// //       if (!context.mounted) return;
// //       showError(context, 'Failed to delete account. Please try again later.');
// //     }
// //   }
// // }

// // // // AuthService.dart
// // // //
// // // // Handles Google Sign-In using Firebase Auth (v7.x).
// // // // - Web: uses `signInWithPopup`
// // // // - Mobile: uses `signInWithProvider`
// // // //
// // // // Also:
// // // // - Saves FCM token
// // // // - Stores login timestamp & device metadata
// // // // - Leaves routing to AuthGate + UserRouter (no duplicate logic)
// // // // - Clears persisted role on logout.

// // // import 'package:coursebuddy/widgets/error_dialog.dart';
// // // import 'package:flutter/foundation.dart' show kIsWeb;
// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // import 'package:device_info_plus/device_info_plus.dart';
// // // import 'role_manager.dart'; // NEW

// // // class AuthService {
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// // //   static const int _maxRetries = 2;
// // //   static const Duration _timeoutDuration = Duration(seconds: 15);

// // //   Future<void> signInWithGoogle(BuildContext context) async {
// // //     int attempt = 0;

// // //     while (attempt <= _maxRetries) {
// // //       try {
// // //         UserCredential userCredential;

// // //         if (kIsWeb) {
// // //           debugPrint('Google Sign-In on Web...');
// // //           userCredential = await _auth
// // //               .signInWithPopup(GoogleAuthProvider())
// // //               .timeout(_timeoutDuration);
// // //         } else {
// // //           debugPrint('Google Sign-In on Mobile...');
// // //           final googleProvider = GoogleAuthProvider()
// // //             ..addScope('email')
// // //             ..addScope('profile');

// // //           try {
// // //             userCredential = await _auth
// // //                 .signInWithProvider(googleProvider)
// // //                 .timeout(_timeoutDuration);
// // //           } catch (e) {
// // //             if (!context.mounted) return;
// // //             showError(context, 'Google sign-in failed: $e');
// // //             return;
// // //           }
// // //         }

// // //         final user = userCredential.user;
// // //         final uid = user?.uid;
// // //         final email = user?.email;

// // //         if (uid == null || email == null) {
// // //           if (!context.mounted) return;
// // //           showError(
// // //             context,
// // //             "Google account did not return a valid email/uid.",
// // //           );
// // //           return;
// // //         }

// // //         final userDocRef = _firestore.collection('users').doc(uid);
// // //         //This may be unnecessary i'm just keeping incase we need it later
// // //         final existingDoc = await userDocRef.get();
// // //         if (!existingDoc.exists) {
// // //           debugPrint('🆕 New user detected.');
// // //         } else {
// // //           debugPrint('🔁 Returning user.');
// // //         }

// // //         // if (!existingDoc.exists) {
// // //         //   debugPrint('🆕 New user detected. Running first-time setup...');
// // //         //   // Optional: add one-time fields
// // //         //   await userDocRef.set({
// // //         //     'createdAt': FieldValue.serverTimestamp(),
// // //         //     'onboardingComplete': false,
// // //         //   }, SetOptions(merge: true));
// // //         // } else {
// // //         //   debugPrint('🔁 Returning user logging in.');
// // //         // }

// // //         String? fcmToken = await FirebaseMessaging.instance.getToken();
// // //         final deviceInfo = DeviceInfoPlugin();
// // //         Map<String, dynamic> deviceData = {};
// // //         if (!kIsWeb) {
// // //           final android = await deviceInfo.androidInfo;
// // //           deviceData = {
// // //             'device': android.model,
// // //             'osVersion': android.version.release,
// // //           };
// // //         }

// // //         await userDocRef.set({
// // //           'uid': uid,
// // //           'email': email,
// // //           // 'name': user.displayName ?? '',
// // //           'name': user?.displayName ?? '',
// // //           'fcmToken': fcmToken ?? '',
// // //           'lastLogin': FieldValue.serverTimestamp(),
// // //           'deviceInfo': deviceData,
// // //           'updatedAt': FieldValue.serverTimestamp(),
// // //         }, SetOptions(merge: true));

// // //         debugPrint('User document updated/created');
// // //         return;
// // //       } catch (e) {
// // //         attempt++;
// // //         if (attempt > _maxRetries) {
// // //           if (!context.mounted) return;
// // //           debugPrint('Sign-In Error after $attempt attempts: $e');
// // //           showError(context, e);
// // //           return;
// // //         }
// // //         debugPrint('Sign-In attempt $attempt failed, retrying... Error: $e');
// // //       }
// // //     }
// // //   }

// // //   /// Signs out the current user and clears persisted role
// // //   Future<void> logout(BuildContext context) async {
// // //     try {
// // //       await FirebaseAuth.instance.signOut();
// // //       await RoleManager.clearRole(); // NEW
// // //       if (!context.mounted) return;
// // //       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
// // //     } catch (e) {
// // //       debugPrint('Logout error: $e');
// // //     }
// // //   }

// // //   /// Deletes the user's Firebase account and user doc
// // //   Future<void> deleteAccount(BuildContext context) async {
// // //     try {
// // //       final user = FirebaseAuth.instance.currentUser;
// // //       if (user == null) return;

// // //       await FirebaseFirestore.instance
// // //           .collection('users')
// // //           .doc(user.uid)
// // //           .delete();
// // //       await user.delete();
// // //       await RoleManager.clearRole(); // NEW

// // //       if (!context.mounted) return;
// // //       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
// // //     } catch (e) {
// // //       debugPrint('Account deletion error: $e');
// // //       if (!context.mounted) return;
// // //       showError(context, 'Failed to delete account. Please try again later.');
// // //     }
// // //   }
// // // }


// // AuthService.dart
// //
// // Handles Google Sign-In using Firebase Auth (v7.x).
// // - Web: uses `signInWithPopup`
// // - Mobile: uses `signInWithProvider`
// //
// // Also:
// // - Saves FCM token
// // - Stores login timestamp & device metadata
// // - Leaves routing to AuthGate + UserRouter (no duplicate logic)
// // - Clears persisted role on logout.

// // import 'package:coursebuddy/widgets/error_dialog.dart';
// // import 'package:flutter/foundation.dart' show kIsWeb;
// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:device_info_plus/device_info_plus.dart';
// // import 'OLD/role_manager.dart'; // NEW

// // class AuthService {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// //   static const int _maxRetries = 2;
// //   static const Duration _timeoutDuration = Duration(seconds: 15);

// //   Future<void> signInWithGoogle(BuildContext context) async {
// //     int attempt = 0;

// //     while (attempt <= _maxRetries) {
// //       try {
// //         UserCredential userCredential;

// //         if (kIsWeb) {
// //           debugPrint('Google Sign-In on Web...');
// //           userCredential = await _auth
// //               .signInWithPopup(GoogleAuthProvider())
// //               .timeout(_timeoutDuration);
// //         } else {
// //           debugPrint('Google Sign-In on Mobile...');
// //           final googleProvider = GoogleAuthProvider()
// //             ..addScope('email')
// //             ..addScope('profile');

// //           try {
// //             userCredential = await _auth
// //                 .signInWithProvider(googleProvider)
// //                 .timeout(_timeoutDuration);
// //           } catch (e) {
// //             if (!context.mounted) return;
// //             showError(context, 'Google sign-in failed: $e');
// //             return;
// //           }
// //         }

// //         final user = userCredential.user;
// //         final uid = user?.uid;
// //         final email = user?.email;

// //         if (uid == null || email == null) {
// //           if (!context.mounted) return;
// //           showError(
// //             context,
// //             "Google account did not return a valid email/uid.",
// //           );
// //           return;
// //         }

// //         final userDocRef = _firestore.collection('users').doc(uid);
// //         //This may be unnecessary i'm just keeping incase we need it later
// //         final existingDoc = await userDocRef.get();
// //         if (!existingDoc.exists) {
// //           debugPrint('🆕 New user detected.');
// //         } else {
// //           debugPrint('🔁 Returning user.');
// //         }

// //         // if (!existingDoc.exists) {
// //         //   debugPrint('🆕 New user detected. Running first-time setup...');
// //         //   // Optional: add one-time fields
// //         //   await userDocRef.set({
// //         //     'createdAt': FieldValue.serverTimestamp(),
// //         //     'onboardingComplete': false,
// //         //   }, SetOptions(merge: true));
// //         // } else {
// //         //   debugPrint('🔁 Returning user logging in.');
// //         // }

// //         String? fcmToken = await FirebaseMessaging.instance.getToken();
// //         final deviceInfo = DeviceInfoPlugin();
// //         Map<String, dynamic> deviceData = {};
// //         if (!kIsWeb) {
// //           final android = await deviceInfo.androidInfo;
// //           deviceData = {
// //             'device': android.model,
// //             'osVersion': android.version.release,
// //           };
// //         }

// //         await userDocRef.set({
// //           'uid': uid,
// //           'email': email,
// //           // 'name': user.displayName ?? '',
// //           'name': user?.displayName ?? '',
// //           'fcmToken': fcmToken ?? '',
// //           'lastLogin': FieldValue.serverTimestamp(),
// //           'deviceInfo': deviceData,
// //           'updatedAt': FieldValue.serverTimestamp(),
// //         }, SetOptions(merge: true));

// //         debugPrint('User document updated/created');
// //         return;
// //       } catch (e) {
// //         attempt++;
// //         if (attempt > _maxRetries) {
// //           if (!context.mounted) return;
// //           debugPrint('Sign-In Error after $attempt attempts: $e');
// //           showError(context, e);
// //           return;
// //         }
// //         debugPrint('Sign-In attempt $attempt failed, retrying... Error: $e');
// //       }
// //     }
// //   }

// //   /// Signs out the current user and clears persisted role
// //   Future<void> logout(BuildContext context) async {
// //     try {
// //       await FirebaseAuth.instance.signOut();
// //       await RoleManager.clearRole(); // NEW
// //       if (!context.mounted) return;
// //       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
// //     } catch (e) {
// //       debugPrint('Logout error: $e');
// //     }
// //   }

// //   /// Deletes the user's Firebase account and user doc
// //   Future<void> deleteAccount(BuildContext context) async {
// //     try {
// //       final user = FirebaseAuth.instance.currentUser;
// //       if (user == null) return;

// //       await FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(user.uid)
// //           .delete();
// //       await user.delete();
// //       await RoleManager.clearRole(); // NEW

// //       if (!context.mounted) return;
// //       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
// //     } catch (e) {
// //       debugPrint('Account deletion error: $e');
// //       if (!context.mounted) return;
// //       showError(context, 'Failed to delete account. Please try again later.');
// //     }
// //   }
// // }

// // // // /// AuthService.dart
// // // // ///
// // // // /// Handles Google Sign-In using Firebase Auth (v7.x).
// // // // /// - Web: uses `signInWithPopup`
// // // // /// - Mobile: uses `signInWithProvider`
// // // // ///
// // // // /// Also:
// // // // /// - Saves FCM token
// // // // /// - Stores login timestamp & device metadata
// // // // /// - Leaves routing to AuthGate + UserRouter (no duplicate logic)

// // // // import 'package:coursebuddy/widgets/error_dialog.dart';
// // // // import 'package:flutter/foundation.dart' show kIsWeb;
// // // // import 'package:flutter/material.dart';
// // // // import 'package:firebase_auth/firebase_auth.dart';
// // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // import 'package:firebase_messaging/firebase_messaging.dart';
// // // // import 'package:device_info_plus/device_info_plus.dart';

// // // // class AuthService {
// // // //   final FirebaseAuth _auth = FirebaseAuth.instance;
// // // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// // // //   // Maximum number of retries for sign-in
// // // //   static const int _maxRetries = 2;
// // // //   // Timeout duration for sign-in attempts
// // // //   static const Duration _timeoutDuration = Duration(seconds: 15);

// // // //   Future<void> signInWithGoogle(BuildContext context) async {
// // // //     int attempt = 0;

// // // //     while (attempt <= _maxRetries) {
// // // //       try {
// // // //         UserCredential userCredential;

// // // //         if (kIsWeb) {
// // // //           debugPrint('Google Sign-In on Web...');
// // // //           userCredential = await _auth
// // // //               .signInWithPopup(GoogleAuthProvider())
// // // //               .timeout(_timeoutDuration);
// // // //         } else {
// // // //           debugPrint('Google Sign-In on Mobile...');
// // // //           final googleProvider = GoogleAuthProvider()
// // // //             ..addScope('email')
// // // //             ..addScope('profile');

// // // //           // ✅ Updated to use try/catch instead of unsupported method
// // // //           try {
// // // //             userCredential = await _auth
// // // //                 .signInWithProvider(googleProvider)
// // // //                 .timeout(_timeoutDuration);
// // // //           } catch (e) {
// // // //             if (!context.mounted) return;
// // // //             showError(context, 'Google sign-in failed: $e');
// // // //             return;
// // // //           }
// // // //         }

// // // //         final user = userCredential.user;
// // // //         final uid = user?.uid;
// // // //         final email = user?.email;

// // // //         debugPrint('Auth success → UID: $uid, Email: $email');

// // // //         if (uid == null || email == null) {
// // // //           if (!context.mounted) return;
// // // //           showError(
// // // //             context,
// // // //             "Google account did not return a valid email/uid.",
// // // //           );
// // // //           return;
// // // //         }

// // // //         final userDocRef = _firestore.collection('users').doc(uid);
// // // //         final existingDoc = await userDocRef.get();

// // // //         // Get FCM Token
// // // //         String? fcmToken = await FirebaseMessaging.instance.getToken();
// // // //         debugPrint('FCM Token: ${fcmToken ?? "null"}');

// // // //         // Get Device Info (only for mobile, optional on web)
// // // //         final deviceInfo = DeviceInfoPlugin();
// // // //         Map<String, dynamic> deviceData = {};
// // // //         if (!kIsWeb) {
// // // //           final android = await deviceInfo.androidInfo;
// // // //           deviceData = {
// // // //             'device': android.model,
// // // //             'osVersion': android.version.release,
// // // //           };
// // // //         }

// // // //         await userDocRef.set({
// // // //           'uid': uid,
// // // //           'email': email,
// // // //           'name': user?.displayName ?? '',
// // // //           'fcmToken': fcmToken ?? '',
// // // //           'lastLogin': FieldValue.serverTimestamp(),
// // // //           'deviceInfo': deviceData,
// // // //           'updatedAt': FieldValue.serverTimestamp(),
// // // //         }, SetOptions(merge: true));

// // // //         debugPrint('User document updated/created');

// // // //         // ✅ DO NOT route here — AuthGate will handle routing
// // // //         return; // Success, exit loop
// // // //       } catch (e) {
// // // //         // stack) {
// // // //         attempt++;
// // // //         if (attempt > _maxRetries) {
// // // //           if (!context.mounted) return;
// // // //           debugPrint('Sign-In Error after $attempt attempts: $e');
// // // //           showError(context, e); //, stack);
// // // //           return;
// // // //         }
// // // //         debugPrint('Sign-In attempt $attempt failed, retrying... Error: $e');
// // // //       }
// // // //     }
// // // //   }

// // // //   /// Signs out the current user and resets navigation
// // // //   Future<void> logout(BuildContext context) async {
// // // //     try {
// // // //       await FirebaseAuth.instance.signOut();
// // // //       if (!context.mounted) return;
// // // //       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
// // // //     } catch (e) {
// // // //       debugPrint('Logout error: $e');
// // // //     }
// // // //   }

// // // //   /// Deletes the user's Firebase account and user doc
// // // //   Future<void> deleteAccount(BuildContext context) async {
// // // //     try {
// // // //       final user = FirebaseAuth.instance.currentUser;
// // // //       if (user == null) return;

// // // //       await FirebaseFirestore.instance
// // // //           .collection('users')
// // // //           .doc(user.uid)
// // // //           .delete();
// // // //       await user.delete();

// // // //       if (!context.mounted) return;
// // // //       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
// // // //     } catch (e) {
// // // //       debugPrint('Account deletion error: $e');
// // // //       if (!context.mounted) return;
// // // //       showError(context, 'Failed to delete account. Please try again later.');
// // // //     }
// // // //   }
// // // // }
