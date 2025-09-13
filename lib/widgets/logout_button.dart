/// Signs out the current Firebase user and navigates to the login screen.
/// After successfully signing out, this function clears the navigation stack
/// and pushes the login route (`'/login'`), preventing the user from returning
/// to the previous screens.
/// If sign-out fails, the error is caught and logged using `debugPrint`.
/// Requires a valid [BuildContext] for navigation.
///
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  } catch (e) {
    debugPrint('Logout error: $e');
  }
}
