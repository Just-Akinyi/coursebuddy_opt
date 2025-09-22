// import 'package:coursebuddy/screens/login.dart';
// import 'package:coursebuddy/services/user_router.dart';
// import 'package:coursebuddy/widgets/error_dialog.dart';
// import 'package:coursebuddy/services/session_manager.dart';
// import 'package:coursebuddy/services/role_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:coursebuddy/screens/guest_user.dart';
// import '../constants/user_roles.dart';

// class AuthGate extends StatefulWidget {
//   const AuthGate({super.key});

//   static const int maxDaysLoggedIn = 7;

//   @override
//   State<AuthGate> createState() => _AuthGateState();
// }

// class _AuthGateState extends State<AuthGate> {
//   Future<Widget>? _dashboardFuture;
//   bool _approvalShown = false; // Prevent duplicate snack/dialog firing

//   @override
//   void initState() {
//     super.initState();
//   }

//   // Signs out the current Firebase user and navigates to the login screen.
//   Future<void> logout(BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       await RoleManager.clearRole();
//       SessionManager.currentRole = null;

//       if (!context.mounted) return;
//       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//     } catch (e) {
//       debugPrint('Logout error: $e');
//     }
//   }

//   Future<Widget> _buildDashboardWidget(User user) async {
//     final lastSignIn = user.metadata.lastSignInTime ?? DateTime.now();
//     final daysDiff = DateTime.now().difference(lastSignIn).inDays;

//     if (kDebugMode) {
//       print("User last signed in: ${user.metadata.lastSignInTime}");
//     }

//     if (daysDiff > AuthGate.maxDaysLoggedIn) {
//       await logout(context);
//       if (!mounted) return const LoginScreen();
//       return const LoginScreen();
//     }

//     try {
//       final idTokenResult = await user.getIdTokenResult(true);
//       final claims = idTokenResult.claims ?? {};
//       String role = claims['role'] as String? ?? 'guest';

//       final userDocRef =
//           FirebaseFirestore.instance.collection('users').doc(user.uid);
//       final doc = await userDocRef.get();

//       if (!doc.exists) {
//         await userDocRef.set({
//           'uid': user.uid,
//           'email': user.email,
//           'name': user.displayName ?? 'Guest',
//           'role': role,
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//       } else {
//         final data = doc.data()!;
//         role = (data['role'] as String?) ?? role;
//       }

//       // Save role in managers
//       final savedRole = await RoleManager.getRole();
//       if (savedRole != null) {
//         SessionManager.currentRole = savedRole;
//       } else {
//         SessionManager.currentRole = role;
//         await RoleManager.saveRole(role);
//       }

//       if (SessionManager.currentRole == UserRoles.guest) {
//         return const NotRegisteredScreen();
//       }

//       // Prevent repeated "approved" messages
//       if (!_approvalShown && mounted) {
//         _approvalShown = true;
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("You've been approved")),
//           );
//         });
//       }

