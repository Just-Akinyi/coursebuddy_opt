// AuthGate listens for auth changes, checks session expiration.
// If expired, signs out asynchronously (avoids build-time side effects).
// If valid, hands off to getDashboardForUser (UserRouter) for role-based routing.
// Uses your custom showError utility to handle loading errors gracefully.
// Debug-only prints wrapped with kDebugMode for clean production builds.

import 'package:coursebuddy/screens/login.dart';
import 'package:coursebuddy/services/user_router.dart';
import 'package:coursebuddy/widgets/error_dialog.dart'; // your custom showError function
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // Max days allowed since last sign-in before forcing logout
  static const int maxDaysLoggedIn = 7;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        // Show loading indicator while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // If no user logged in, show login screen
        if (user == null) return const LoginScreen();

        final lastSignIn = user.metadata.lastSignInTime ?? DateTime.now();
        final daysDiff = DateTime.now().difference(lastSignIn).inDays;

        // Debug-only log for last sign-in time
        if (kDebugMode) {
          print("User last signed in: ${user.metadata.lastSignInTime}");
        }

        // If user session is expired, sign out asynchronously and show login
        if (daysDiff > maxDaysLoggedIn) {
          Future.microtask(() => FirebaseAuth.instance.signOut());
          return const LoginScreen();
        }

        // Delegate user dashboard loading to UserRouter utility
        return FutureBuilder<Widget>(
          future: getDashboardForUser(user.email ?? ""),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snap.hasError) {
              // Handle errors gracefully with your custom error dialog
              Future.microtask(
                  () => showError(ctx, snap.error!)); // snap.stackTrace));
              return const Scaffold(
                body: Center(child: Text('Something went wrong.')),
              );
            }

            if (!snap.hasData) {
              // Fallback loading state (should rarely occur)
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Return the dashboard widget determined by UserRouter
            return snap.data!;
          },
        );
      },
    );
  }
}
