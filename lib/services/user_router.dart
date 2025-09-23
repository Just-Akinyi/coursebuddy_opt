// getDashboardForUser.dart
//
// Determines and returns the appropriate dashboard widget for the current user
// based on their single role stored in Firestore and persisted with RoleManager.
// - Creates a guest user doc if none exists
// - Logs guest visits once per day
// - Supports roles: student, teacher, admin, parent (optional), and guest
// - Persists role locally, but Firestore is always the source of truth

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/guest_user.dart';
// import 'package:coursebuddy/screens/parent_dashboard.dart';
import 'package:coursebuddy/screens/student/student_dashboard.dart';
import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
import 'package:coursebuddy/screens/admin/admin_dashboard.dart';
import 'package:coursebuddy/constants/user_roles.dart';
import 'role_manager.dart';

Future<Widget> getDashboardForUser(String email) async {
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;
  final uid = user.uid;
  final docRef = firestore.collection('users').doc(uid);

  final doc = await docRef.get();

  if (doc.exists) {
    final data = doc.data()!;
    final String role = (data['role'] ?? UserRoles.guest).toString();

    // 🔹 Debug print
    if (kDebugMode) {
      print("🔍 Firestore role for $email (uid=$uid): $role");
    }

    // 🔹 Firestore role is always source of truth
    await RoleManager.saveRole(role);

    if (role == UserRoles.guest) {
      if (kDebugMode) {
        print("➡️ Routing to NotRegisteredScreen (guest)");
      }
      return const NotRegisteredScreen();
    }

    switch (role) {
      case UserRoles.student:
        if (kDebugMode) {
          print("➡️ Routing to StudentDashboard");
        }
        return StudentDashboard(
          courseId: data['courseId'] ?? 'default_course',
          status: 'Active',
        );
      // case UserRoles.parent:
      //   print("➡️ Routing to ParentDashboard");
      //   return ParentDashboard();
      case UserRoles.teacher:
        if (kDebugMode) {
          print("➡️ Routing to TeacherDashboard");
        }
        return const TeacherDashboard();
      case UserRoles.admin:
        if (kDebugMode) {
          print("➡️ Routing to AdminDashboard");
        }
        return const AdminDashboard();
      default:
        if (kDebugMode) {
          print("⚠️ Unknown role: $role → NotRegisteredScreen");
        }
        return const NotRegisteredScreen();
    }
  }

  // 🔹 New user → create guest record
  if (kDebugMode) {
    print("🆕 No Firestore doc found. Creating guest record for $email (uid=$uid)");
  }
  await docRef.set({
    'uid': uid,
    'email': email,
    'name': user.displayName ?? 'Guest',
    'role': UserRoles.guest,
    'createdAt': FieldValue.serverTimestamp(),
  });

  // 🔹 Log guest visit once per day
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final existingVisit = await firestore
      .collection('guest_visits')
      .where('uid', isEqualTo: uid)
      .where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .get();

  if (existingVisit.docs.isEmpty) {
    await firestore.collection('guest_visits').add({
      'uid': uid,
      'email': email,
      'timestamp': FieldValue.serverTimestamp(),
    });
    if (kDebugMode) {
      print("📌 Guest visit logged for $email");
    }
  }

  return const NotRegisteredScreen();
}


// // getDashboardForUser.dart
// //
// // Determines and returns the appropriate dashboard widget for the current user
// // based on their single role stored in Firestore and persisted with RoleManager.
// // - Creates a guest user doc if none exists
// // - Logs guest visits once per day
// // - Supports roles: student, teacher, admin, parent (optional), and guest
// // - Persists role locally, but Firestore is always the source of truth

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../screens/guest_user.dart';
// // import 'package:coursebuddy/screens/parent_dashboard.dart';
// import 'package:coursebuddy/screens/student/student_dashboard.dart';
// import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
// import 'package:coursebuddy/screens/admin/admin_dashboard.dart';
// import 'package:coursebuddy/constants/user_roles.dart';
// import 'role_manager.dart';

