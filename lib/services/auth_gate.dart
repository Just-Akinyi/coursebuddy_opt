import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coursebuddy/services/user_router.dart';
import 'package:coursebuddy/screens/login.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = snapshot.data!;
        return FutureBuilder<Widget>(
          future: getDashboardForUser(user.email ?? "noemail"),
          builder: (context, dashboardSnapshot) {
            if (dashboardSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (dashboardSnapshot.hasError) {
              return Scaffold(
                body: Center(child: Text("Error: ${dashboardSnapshot.error}")),
              );
            }
            return dashboardSnapshot.data!;
          },
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:coursebuddy/services/user_router.dart';
// import 'package:coursebuddy/screens/login.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // Still connecting
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // Not logged in → go to login
//         if (!snapshot.hasData) {
//           return const LoginScreen();
//         }

//         // Logged in → resolve dashboard
//         final user = snapshot.data!;
//         return FutureBuilder<Widget>(
//           future: getDashboardForUser(user.email ?? "noemail"),
//           builder: (context, dashboardSnapshot) {
//             if (dashboardSnapshot.connectionState ==
//                 ConnectionState.waiting) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }
//             if (dashboardSnapshot.hasError) {
//               return Scaffold(
//                 body: Center(child: Text("Error: ${dashboardSnapshot.error}")),
//               );
//             }
//             return dashboardSnapshot.data!;
//           },
//         );
//       },
//     );
//   }
// }