//       return await getDashboardForUser(user.email ?? "");
//     } catch (e) {
//       debugPrint('Error while building dashboard: $e');
//       rethrow; // Rethrow to handle higher-level errors
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (ctx, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         final user = snapshot.data;
//         if (user == null) {
//           // Reset state on logout
//           _approvalShown = false;
//           RoleManager.clearRole();
//           SessionManager.currentRole = null;
//           _dashboardFuture = null;
//           return const LoginScreen();
//         }

//         // Only create future once per session to prevent flashing
//         _dashboardFuture ??= _buildDashboardWidget(user);

//         return FutureBuilder<Widget>(
//           future: _dashboardFuture,
//           builder: (ctx, snap) {
//             if (snap.connectionState == ConnectionState.waiting) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }
//             if (snap.hasError) {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (mounted) showError(ctx, snap.error!);
//               });
//               return const Scaffold(
//                 body: Center(child: Text('Something went wrong.')),
//               );
//             }
//             if (!snap.hasData) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }
//             return snap.data!;
//           },
//         );
//       },
//     );
//   }
// }

// // import 'package:coursebuddy/screens/login.dart';
// // import 'package:coursebuddy/services/user_router.dart';
// // import 'package:coursebuddy/widgets/error_dialog.dart';
// // import 'package:coursebuddy/screens/admin/choose_role_dialog.dart';
// // import 'package:coursebuddy/services/session_manager.dart';
// // import 'package:coursebuddy/services/role_manager.dart';
// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:coursebuddy/screens/guest_user.dart';
// // import '../constants/user_roles.dart';

// // class AuthGate extends StatefulWidget {
// //   const AuthGate({super.key});

// //   static const int maxDaysLoggedIn = 7;

// //   @override
// //   State<AuthGate> createState() => _AuthGateState();
// // }

// // class _AuthGateState extends State<AuthGate> {
// //   Future<Widget>? _dashboardFuture;
// //   bool _approvalShown = false; // Prevent duplicate snack/dialog firing

// //   @override
// //   void initState() {
// //     super.initState();
// //   }

// //   // Signs out the current Firebase user and navigates to the login screen.
// //   Future<void> logout(BuildContext context) async {
// //     try {
// //       await FirebaseAuth.instance.signOut();
// //       await RoleManager.clearRole();
// //       SessionManager.currentRole = null;

// //       if (!context.mounted) return;
// //       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
// //     } catch (e) {
// //       debugPrint('Logout error: $e');
// //     }
// //   }

// //   Future<Widget> _buildDashboardWidget(User user) async {
// //     final lastSignIn = user.metadata.lastSignInTime ?? DateTime.now();
// //     final daysDiff = DateTime.now().difference(lastSignIn).inDays;

// //     if (kDebugMode) {
// //       print("User last signed in: ${user.metadata.lastSignInTime}");
// //     }

// //     if (daysDiff > AuthGate.maxDaysLoggedIn) {
// //       await logout(context);
// //       if (!mounted) return const LoginScreen();
// //       return const LoginScreen();
// //     }

// //     try {
// //       final idTokenResult = await user.getIdTokenResult(true);
// //       final claims = idTokenResult.claims ?? {};
// //       String? roleFromClaims = claims['role'] as String?;
// // String role = roleFromClaims ?? 'guest';

// //       // List<String> rolesFromClaims = [];
// //       // if (claims.containsKey('roles') && claims['roles'] is Map) {
// //       //   final Map rolesMap = claims['roles'] as Map;
// //       //   rolesFromClaims = rolesMap.keys
// //       //       .where((k) => rolesMap[k] == true)
// //       //       .map((e) => e.toString())
// //       //       .toList();
// //       // }

// //       // List<String> roles = rolesFromClaims;

// //       final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
// //       final doc = await userDocRef.get();

// //       if (roles.isEmpty && doc.exists) {
// //         final data = doc.data()!;
// //         final fsRoles = (data['roles'] as List<dynamic>?)?.cast<String>() ?? [];
// //         roles = fsRoles;
// //       }

// //       if (roles.isEmpty) {
// //         await userDocRef.set({
// //           'uid': user.uid,
// //           'email': user.email,
// //           'name': user.displayName ?? 'Guest',
// //           'roles': [],
// //           'createdAt': FieldValue.serverTimestamp(),
// //         });
// //         roles = ['guest'];
// //       }

// //       // Handle saved role + admin priority
// //       final savedRole = await RoleManager.getRole();

// //       if (roles.contains(UserRoles.admin) && savedRole != UserRoles.admin) {
// //         SessionManager.currentRole = UserRoles.admin;
// //         await RoleManager.saveRole(UserRoles.admin);
// //       } else if (savedRole != null) {
// //         SessionManager.currentRole = savedRole;
// //       } else {
// //         if (roles.length > 1) {
// //           if (!mounted) {
// //             SessionManager.currentRole = roles.first;
// //           } else {
// //             final chosen = await showDialog<String>(
// //               context: context,
// //               builder: (_) => ChooseRoleDialog(roles: roles),
// //             );
// //             SessionManager.currentRole = chosen ?? roles.first;
// //           }
// //         } else {
// //           SessionManager.currentRole = roles.first;
// //         }
// //         await RoleManager.saveRole(SessionManager.currentRole!);
// //       }

// //       if (SessionManager.currentRole == 'guest') {
// //         return const NotRegisteredScreen();
// //       }

// //       // Prevent repeated "approved" messages
// //       if (!_approvalShown && mounted) {
// //         _approvalShown = true;
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text("You've been approved")),
// //           );
// //         });
// //       }