// Future<Widget> getDashboardForUser(String email) async {
//   final firestore = FirebaseFirestore.instance;
//   final user = FirebaseAuth.instance.currentUser!;
//   final uid = user.uid;
//   final docRef = firestore.collection('users').doc(uid);

//   final doc = await docRef.get();

//   if (doc.exists) {
//     final data = doc.data()!;
//     final String role = (data['role'] ?? UserRoles.guest).toString();

//     // 🔹 Firestore role is always source of truth
//     await RoleManager.saveRole(role);

//     if (role == UserRoles.guest) return const NotRegisteredScreen();

//     switch (role) {
//       case UserRoles.student:
//         return StudentDashboard(
//           courseId: data['courseId'] ?? 'default_course',
//           status: 'Active',
//         );
//       // case UserRoles.parent:
//       //   return ParentDashboard();
//       case UserRoles.teacher:
//         return const TeacherDashboard();
//       case UserRoles.admin:
//         return const AdminDashboard();
//       default:
//         return const NotRegisteredScreen();
//     }
//   }

//   // 🔹 New user → create guest record
//   await docRef.set({
//     'uid': uid,
//     'email': email,
//     'name': user.displayName ?? 'Guest',
//     'role': UserRoles.guest,
//     'createdAt': FieldValue.serverTimestamp(),
//   });

//   // 🔹 Log guest visit once per day
//   final today = DateTime.now();
//   final startOfDay = DateTime(today.year, today.month, today.day);
//   final existingVisit = await firestore
//       .collection('guest_visits')
//       .where('uid', isEqualTo: uid)
//       .where('timestamp',
//           isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
//       .get();

//   if (existingVisit.docs.isEmpty) {
//     await firestore.collection('guest_visits').add({
//       'uid': uid,
//       'email': email,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }

//   return const NotRegisteredScreen();
// }

// // getDashboardForUser.dart
// //
// // Determines and returns the appropriate dashboard widget for the current user
// // based on their single role stored in Firestore and persisted with RoleManager.
// // - Creates a guest user doc if none exists
// // - Logs guest visits once per day
// // - Supports roles: student, teacher, admin, parent (optional), and guest
// // - Persists role selection across sessions

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../screens/guest_user.dart';
// // import 'package:coursebuddy/screens/parent_dashboard.dart';
// import 'package:coursebuddy/screens/student/student_dashboard.dart';
// import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
// import 'package:coursebuddy/screens/admin/admin_dashboard.dart';
// import 'package:coursebuddy/constants/user_roles.dart';
// import 'package:coursebuddy/services/session_manager.dart';
// import 'role_manager.dart';

// Future<Widget> getDashboardForUser(String email) async {
//   final firestore = FirebaseFirestore.instance;
//   final user = FirebaseAuth.instance.currentUser!;
//   final uid = user.uid;
//   final docRef = firestore.collection('users').doc(uid);

//   final doc = await docRef.get();

//   if (doc.exists) {
//     final data = doc.data()!;
//     final String role = (data['role'] ?? UserRoles.guest).toString();

//     // Load persisted role first
//     String? persistedRole = await RoleManager.getRole();
//     final effectiveRole = SessionManager.currentRole ?? persistedRole ?? role;

//     // Persist the role if first time
//     if (persistedRole == null) await RoleManager.saveRole(effectiveRole);

//     if (effectiveRole == UserRoles.guest) return const NotRegisteredScreen();

//     switch (effectiveRole) {
//       case UserRoles.student:
//         return StudentDashboard(
//           courseId: data['courseId'] ?? 'default_course',
//           status: 'Active',
//         );
//       // case UserRoles.parent:
//       //   return ParentDashboard();
//       case UserRoles.teacher:
//         return const TeacherDashboard();
//       case UserRoles.admin:
//         return const AdminDashboard();
//       default:
//         return const NotRegisteredScreen();
//     }
//   }

//   // 🔹 New user → create guest record
//   await docRef.set({
//     'uid': uid,
//     'email': email,
//     'name': user.displayName ?? 'Guest',
//     'role': UserRoles.guest,
//     'createdAt': FieldValue.serverTimestamp(),
//   });

