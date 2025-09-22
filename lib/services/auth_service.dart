import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:coursebuddy/screens/login.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    // ✅ Guard: if already logged in, skip
    if (_auth.currentUser != null) {
      return null; // no need to sign in again
    }

    if (kIsWeb) {
      // ✅ Web flow: popup once
      final googleProvider = GoogleAuthProvider();
      return await _auth.signInWithPopup(googleProvider);
    } else {
      // ✅ Mobile flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception("Google sign-in aborted");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  User? get currentUser => _auth.currentUser;
}


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:coursebuddy/screens/login.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   Future<UserCredential> signInWithGoogle(BuildContext context) async {
//     // ✅ Guard: if already logged in, just return
//     if (_auth.currentUser != null) {
//       return Future.value(
//         UserCredential(additionalUserInfo: null, credential: null, user: _auth.currentUser),
//       );
//     }

//     if (kIsWeb) {
//       // ✅ Web flow: popup once
//       final googleProvider = GoogleAuthProvider();
//       return await _auth.signInWithPopup(googleProvider);
//     } else {
//       // ✅ Mobile flow
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         throw Exception("Google sign-in aborted");
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       return await _auth.signInWithCredential(credential);
//     }
//   }

//   Future<void> logout(BuildContext context) async {
//     await _auth.signOut();
//     if (!kIsWeb) {
//       await _googleSignIn.signOut();
//     }

//     if (context.mounted) {
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//         (route) => false,
//       );
//     }
//   }

//   User? get currentUser => _auth.currentUser;
// }

// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:google_sign_in/google_sign_in.dart';
// // import 'package:flutter/foundation.dart' show kIsWeb;
// // import 'package:flutter/material.dart';
// // import 'package:coursebuddy/screens/login.dart';

// // class AuthService {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final GoogleSignIn _googleSignIn = GoogleSignIn();

// //   Future<UserCredential> signInWithGoogle(BuildContext context) async {
// //     if (kIsWeb) {
// //       // ✅ Web flow: use popup
// //       final googleProvider = GoogleAuthProvider();
// //       return await _auth.signInWithPopup(googleProvider);
// //     } else {
// //       // ✅ Mobile flow: use google_sign_in
// //       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
// //       if (googleUser == null) {
// //         throw Exception("Google sign-in aborted");
// //       }

// //       final GoogleSignInAuthentication googleAuth =
// //           await googleUser.authentication;

// //       final credential = GoogleAuthProvider.credential(
// //         accessToken: googleAuth.accessToken,
// //         idToken: googleAuth.idToken,
// //       );

// //       return await _auth.signInWithCredential(credential);
// //     }
// //   }

// //   Future<void> logout(BuildContext context) async {
// //     await _auth.signOut();
// //     if (!kIsWeb) {
// //       // google_sign_in only needed on mobile
// //       await _googleSignIn.signOut();
// //     }

// //     // 🔑 Clear navigation stack → back to Login
// //     if (context.mounted) {
// //       Navigator.of(context).pushAndRemoveUntil(
// //         MaterialPageRoute(builder: (_) => const LoginScreen()),
// //         (route) => false,
// //       );
// //     }
// //   }

// //   User? get currentUser => _auth.currentUser;
// // }