// //       return await getDashboardForUser(user.email ?? "");
// //     } catch (e) {
// //       debugPrint('Error while building dashboard: $e');
// //       rethrow;  // Rethrow to handle higher-level errors
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return StreamBuilder<User?>(
// //       stream: FirebaseAuth.instance.authStateChanges(),
// //       builder: (ctx, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Scaffold(
// //             body: Center(child: CircularProgressIndicator()),
// //           );
// //         }

// //         final user = snapshot.data;
// //         if (user == null) {
// //           // Reset state on logout
// //           _approvalShown = false;
// //           RoleManager.clearRole();
// //           SessionManager.currentRole = null;
// //           _dashboardFuture = null;
// //           return const LoginScreen();
// //         }

// //         // Only create future once per session to prevent flashing
// //         _dashboardFuture ??= _buildDashboardWidget(user);

// //         return FutureBuilder<Widget>(
// //           future: _dashboardFuture,
// //           builder: (ctx, snap) {
// //             if (snap.connectionState == ConnectionState.waiting) {
// //               return const Scaffold(
// //                 body: Center(child: CircularProgressIndicator()),
// //               );
// //             }
// //             if (snap.hasError) {
// //               WidgetsBinding.instance.addPostFrameCallback((_) {
// //                 if (mounted) showError(ctx, snap.error!);
// //               });
// //               return const Scaffold(
// //                 body: Center(child: Text('Something went wrong.')),
// //               );
// //             }
// //             if (!snap.hasData) {
// //               return const Scaffold(
// //                 body: Center(child: CircularProgressIndicator()),
// //               );
// //             }
// //             return snap.data!;
// //           },
// //         );
// //       },
// //     );
// //   }
// // }

// // // AuthGate.dart
// // //
// // // Listens for auth changes, checks session expiration, and performs role-based routing.
// // // - Uses RoleManager to persist selected role.
// // // - Guests are sent to NotRegisteredScreen (or GuestDashboard).
// // // - Session expiration uses maxDaysLoggedIn without forcing login unnecessarily.
// // // AuthGate.dart
// // //
// // // A more robust and reliable authentication gate.
// // //
// // // This version uses a nested FutureBuilder inside the StreamBuilder's builder.
// // // This ensures that the async logic to build the dashboard widget is re-executed
// // // every time the user's authentication state changes (e.g., after login/logout).
// // // AuthGate.dart
// // //
// // // A more robust and reliable authentication gate.
// // //
// // // This version correctly uses a StatefulWidget to handle asynchronous operations
// // // and guard against using an invalid BuildContext.
// // import 'package:coursebuddy/screens/login.dart';
// // import 'package:coursebuddy/services/user_router.dart';
// // import 'package:coursebuddy/widgets/error_dialog.dart';
// // import 'package:coursebuddy/screens/admin/choose_role_dialog.dart';
// // import 'package:coursebuddy/services/session_manager.dart';
// // import 'package:coursebuddy/services/role_manager.dart';
// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:coursebuddy/screens/guest_user.dart';
// // import 'package:coursebuddy/constants/user_roles.dart';

// // class AuthGate extends StatefulWidget {
// //   const AuthGate({super.key});

// //   static const int maxDaysLoggedIn = 7;

// //   @override
// //   State<AuthGate> createState() => _AuthGateState();
// // }

// // class _AuthGateState extends State<AuthGate> {
// //   // Use a Future variable to hold the result of the async work
// //   Future<Widget>? _dashboardFuture;

// //   bool _approvalShown = false; // prevent duplicate snack/dialog firing

// //   @override
// //   void initState() {
// //     super.initState();
// //   }

// //   // Signs out the current Firebase user and navigates to the login screen.
// //   // After successfully signing out, this function clears the navigation stack,
// //   // clears role/session state, and pushes the login route (`'/login'`).
// //   // If sign-out fails, the error is caught and logged using `debugPrint`.
// //   // Requires a valid [BuildContext] for navigation.
// //   Future<void> logout(BuildContext context) async {
// //     try {
// //       await FirebaseAuth.instance.signOut();
// //       await RoleManager.clearRole();
// //       SessionManager.currentRole = null;

// //       if (!context.mounted) return;
// //       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
// //     } catch (e) {
// //       debugPrint('Logout error: $e');
// //     }
// //   }

// //   Future<Widget> _buildDashboardWidget(User user) async {
// //     final lastSignIn = user.metadata.lastSignInTime ?? DateTime.now();
// //     final daysDiff = DateTime.now().difference(lastSignIn).inDays;

// //     if (kDebugMode) {
// //       print("User last signed in: ${user.metadata.lastSignInTime}");
// //     }

// //     if (daysDiff > AuthGate.maxDaysLoggedIn) {
// //       await logout(context);
// //       if (!mounted) return const LoginScreen();
// //       return const LoginScreen();
// //     }

// //     try {
// //       final idTokenResult = await user.getIdTokenResult(true);
// //       final claims = idTokenResult.claims ?? {};

// //       List<String> rolesFromClaims = [];
// //       if (claims.containsKey('roles') && claims['roles'] is Map) {
// //         final Map rolesMap = claims['roles'] as Map;
// //         rolesFromClaims = rolesMap.keys
// //             .where((k) => rolesMap[k] == true)
// //             .map((e) => e.toString())
// //             .toList();
// //       }

// //       List<String> roles = rolesFromClaims;

// //       final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
// //       final doc = await userDocRef.get();

// //       if (roles.isEmpty && doc.exists) {
// //         final data = doc.data()!;
// //         final fsRoles = (data['roles'] as List<dynamic>?)?.cast<String>() ?? [];
// //         roles = fsRoles;
// //       }

// //       if (roles.isEmpty) {
// //         await userDocRef.set({
// //           'uid': user.uid,
// //           'email': user.email,
// //           'name': user.displayName ?? 'Guest',
// //           'roles': ['guest'],
// //           'createdAt': FieldValue.serverTimestamp(),
// //         });
// //         roles = ['guest'];
// //       }

// //       // Handle saved role + admin priority
// //       final savedRole = await RoleManager.getRole();

// //       if (roles.contains(UserRoles.admin) && savedRole != UserRoles.admin) {
// //         SessionManager.currentRole = UserRoles.admin;
// //         await RoleManager.saveRole(UserRoles.admin);
// //       } else if (savedRole != null) {
// //         SessionManager.currentRole = savedRole;
// //       } else {
// //         if (roles.length > 1) {
// //           // Guard with a mounted check before showing the dialog
// //           if (!mounted) {
// //             SessionManager.currentRole = roles.first;
// //           } else {
// //             final chosen = await showDialog<String>(
// //               context: context,
// //               builder: (_) => ChooseRoleDialog(roles: roles),
// //             );
// //             SessionManager.currentRole = chosen ?? roles.first;
// //           }
// //         } else {
// //           SessionManager.currentRole = roles.first;
// //         }
// //         await RoleManager.saveRole(SessionManager.currentRole!);
// //       }

// //       if (SessionManager.currentRole == 'guest') {
// //         return const NotRegisteredScreen();
// //       }

// //       // Prevent repeated "approved" messages
// //       if (!_approvalShown && mounted) {
// //         _approvalShown = true;
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text("You've been approved")),
// //           );
// //         });
// //       }