//   // 🔹 Log guest visit once per day
//   final today = DateTime.now();
//   final startOfDay = DateTime(today.year, today.month, today.day);
//   final existingVisit = await firestore
//       .collection('guest_visits')
//       .where('uid', isEqualTo: uid)
//       .where('timestamp',
//           isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
//       .get();

//   if (existingVisit.docs.isEmpty) {
//     await firestore.collection('guest_visits').add({
//       'uid': uid,
//       'email': email,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }

//   return const NotRegisteredScreen();
// }


// // // getDashboardForUser.dart
// // //
// // // Determines and returns the appropriate dashboard widget for the current user
// // // based on their single role stored in Firestore and persisted with RoleManager.
// // // - Creates a guest user doc if none exists
// // // - Logs guest visits once per day
// // // - Supports roles: student, teacher, admin, parent (optional), and guest
// // // - Persists role selection across sessions

// //MULTIROLE
// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import '../screens/guest_user.dart';
// // // import 'package:coursebuddy/screens/parent_dashboard.dart';
// // import 'package:coursebuddy/screens/student/student_dashboard.dart';
// // import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
// // import 'package:coursebuddy/screens/admin/admin_dashboard.dart';
// // import 'package:coursebuddy/constants/user_roles.dart';
// // import 'package:coursebuddy/services/session_manager.dart';
// // import 'role_manager.dart';

// // Future<Widget> getDashboardForUser(String email) async {
// //   final firestore = FirebaseFirestore.instance;
// //   final user = FirebaseAuth.instance.currentUser!;
// //   final uid = user.uid;
// //   final docRef = firestore.collection('users').doc(uid);

// //   final doc = await docRef.get();

// //   if (doc.exists) {
// //     final data = doc.data()!;
// //     final String role = data['role'] ?? UserRoles.guest;

// //     // Load persisted role first
// //     String? persistedRole = await RoleManager.getRole();
// //     final effectiveRole = SessionManager.currentRole ?? persistedRole ?? role;

// //     // Persist the role if first time
// //     if (persistedRole == null) await RoleManager.saveRole(effectiveRole);

// //     if (effectiveRole == UserRoles.guest) return const NotRegisteredScreen();

// //     final dashboardMap = <String, Widget Function(Map<String, dynamic>)>{
// //       UserRoles.student: (data) => StudentDashboard(
// //             courseId: data['courseId'] ?? 'default_course',
// //             status: 'Active',
// //           ),
// //       // UserRoles.parent: (_) => ParentDashboard(),
// //       UserRoles.teacher: (_) => const TeacherDashboard(),
// //       UserRoles.admin: (_) => const AdminDashboard(),
// //     };

// //     return dashboardMap[effectiveRole]?.call(data) ??
// //         const NotRegisteredScreen();
// //   }

// //   // New user → create guest record
// //   await docRef.set({
// //     'uid': uid,
// //     'email': email,
// //     'name': user.displayName ?? 'Guest',
// //     'role': UserRoles.guest,
// //     'createdAt': FieldValue.serverTimestamp(),
// //   });

// //   // Log guest visit once per day
// //   final today = DateTime.now();
// //   final startOfDay = DateTime(today.year, today.month, today.day);
// //   final existingVisit = await firestore
// //       .collection('guest_visits')
// //       .where('uid', isEqualTo: uid)
// //       .where('timestamp',
// //           isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
// //       .get();

// //   if (existingVisit.docs.isEmpty) {
// //     await firestore.collection('guest_visits').add({
// //       'uid': uid,
// //       'email': email,
// //       'timestamp': FieldValue.serverTimestamp(),
// //     });
// //   }

// //   return const NotRegisteredScreen();
// // }

// // // getDashboardForUser.dart
// // //
// // // Determines and returns the appropriate dashboard widget for the current user
// // // based on their role stored in Firestore and persisted with RoleManager.
// // // - Creates a guest user doc if none exists
// // // - Logs guest visits once per day
// // // - Supports roles: student, teacher, admin, parent, and guest
// // // - Persists role selection across sessions (single role only)

// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import '../screens/guest_user.dart';
// // // import 'package:coursebuddy/screens/parent_dashboard.dart';
// // import 'package:coursebuddy/screens/student/student_dashboard.dart';
// // import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
// // import 'package:coursebuddy/screens/admin/admin_dashboard.dart';
// // import 'package:coursebuddy/constants/user_roles.dart';
// // import 'package:coursebuddy/services/session_manager.dart';
// // import 'role_manager.dart'; // NEW

// // Future<Widget> getDashboardForUser(String email) async {
// //   final firestore = FirebaseFirestore.instance;
// //   final user = FirebaseAuth.instance.currentUser!;
// //   final uid = user.uid;
// //   final docRef = firestore.collection('users').doc(uid);

// //   final doc = await docRef.get();

// //   if (doc.exists) {
// //     final data = doc.data()!;
// //     final String role = data['role'] ?? UserRoles.guest;

// //     // Load persisted role first
// //     String? persistedRole = await RoleManager.getRole();
// //     final effectiveRole =
// //         SessionManager.currentRole ?? persistedRole ?? role;

// //     // Persist the role if first time
// //     if (persistedRole == null) await RoleManager.saveRole(effectiveRole);

// //     if (effectiveRole == UserRoles.guest) return const NotRegisteredScreen();

// //     final dashboardMap = <String, Widget Function(Map<String, dynamic>)>{
// //       UserRoles.student: (data) =>
// //           StudentDashboard(courseId: data['courseId'] ?? 'default_course', status: 'Active'),
// //       // UserRoles.parent: (_) => ParentDashboard(),
// //       UserRoles.teacher: (_) => const TeacherDashboard(),
// //       UserRoles.admin: (_) => const AdminDashboard(), // ✅ AdminDashboard integrated
// //     };

// //     return dashboardMap[effectiveRole]?.call(data) ?? const NotRegisteredScreen();
// //   }

// //   // New user → create guest
// //   await docRef.set({
// //     'uid': uid,
// //     'email': email,
// //     'name': user.displayName ?? 'Guest',
// //     'role': UserRoles.guest,
// //     'createdAt': FieldValue.serverTimestamp(),
// //   });

// //   // Log guest visit once per day
// //   final today = DateTime.now();
// //   final startOfDay = DateTime(today.year, today.month, today.day);
// //   final existingVisit = await firestore
// //       .collection('guest_visits')
// //       .where('uid', isEqualTo: uid)
// //       .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
// //       .get();

// //   if (existingVisit.docs.isEmpty) {
// //     await firestore.collection('guest_visits').add({
// //       'uid': uid,
// //       'email': email,
// //       'timestamp': FieldValue.serverTimestamp(),
// //     });
// //   }

// //   return const NotRegisteredScreen();
// // }

// // // getDashboardForUser.dart
// // //
// // // Determines and returns the appropriate dashboard widget for the current user
// // // based on their role stored in Firestore and persisted with RoleManager.
// // // - Creates a guest user doc if none exists
// // // - Logs guest visits once per day
// // // - Supports roles: student, teacher, admin, parent, and guest
// // // - Persists multi-role selection across sessions

// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import '../screens/guest_user.dart';
// // // import 'package:coursebuddy/screens/parent_dashboard.dart';
// // import 'package:coursebuddy/screens/student/student_dashboard.dart';
// // import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
// // import 'package:coursebuddy/screens/admin/admin_dashboard.dart';
// // import 'package:coursebuddy/constants/user_roles.dart';
// // import 'package:coursebuddy/services/session_manager.dart';
// // import 'role_manager.dart'; // NEW

// // Future<Widget> getDashboardForUser(String email) async {
// //   final firestore = FirebaseFirestore.instance;
// //   final user = FirebaseAuth.instance.currentUser!;
// //   final uid = user.uid;
// //   final docRef = firestore.collection('users').doc(uid);

// //   final doc = await docRef.get();