// //       return await getDashboardForUser(user.email ?? "");
// //     } catch (e) {
// //       rethrow;
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return StreamBuilder<User?>(
// //       stream: FirebaseAuth.instance.authStateChanges(),
// //       builder: (ctx, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Scaffold(
// //             body: Center(child: CircularProgressIndicator()),
// //           );
// //         }

// //         final user = snapshot.data;
// //         if (user == null) {
// //           // Reset state on logout
// //           _approvalShown = false;
// //           RoleManager.clearRole();
// //           SessionManager.currentRole = null;
// //           _dashboardFuture = null;
// //           return const LoginScreen();
// //         }

// //         // Only create future once per session to prevent flashing
// //         _dashboardFuture ??= _buildDashboardWidget(user);

// //         return FutureBuilder<Widget>(
// //           future: _dashboardFuture,
// //           builder: (ctx, snap) {
// //             if (snap.connectionState == ConnectionState.waiting) {
// //               return const Scaffold(
// //                 body: Center(child: CircularProgressIndicator()),
// //               );
// //             }
// //             if (snap.hasError) {
// //               WidgetsBinding.instance.addPostFrameCallback((_) {
// //                 if (mounted) showError(ctx, snap.error!);
// //               });
// //               return const Scaffold(
// //                 body: Center(child: Text('Something went wrong.')),
// //               );
// //             }
// //             if (!snap.hasData) {
// //               return const Scaffold(
// //                 body: Center(child: CircularProgressIndicator()),
// //               );
// //             }
// //             return snap.data!;
// //           },
// //         );
// //       },
// //     );
// //   }
// // }


// // // // AuthGate.dart
// // // //
// // // // Listens for auth changes, checks session expiration, and performs role-based routing.
// // // // - Uses RoleManager to persist selected role.
// // // // - Guests are sent to NotRegisteredScreen (or GuestDashboard).
// // // // - Session expiration uses maxDaysLoggedIn without forcing login unnecessarily.
// // // // AuthGate.dart
// // // //
// // // // A more robust and reliable authentication gate.
// // // //
// // // // This version uses a nested FutureBuilder inside the StreamBuilder's builder.
// // // // This ensures that the async logic to build the dashboard widget is re-executed
// // // // every time the user's authentication state changes (e.g., after login/logout).
// // // // AuthGate.dart
// // // //
// // // // A more robust and reliable authentication gate.
// // // //
// // // // This version correctly uses a StatefulWidget to handle asynchronous operations
// // // // and guard against using an invalid BuildContext.
// // // import 'package:coursebuddy/screens/login.dart';
// // // import 'package:coursebuddy/services/user_router.dart';
// // // import 'package:coursebuddy/widgets/error_dialog.dart';
// // // import 'package:coursebuddy/screens/admin/choose_role_dialog.dart';
// // // import 'package:coursebuddy/services/session_manager.dart';
// // // import 'package:coursebuddy/services/role_manager.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:flutter/foundation.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:coursebuddy/screens/guest_user.dart';

// // // class AuthGate extends StatefulWidget {
// // //   const AuthGate({super.key});

// // //   static const int maxDaysLoggedIn = 7;

// // //   @override
// // //   State<AuthGate> createState() => _AuthGateState();
// // // }

// // // class _AuthGateState extends State<AuthGate> {
// // //   // Use a Future variable to hold the result of the async work
// // //   Future<Widget>? _dashboardFuture;

// // //   bool _approvalShown = false; // prevent duplicate snack/dialog firing

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //   }

// // //   // Signs out the current Firebase user and navigates to the login screen.
// // //   // After successfully signing out, this function clears the navigation stack,
// // //   // clears role/session state, and pushes the login route (`'/login'`).
// // //   // If sign-out fails, the error is caught and logged using `debugPrint`.
// // //   // Requires a valid [BuildContext] for navigation.
// // //   Future<void> logout(BuildContext context) async {
// // //     try {
// // //       await FirebaseAuth.instance.signOut();
// // //       await RoleManager.clearRole();
// // //       SessionManager.currentRole = null;

// // //       if (!context.mounted) return;
// // //       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
// // //     } catch (e) {
// // //       debugPrint('Logout error: $e');
// // //     }
// // //   }

// // //   // This is now an instance method within the State class, giving it access to `mounted`.
// // //   // Future<Widget> _buildDashboardWidget(User user) async {
// // //   //   if (user == null) {
// // //   //     return const LoginScreen();
// // //   //   }

// // //   //   final lastSignIn = user.metadata.lastSignInTime ?? DateTime.now();
// // //   //   final daysDiff = DateTime.now().difference(lastSignIn).inDays;

// // //   //   if (kDebugMode) {
// // //   //     print("User last signed in: ${user.metadata.lastSignInTime}");
// // //   //   }
// // //   Future<Widget> _buildDashboardWidget(User user) async {
// // //     final lastSignIn = user.metadata.lastSignInTime ?? DateTime.now();
// // //     final daysDiff = DateTime.now().difference(lastSignIn).inDays;

// // //     if (kDebugMode) {
// // //       print("User last signed in: ${user.metadata.lastSignInTime}");
// // //     }

// // //     if (daysDiff > AuthGate.maxDaysLoggedIn) {
// // //       await logout(context); // use the new extended logout
// // //       if (!mounted) return const LoginScreen();
// // //       return const LoginScreen();
// // //     }

// // //     try {
// // //       final idTokenResult = await user.getIdTokenResult(true);
// // //       final claims = idTokenResult.claims ?? {};

// // //       List<String> rolesFromClaims = [];
// // //       if (claims.containsKey('roles') && claims['roles'] is Map) {
// // //         final Map rolesMap = claims['roles'] as Map;
// // //         rolesFromClaims = rolesMap.keys
// // //             .where((k) => rolesMap[k] == true)
// // //             .map((e) => e.toString())
// // //             .toList();
// // //       }

// // //       List<String> roles = rolesFromClaims;

// // //       final userDocRef = FirebaseFirestore.instance
// // //           .collection('users')
// // //           .doc(user.uid);
// // //       final doc = await userDocRef.get();

// // //       if (roles.isEmpty && doc.exists) {
// // //         final data = doc.data()!;
// // //         final fsRoles = (data['roles'] as List<dynamic>?)?.cast<String>() ?? [];
// // //         roles = fsRoles;
// // //       }

// // //       if (roles.isEmpty) {
// // //         await userDocRef.set({
// // //           'uid': user.uid,
// // //           'email': user.email,
// // //           'name': user.displayName ?? 'Guest',
// // //           'roles': ['guest'],
// // //           'createdAt': FieldValue.serverTimestamp(),
// // //         });
// // //         roles = ['guest'];
// // //       }

// // //       final savedRole = await RoleManager.getRole();

// // //       if (savedRole != null) {
// // //         SessionManager.currentRole = savedRole;
// // //       } else {
// // //         if (roles.length > 1) {
// // //           // Guard with a mounted check before showing the dialog
// // //           if (!mounted) {
// // //             SessionManager.currentRole = roles.first;
// // //           } else {
// // //             final chosen = await showDialog<String>(
// // //               context: context,
// // //               builder: (_) => ChooseRoleDialog(roles: roles),
// // //             );
// // //             SessionManager.currentRole = chosen ?? roles.first;
// // //           }
// // //         } else {
// // //           SessionManager.currentRole = roles.first;
// // //         }
// // //         await RoleManager.saveRole(SessionManager.currentRole!);
// // //       }

// // //       if (SessionManager.currentRole == 'guest') {
// // //         return const NotRegisteredScreen();
// // //       }

// // //       // Prevent repeated "approved" messages
// // //       if (!_approvalShown && mounted) {
// // //         _approvalShown = true;
// // //         ScaffoldMessenger.of(
// // //           context,
// // //         ).showSnackBar(const SnackBar(content: Text("You've been approved")));
// // //       }

// // //       return await getDashboardForUser(user.email ?? "");
// // //     } catch (e) {
// // //       rethrow;
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return StreamBuilder<User?>(
// // //       stream: FirebaseAuth.instance.authStateChanges(),
// // //       builder: (ctx, snapshot) {
// // //         if (snapshot.connectionState == ConnectionState.waiting) {
// // //           return const Scaffold(
// // //             body: Center(child: CircularProgressIndicator()),
// // //           );
// // //         }

// // //         final user = snapshot.data;
// // //         if (user == null) {
// // //           // Reset state on logout
// // //           _approvalShown = false;
// // //           RoleManager.clearRole();
// // //           SessionManager.currentRole = null;
// // //           return const LoginScreen();
// // //         }

// // //         // Rebuild future on each auth change
// // //         _dashboardFuture = _buildDashboardWidget(user);

// // //         return FutureBuilder<Widget>(
// // //           future: _dashboardFuture,
// // //           builder: (ctx, snap) {
// // //             if (snap.connectionState == ConnectionState.waiting) {
// // //               return const Scaffold(
// // //                 body: Center(child: CircularProgressIndicator()),
// // //               );
// // //             }
// // //             if (snap.hasError) {
// // //               WidgetsBinding.instance.addPostFrameCallback((_) {
// // //                 // Guard with a mounted check before showing the error dialog
// // //                 if (mounted) {
// // //                   showError(ctx, snap.error!);
// // //                 }
// // //               });
// // //               return const Scaffold(
// // //                 body: Center(child: Text('Something went wrong.')),
// // //               );
// // //             }
// // //             if (!snap.hasData) {
// // //               return const Scaffold(
// // //                 body: Center(child: CircularProgressIndicator()),
// // //               );
// // //             }
// // //             return snap.data!;
// // //           },
// // //         );
// // //       },
// // //     );
// // //   }
// // // }

// // // // AuthGate.dart
// // // //
// // // // Listens for auth changes, checks session expiration, and performs role-based routing.
// // // // - Uses RoleManager to persist selected role.
// // // // - Guests are sent to NotRegisteredScreen (or GuestDashboard).
// // // // - Session expiration uses maxDaysLoggedIn without forcing login unnecessarily.
// // // // AuthGate.dart
// // // //
// // // // A more robust and reliable authentication gate.
// // // //
// // // // This version uses a nested FutureBuilder inside the StreamBuilder's builder.
// // // // This ensures that the async logic to build the dashboard widget is re-executed
// // // // every time the user's authentication state changes (e.g., after login/logout).
// // // // AuthGate.dart
// // // //
// // // // A more robust and reliable authentication gate.
// // // //
// // // // This version correctly uses a StatefulWidget to handle asynchronous operations
// // // // and guard against using an invalid BuildContext.


// // // // import 'package:coursebuddy/screens/login.dart';
// // // // import 'package:coursebuddy/services/user_router.dart';
// // // // import 'package:coursebuddy/widgets/error_dialog.dart';
// // // // import 'package:coursebuddy/screens/admin/choose_role_dialog.dart';
// // // // import 'package:coursebuddy/services/session_manager.dart';
// // // // import 'package:coursebuddy/services/role_manager.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:firebase_auth/firebase_auth.dart';
// // // // import 'package:flutter/foundation.dart';
// // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // import 'package:coursebuddy/screens/guest_user.dart';

// // // // class AuthGate extends StatefulWidget {
// // // //   const AuthGate({super.key});

// // // //   static const int maxDaysLoggedIn = 7;

// // // //   @override
// // // //   State<AuthGate> createState() => _AuthGateState();
// // // // }

// // // // class _AuthGateState extends State<AuthGate> {
// // // //   // Use a Future variable to hold the result of the async work
// // // //   late Future<Widget> _dashboardFuture;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     // Initialize the future when the widget is first created
// // // //     _dashboardFuture = _buildDashboardWidget();
// // // //   }

// // // //   // This is now an instance method within the State class, giving it access to `mounted`.
// // // //   Future<Widget> _buildDashboardWidget() async {
// // // //     final user = FirebaseAuth.instance.currentUser;

// // // //     if (user == null) {
// // // //       return const LoginScreen();
// // // //     }

// // // //     final lastSignIn = user.metadata.lastSignInTime ?? DateTime.now();
// // // //     final daysDiff = DateTime.now().difference(lastSignIn).inDays;

// // // //     if (kDebugMode) {
// // // //       print("User last signed in: ${user.metadata.lastSignInTime}");
// // // //     }

// // // //     if (daysDiff > AuthGate.maxDaysLoggedIn) {
// // // //       await FirebaseAuth.instance.signOut();
// // // //       if (!mounted) return const LoginScreen();
// // // //       return const LoginScreen();
// // // //     }

// // // //     try {
// // // //       final idTokenResult = await user.getIdTokenResult(true);
// // // //       final claims = idTokenResult.claims ?? {};

// // // //       List<String> rolesFromClaims = [];
// // // //       if (claims.containsKey('roles') && claims['roles'] is Map) {
// // // //         final Map rolesMap = claims['roles'] as Map;
// // // //         rolesFromClaims = rolesMap.keys
// // // //             .where((k) => rolesMap[k] == true)
// // // //             .map((e) => e.toString())
// // // //             .toList();
// // // //       }

// // // //       List<String> roles = rolesFromClaims;

// // // //       final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
// // // //       final doc = await userDocRef.get();

// // // //       if (roles.isEmpty && doc.exists) {
// // // //         final data = doc.data()!;
// // // //         final fsRoles = (data['roles'] as List<dynamic>?)?.cast<String>() ?? [];
// // // //         roles = fsRoles;
// // // //       }

// // // //       if (roles.isEmpty) {
// // // //         await userDocRef.set({
// // // //           'uid': user.uid,
// // // //           'email': user.email,
// // // //           'name': user.displayName ?? 'Guest',
// // // //           'roles': ['guest'],
// // // //           'createdAt': FieldValue.serverTimestamp(),
// // // //         });
// // // //         roles = ['guest'];
// // // //       }

// // // //       final savedRole = await RoleManager.getRole();

// // // //       if (savedRole != null) {
// // // //         SessionManager.currentRole = savedRole;
// // // //       } else {
// // // //         if (roles.length > 1) {
// // // //           // Guard with a mounted check before showing the dialog
// // // //           if (!mounted) {
// // // //             SessionManager.currentRole = roles.first;
// // // //           } else {
// // // //             final chosen = await showDialog<String>(
// // // //               context: context,
// // // //               builder: (_) => ChooseRoleDialog(roles: roles),
// // // //             );
// // // //             SessionManager.currentRole = chosen ?? roles.first;
// // // //           }
// // // //         } else {
// // // //           SessionManager.currentRole = roles.first;
// // // //         }
// // // //         await RoleManager.saveRole(SessionManager.currentRole!);
// // // //       }

// // // //       if (SessionManager.currentRole == 'guest') {
// // // //         return const NotRegisteredScreen();
// // // //       }

// // // //       return await getDashboardForUser(user.email ?? "");
// // // //     } catch (e) {
// // // //       rethrow;
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return StreamBuilder<User?>(
// // // //       stream: FirebaseAuth.instance.authStateChanges(),
// // // //       builder: (ctx, snapshot) {
// // // //         if (snapshot.connectionState == ConnectionState.waiting) {
// // // //           return const Scaffold(
// // // //             body: Center(child: CircularProgressIndicator()),
// // // //           );
// // // //         }

// // // //         final user = snapshot.data;
// // // //         if (user == null) {
// // // //           return const LoginScreen();
// // // //         }

// // // //         return FutureBuilder<Widget>(
// // // //           future: _dashboardFuture,
// // // //           builder: (ctx, snap) {
// // // //             if (snap.connectionState == ConnectionState.waiting) {
// // // //               return const Scaffold(
// // // //                 body: Center(child: CircularProgressIndicator()),
// // // //               );
// // // //             }
// // // //             if (snap.hasError) {
// // // //               WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //                 // Guard with a mounted check before showing the error dialog
// // // //                 if (mounted) {
// // // //                   showError(ctx, snap.error!);
// // // //                 }
// // // //               });
// // // //               return const Scaffold(body: Center(child: Text('Something went wrong.')));
// // // //             }
// // // //             if (!snap.hasData) {
// // // //               return const Scaffold(body: Center(child: CircularProgressIndicator()));
// // // //             }
// // // //             return snap.data!;
// // // //           },
// // // //         );
// // // //       },
// // // //     );
// // // //   }
// // // // }


// // // // // AuthGate listens for auth changes, checks session expiration.
// // // // // If expired, signs out asynchronously (avoids build-time side effects).
// // // // // If valid, hands off to getDashboardForUser (UserRouter) for role-based routing.
// // // // // Uses your custom showError utility to handle loading errors gracefully.
// // // // // Debug-only prints wrapped with kDebugMode for clean production builds.

// // // // import 'package:coursebuddy/screens/login.dart';
// // // // import 'package:coursebuddy/services/user_router.dart';
// // // // import 'package:coursebuddy/widgets/error_dialog.dart'; // your custom showError function
// // // // import 'package:coursebuddy/screens/admin/choose_role_dialog.dart';
// // // // import 'package:coursebuddy/services/session_manager.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:firebase_auth/firebase_auth.dart';
// // // // import 'package:flutter/foundation.dart';
// // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // import 'package:coursebuddy/screens/guest_user.dart';

// // // // class AuthGate extends StatelessWidget {
// // // //   const AuthGate({super.key});

// // // //   // Max days allowed since last sign-in before forcing logout
// // // //   static const int maxDaysLoggedIn = 7;

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return StreamBuilder<User?>(
// // // //       stream: FirebaseAuth.instance.authStateChanges(),
// // // //       builder: (ctx, snapshot) {
// // // //         // Show loading indicator while waiting for auth state
// // // //         if (snapshot.connectionState == ConnectionState.waiting) {
// // // //           return const Scaffold(
// // // //             body: Center(child: CircularProgressIndicator()),
// // // //           );
// // // //         }

// // // //         final user = snapshot.data;

// // // //         // If no user logged in, show login screen
// // // //         if (user == null) return const LoginScreen();

// // // //         final lastSignIn = user.metadata.lastSignInTime ?? DateTime.now();
// // // //         final daysDiff = DateTime.now().difference(lastSignIn).inDays;

// // // //         // Debug-only log for last sign-in time
// // // //         if (kDebugMode) {
// // // //           print("User last signed in: ${user.metadata.lastSignInTime}");
// // // //         }

// // // //         // If user session is expired, sign out asynchronously and show login
// // // //         if (daysDiff > maxDaysLoggedIn) {
// // // //           Future.microtask(() => FirebaseAuth.instance.signOut());
// // // //           return const LoginScreen();
// // // //         }

// // // //         // Before handing over to UserRouter, we need to ensure we have the user's role.
// // // //         // We prefer custom claims (idTokenResult.claims.roles) because they avoid an extra Firestore read.
// // // //         // If claims are missing we fallback to Firestore.
// // // //         // If user has multiple roles, show chooser dialog and store selection in SessionManager.currentRole.

// // // //         return FutureBuilder<Widget>(
// // // //           future: () async {
// // // //             try {
// // // //               final idTokenResult = await user.getIdTokenResult(true);
// // // //               final claims = idTokenResult.claims ?? {};

// // // //               List<String> rolesFromClaims = [];
// // // //               if (claims.containsKey('roles') && claims['roles'] is Map) {
// // // //                 // custom claims store roles as a map: { roles: { admin: true, teacher: true } }
// // // //                 final Map rolesMap = claims['roles'] as Map;
// // // //                 rolesFromClaims = rolesMap.keys
// // // //                     .where((k) => rolesMap[k] == true)
// // // //                     .map((e) => e.toString())
// // // //                     .toList();
// // // //               }

// // // //               List<String> roles = rolesFromClaims;

// // // //               // Fallback: read roles from Firestore if claims are empty
// // // //               final userDocRef =
// // // //                   FirebaseFirestore.instance.collection('users').doc(user.uid);
// // // //               final doc = await userDocRef.get();

// // // //               if (roles.isEmpty && doc.exists) {
// // // //                 final data = doc.data()!;
// // // //                 final fsRoles =
// // // //                     (data['roles'] as List<dynamic>?)?.cast<String>() ?? [];
// // // //                 roles = fsRoles;
// // // //               }

// // // //               // 🔹 If user doc doesn't exist, create guest user
// // // //               if (roles.isEmpty) {
// // // //                 await userDocRef.set({
// // // //                   'uid': user.uid,
// // // //                   'email': user.email,
// // // //                   'name': user.displayName ?? 'Guest',
// // // //                   'roles': ['guest'],
// // // //                   'createdAt': FieldValue.serverTimestamp(),
// // // //                 });
// // // //                 roles = ['guest'];
// // // //               }

// // // //               // If multiple roles, show chooser and set SessionManager.currentRole
// // // //               if (roles.length > 1) {
// // // //                 final chosen = await showDialog<String>(
// // // //                   context: ctx, // ✅ fixed context
// // // //                   builder: (_) => ChooseRoleDialog(roles: roles),
// // // //                 );
// // // //                 SessionManager.currentRole = chosen ?? roles.first;
// // // //               } else {
// // // //                 SessionManager.currentRole = roles.first;
// // // //               }

// // // //               // 🔹 Redirect guest users immediately to guest dashboard
// // // //               if (SessionManager.currentRole == 'guest') {
// // // //                 return const NotRegisteredScreen(); // or GuestDashboard()
// // // //               }

// // // //               // Now call existing UserRouter logic
// // // //               return await getDashboardForUser(user.email ?? "");
// // // //             } catch (e) {
// // // //               // bubble up to FutureBuilder's error handling
// // // //               rethrow;
// // // //             }
// // // //           }(),
// // // //           builder: (ctx, snap) {
// // // //             if (snap.connectionState == ConnectionState.waiting) {
// // // //               return const Scaffold(
// // // //                 body: Center(child: CircularProgressIndicator()),
// // // //               );
// // // //             }

// // // //             if (snap.hasError) {
// // // //               // Handle errors gracefully with your custom error dialog
// // // //               Future.microtask(() => showError(ctx, snap.error!)); // snap.stackTrace));
// // // //               return const Scaffold(
// // // //                 body: Center(child: Text('Something went wrong.')),
// // // //               );
// // // //             }

// // // //             if (!snap.hasData) {
// // // //               // Fallback loading state (should rarely occur)
// // // //               return const Scaffold(
// // // //                 body: Center(child: CircularProgressIndicator()),
// // // //               );
// // // //             }

// // // //             // Return the dashboard widget determined by UserRouter
// // // //             return snap.data!;
// // // //           },
// // // //         );
// // // //       },
// // // //     );
// // // //   }
// // // // }

// // // // // // AuthGate listens for auth changes, checks session expiration.
// // // // // // If expired, signs out asynchronously (avoids build-time side effects).
// // // // // // If valid, hands off to getDashboardForUser (UserRouter) for role-based routing.
// // // // // // Uses your custom showError utility to handle loading errors gracefully.
// // // // // // Debug-only prints wrapped with kDebugMode for clean production builds.

// // // // // import 'package:coursebuddy/screens/login.dart';
// // // // // import 'package:coursebuddy/services/user_router.dart';
// // // // // import 'package:coursebuddy/widgets/error_dialog.dart'; // your custom showError function
// // // // // import 'package:coursebuddy/screens/admin/choose_role_dialog.dart';
// // // // // import 'package:coursebuddy/services/session_manager.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:firebase_auth/firebase_auth.dart';
// // // // // import 'package:flutter/foundation.dart';
// // // // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // // // class AuthGate extends StatelessWidget {
// // // // //   const AuthGate({super.key});

// // // // //   // Max days allowed since last sign-in before forcing logout
// // // // //   static const int maxDaysLoggedIn = 7;

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return StreamBuilder<User?>(
// // // // //       stream: FirebaseAuth.instance.authStateChanges(),
// // // // //       builder: (ctx, snapshot) {
// // // // //         // Show loading indicator while waiting for auth state
// // // // //         if (snapshot.connectionState == ConnectionState.waiting) {
// // // // //           return const Scaffold(
// // // // //             body: Center(child: CircularProgressIndicator()),
// // // // //           );
// // // // //         }

// // // // //         final user = snapshot.data;

// // // // //         // If no user logged in, show login screen
// // // // //         if (user == null) return const LoginScreen();

// // // // //         final lastSignIn = user.metadata.lastSignInTime ?? DateTime.now();
// // // // //         final daysDiff = DateTime.now().difference(lastSignIn).inDays;

// // // // //         // Debug-only log for last sign-in time
// // // // //         if (kDebugMode) {
// // // // //           print("User last signed in: ${user.metadata.lastSignInTime}");
// // // // //         }

// // // // //         // If user session is expired, sign out asynchronously and show login
// // // // //         if (daysDiff > maxDaysLoggedIn) {
// // // // //           Future.microtask(() => FirebaseAuth.instance.signOut());
// // // // //           return const LoginScreen();
// // // // //         }

// // // // //         // Before handing over to UserRouter, we need to ensure we have the user's role.
// // // // //         // We prefer custom claims (idTokenResult.claims.roles) because they avoid an extra Firestore read.
// // // // //         // If claims are missing we fallback to Firestore.
// // // // //         // If user has multiple roles, show chooser dialog and store selection in SessionManager.currentRole.

// // // // //         return FutureBuilder<Widget>(
// // // // //           future: () async {
// // // // //             try {
// // // // //               // Force-refresh token to get most recent custom claims (e.g., after createUser setCustomUserClaims)
// // // // //               final idTokenResult = await user.getIdTokenResult(true);
// // // // //               final claims = idTokenResult.claims ?? {};

// // // // //               List<String> rolesFromClaims = [];
// // // // //               if (claims.containsKey('roles') && claims['roles'] is Map) {
// // // // //                 // custom claims store roles as a map: { roles: { admin: true, teacher: true } }
// // // // //                 final Map rolesMap = claims['roles'] as Map;
// // // // //                 rolesFromClaims = rolesMap.keys
// // // // //                     .where((k) => rolesMap[k] == true)
// // // // //                     .map((e) => e.toString())
// // // // //                     .toList();
// // // // //               }

// // // // //               List<String> roles = rolesFromClaims;

// // // // //               // Fallback: read roles from Firestore if claims are empty
// // // // //               if (roles.isEmpty) {
// // // // //                 final doc = await FirebaseFirestore.instance
// // // // //                     .collection('users')
// // // // //                     .doc(user.uid)
// // // // //                     .get();
// // // // //                 if (doc.exists) {
// // // // //                   final data = doc.data()!;
// // // // //                   final fsRoles =
// // // // //                       (data['roles'] as List<dynamic>?)?.cast<String>() ?? [];
// // // // //                   roles = fsRoles;
// // // // //                 }
// // // // //               }

// // // // //               // If still empty, default to 'student'
// // // // //               if (roles.isEmpty) {
// // // // //                 roles = ['student'];
// // // // //               }

// // // // //               // If multiple roles, show chooser and set SessionManager.currentRole
// // // // //               if (roles.length > 1) {
// // // // //                 final chosen = await showDialog<String>(
// // // // //                   context: ctx, // ✅ fixed here
// // // // //                   builder: (_) => ChooseRoleDialog(roles: roles),
// // // // //                 );
// // // // //                 SessionManager.currentRole = chosen ?? roles.first;
// // // // //               } else {
// // // // //                 SessionManager.currentRole = roles.first;
// // // // //               }

// // // // //               // Now call existing UserRouter logic. Note: UserRouter should read SessionManager.currentRole
// // // // //               // (no signature change required here). getDashboardForUser still receives email like before.
// // // // //               return await getDashboardForUser(user.email ?? "");
// // // // //             } catch (e) {
// // // // //               // bubble up to FutureBuilder's error handling
// // // // //               rethrow;
// // // // //             }
// // // // //           }(),
// // // // //           builder: (ctx, snap) {
// // // // //             if (snap.connectionState == ConnectionState.waiting) {
// // // // //               return const Scaffold(
// // // // //                 body: Center(child: CircularProgressIndicator()),
// // // // //               );
// // // // //             }

// // // // //             if (snap.hasError) {
// // // // //               // Handle errors gracefully with your custom error dialog
// // // // //               Future.microtask(() => showError(ctx, snap.error!)); // snap.stackTrace));
// // // // //               return const Scaffold(
// // // // //                 body: Center(child: Text('Something went wrong.')),
// // // // //               );
// // // // //             }

// // // // //             if (!snap.hasData) {
// // // // //               // Fallback loading state (should rarely occur)
// // // // //               return const Scaffold(
// // // // //                 body: Center(child: CircularProgressIndicator()),
// // // // //               );
// // // // //             }

// // // // //             // Return the dashboard widget determined by UserRouter
// // // // //             return snap.data!;
// // // // //           },
// // // // //         );
// // // // //       },
// // // // //     );
// // // // //   }
// // // // // }