// //   if (doc.exists) {
// //     final data = doc.data()!;
// //     final List roles = List<String>.from(data['roles'] ?? []);

// //     // Load persisted role first
// //     String? persistedRole = await RoleManager.getRole();
// //     final role = SessionManager.currentRole ?? persistedRole ?? (roles.isNotEmpty ? roles.first : UserRoles.guest);

// //     // Persist the role if first time
// //     if (persistedRole == null) await RoleManager.saveRole(role);

// //     if (role == UserRoles.guest) return const NotRegisteredScreen();

// //     final dashboardMap = <String, Widget Function(Map<String, dynamic>)>{
// //       UserRoles.student: (data) =>
// //           StudentDashboard(courseId: data['courseId'] ?? 'default_course', status: 'Active'),
// //       // UserRoles.parent: (_) => ParentDashboard(),
// //       UserRoles.teacher: (_) => const TeacherDashboard(),
// //       UserRoles.admin: (_) => const AdminDashboard(), // ✅ AdminDashboard integrated
// //     };

// //     return dashboardMap[role]?.call(data) ?? const NotRegisteredScreen();
// //   }

// //   // New user → create guest
// //   await docRef.set({
// //     'uid': uid,
// //     'email': email,
// //     'name': user.displayName ?? 'Guest',
// //     'roles': [UserRoles.guest],
// //     'createdAt': FieldValue.serverTimestamp(),
// //   });

// //   // Log guest visit once per day
// //   final today = DateTime.now();
// //   final startOfDay = DateTime(today.year, today.month, today.day);
// //   final existingVisit = await firestore
// //       .collection('guest_visits')
// //       .where('uid', isEqualTo: uid)
// //       .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
// //       .get();

// //   if (existingVisit.docs.isEmpty) {
// //     await firestore.collection('guest_visits').add({
// //       'uid': uid,
// //       'email': email,
// //       'timestamp': FieldValue.serverTimestamp(),
// //     });
// //   }

// //   return const NotRegisteredScreen();
// // }

// // // // getDashboardForUser.dart
// // // //
// // // // Determines and returns the appropriate dashboard widget for the current user
// // // // based on their role stored in Firestore and persisted with RoleManager.
// // // // - Creates a guest user doc if none exists
// // // // - Logs guest visits once per day
// // // // - Supports roles: student, teacher, admin, parent, and guest
// // // // - Persists multi-role selection across sessions

// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import '../screens/guest_user.dart';
// // // // import 'package:coursebuddy/screens/parent_dashboard.dart';
// // // import 'package:coursebuddy/screens/student/student_dashboard.dart';
// // // import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
// // // import 'package:coursebuddy/constants/user_roles.dart';
// // // import 'package:coursebuddy/services/session_manager.dart';
// // // import 'role_manager.dart'; // NEW

// // // Future<Widget> getDashboardForUser(String email) async {
// // //   final firestore = FirebaseFirestore.instance;
// // //   final user = FirebaseAuth.instance.currentUser!;
// // //   final uid = user.uid;
// // //   final docRef = firestore.collection('users').doc(uid);

// // //   final doc = await docRef.get();

// // //   if (doc.exists) {
// // //     final data = doc.data()!;
// // //     final List roles = List<String>.from(data['roles'] ?? []);

// // //     // Load persisted role first
// // //     String? persistedRole = await RoleManager.getRole();
// // //     final role = SessionManager.currentRole ?? persistedRole ?? (roles.isNotEmpty ? roles.first : UserRoles.guest);

// // //     // Persist the role if first time
// // //     if (persistedRole == null) await RoleManager.saveRole(role);

// // //     if (role == UserRoles.guest) return const NotRegisteredScreen();

// // //     final dashboardMap = <String, Widget Function(Map<String, dynamic>)>{
// // //       UserRoles.student: (data) =>
// // //           StudentDashboard(courseId: data['courseId'] ?? 'default_course', status: 'Active'),
// // //       // UserRoles.parent: (_) => ParentDashboard(),
// // //       UserRoles.teacher: (_) => const TeacherDashboard(),
// // //       // UserRoles.admin: (_) => AdminDashboard(),
// // //     };

// // //     return dashboardMap[role]?.call(data) ?? const NotRegisteredScreen();
// // //   }

// // //   // New user → create guest
// // //   await docRef.set({
// // //     'uid': uid,
// // //     'email': email,
// // //     'name': user.displayName ?? 'Guest',
// // //     'roles': [UserRoles.guest],
// // //     'createdAt': FieldValue.serverTimestamp(),
// // //   });

// // //   // Log guest visit once per day
// // //   final today = DateTime.now();
// // //   final startOfDay = DateTime(today.year, today.month, today.day);
// // //   final existingVisit = await firestore
// // //       .collection('guest_visits')
// // //       .where('uid', isEqualTo: uid)
// // //       .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
// // //       .get();

// // //   if (existingVisit.docs.isEmpty) {
// // //     await firestore.collection('guest_visits').add({
// // //       'uid': uid,
// // //       'email': email,
// // //       'timestamp': FieldValue.serverTimestamp(),
// // //     });
// // //   }

// // //   return const NotRegisteredScreen();
// // // }
// // // // /// Determines and returns the appropriate dashboard widget for the current user
// // // // /// based on their role stored in Firestore.
// // // // /// If the user document doesn't exist, creates a guest user record,
// // // // /// logs guest visits once daily,
// // // // /// and returns a default "Not Registered" screen.
// // // // /// Supports roles: student, parent, teacher, admin, and guest.

// // // // import 'package:flutter/material.dart';
// // // // import 'package:firebase_auth/firebase_auth.dart';
// // // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // // import '../screens/guest_user.dart';
// // // // // import 'package:coursebuddy/screens/parent_dashboard.dart';
// // // // import 'package:coursebuddy/screens/student/student_dashboard.dart';
// // // // import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
// // // // import 'package:coursebuddy/constants/user_roles.dart'; // your enum class
// // // // import 'package:coursebuddy/services/session_manager.dart';

// // // // Future<Widget> getDashboardForUser(String email) async {
// // // //   final firestore = FirebaseFirestore.instance;
// // // //   final user = FirebaseAuth.instance.currentUser!;
// // // //   final uid = user.uid;
// // // //   final docRef = firestore.collection('users').doc(uid);

// // // //   final doc = await docRef.get();

// // // //   if (doc.exists) {
// // // //     final data = doc.data()!;
// // // //     // 🔑 Use roles array + SessionManager for currentRole
// // // //     final List roles = List<String>.from(data['roles'] ?? []);

// // // //     // 🔹 Default to guest if no currentRole set or empty roles array
// // // //     final role = SessionManager.currentRole ??
// // // //         (roles.isNotEmpty ? roles.first : UserRoles.guest);

// // // //     // 🔹 Guest users always get guest dashboard
// // // //     if (role == UserRoles.guest) {
// // // //       return const NotRegisteredScreen(); // or GuestDashboard()
// // // //     }

// // // //     final dashboardMap = <String, Widget Function(Map<String, dynamic>)>{
// // // //       UserRoles.student: (data) =>
// // // //           StudentDashboard(
// // // //               courseId: data['courseId'] ?? 'default_course',
// // // //               status: 'Active'),
// // // //       // UserRoles.parent: (_) => ParentDashboard(),
// // // //       UserRoles.teacher: (_) => const TeacherDashboard(),
// // // //       // UserRoles.admin: (_) => AdminDashboard(),
// // // //     };

// // // //     // 🔹 Fallback to guest screen if role not recognized
// // // //     return dashboardMap[role]?.call(data) ?? const NotRegisteredScreen();
// // // //   }

// // // //   // User does not exist → create guest user doc
// // // //   await docRef.set({
// // // //     'uid': uid,
// // // //     'email': email,
// // // //     'name': user.displayName ?? 'Guest',
// // // //     'roles': [UserRoles.guest],
// // // //     'createdAt': FieldValue.serverTimestamp(),
// // // //   });

// // // //   // Log guest visit once per day
// // // //   final today = DateTime.now();
// // // //   final startOfDay = DateTime(today.year, today.month, today.day);

// // // //   final existingVisit = await firestore
// // // //       .collection('guest_visits')
// // // //       .where('uid', isEqualTo: uid)
// // // //       .where('timestamp',
// // // //           isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
// // // //       .get();

// // // //   if (existingVisit.docs.isEmpty) {
// // // //     await firestore.collection('guest_visits').add({
// // // //       'uid': uid,
// // // //       'email': email,
// // // //       'timestamp': FieldValue.serverTimestamp(),
// // // //     });
// // // //   }

// // // //   // 🔹 New users without roles always get guest screen
// // // //   return const NotRegisteredScreen();
// // // // }


// // // // // /// Determines and returns the appropriate dashboard widget for the current user
// // // // // /// based on their role stored in Firestore.
// // // // // /// If the user document doesn't exist, creates a guest user record,
// // // // // /// logs guest visits once daily,
// // // // // /// and returns a default "Not Registered" screen.
// // // // // /// Supports roles: student, parent, teacher, admin, and guest.

// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:firebase_auth/firebase_auth.dart';
// // // // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // // // import '../screens/guest_user.dart';
// // // // // // import 'package:coursebuddy/screens/parent_dashboard.dart';
// // // // // import 'package:coursebuddy/screens/student/student_dashboard.dart';
// // // // // import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
// // // // // import 'package:coursebuddy/constants/user_roles.dart'; // your enum class
// // // // // import 'package:coursebuddy/services/session_manager.dart';

// // // // // Future<Widget> getDashboardForUser(String email) async {
// // // // //   final firestore = FirebaseFirestore.instance;
// // // // //   final user = FirebaseAuth.instance.currentUser!;
// // // // //   final uid = user.uid;
// // // // //   final docRef = firestore.collection('users').doc(uid);

// // // // //   final doc = await docRef.get();

// // // // //   if (doc.exists) {
// // // // //     final data = doc.data()!;
// // // // //     // 🔑 Use roles array + SessionManager for currentRole
// // // // //     final List roles = List<String>.from(data['roles'] ?? []);
// // // // //     final role = SessionManager.currentRole ?? (roles.isNotEmpty ? roles.first : UserRoles.guest);

// // // // //     final dashboardMap = <String, Widget Function(Map<String, dynamic>)>{
// // // // //       UserRoles.student: (data) =>
// // // // //           StudentDashboard(
// // // // //               courseId: data['courseId'] ?? 'default_course',
// // // // //               status: 'Active'),
// // // // //       // UserRoles.parent: (_) => ParentDashboard(),
// // // // //       UserRoles.teacher: (_) => const TeacherDashboard(),
// // // // //       // UserRoles.admin: (_) => AdminDashboard(),
// // // // //     };

// // // // //     return dashboardMap[role]?.call(data) ?? const NotRegisteredScreen();
// // // // //   }

// // // // //   // User does not exist → create guest user doc
// // // // //   await docRef.set({
// // // // //     'uid': uid,
// // // // //     'email': email,
// // // // //     'name': user.displayName ?? 'Guest',
// // // // //     'roles': [UserRoles.guest],
// // // // //     'createdAt': FieldValue.serverTimestamp(),
// // // // //   });

// // // // //   // Log guest visit once per day
// // // // //   final today = DateTime.now();
// // // // //   final startOfDay = DateTime(today.year, today.month, today.day);

// // // // //   final existingVisit = await firestore
// // // // //       .collection('guest_visits')
// // // // //       .where('uid', isEqualTo: uid)
// // // // //       .where('timestamp',
// // // // //           isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
// // // // //       .get();

// // // // //   if (existingVisit.docs.isEmpty) {
// // // // //     await firestore.collection('guest_visits').add({
// // // // //       'uid': uid,
// // // // //       'email': email,
// // // // //       'timestamp': FieldValue.serverTimestamp(),
// // // // //     });
// // // // //   }

// // // // //   return const NotRegisteredScreen();
// // // // // }
