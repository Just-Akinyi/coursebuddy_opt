import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursebuddy/constants/app_theme.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  Future<void> _setRole(String uid, String role, {String? courseId}) async {
    try {
      final updateData = {
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (role == "student") {
        if (courseId == null) return; // 🔹 don't update until a course is chosen
        updateData['courseId'] = courseId;
      }

      await usersRef.doc(uid).update(updateData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error setting role: $e")),
        );
      }
    }
  }

  void _chooseCourseDialog(String uid) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Assign Course"),
          content: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('courses').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final courses = snap.data!.docs;
              return DropdownButtonFormField<String>(
                hint: const Text("Select course"),
                items: courses.map((c) {
                  final cData = c.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: c.id,
                    child: Text(cData['name'] ?? c.id),
                  );
                }).toList(),
                onChanged: (val) async {
                  if (val != null) {
                    await _setRole(uid, "student", courseId: val);
                    
                    if (mounted) Navigator.pop(context);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final docs = snap.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final email = data['email'] ?? 'unknown';
              final uid = doc.id;
              final role = data['role'] ?? 'guest';
              final courseId = data['courseId'];

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(email),
                subtitle: Text("UID: $uid\nRole: $role"
                    "${role == "student" && courseId != null ? "\nCourse: $courseId" : ""}"),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (choice) async {
                    if (choice == "student") {
                      _chooseCourseDialog(uid); // 🔹 force course selection
                    } else {
                      await _setRole(uid, choice);
                    }
                  },
                  itemBuilder: (_) => [
                    for (final r in [
                      'student',
                      'teacher',
                      'parent',
                      'admin',
                      'guest'
                    ])
                      PopupMenuItem(value: r, child: Text('Set role: $r')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}



// user_list_screen.dart
// Screen: User List (Admin)
// - Shows all users from `users` collection.
// - Each user document has a single `role` field (string).
// - Admin can set/overwrite the role.
// - No status field used.

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:coursebuddy/constants/app_theme.dart';

// class UserListScreen extends StatefulWidget {
//   const UserListScreen({super.key});

//   @override
//   State<UserListScreen> createState() => _UserListScreenState();
// }

// class _UserListScreenState extends State<UserListScreen> {
//   final CollectionReference usersRef =
//       FirebaseFirestore.instance.collection('users');

//   Future<void> _setRole(String uid, String role) async {
//     try {
//       await usersRef.doc(uid).update({
//         'role': role,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error setting role: $e")),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("All Users"),
//         backgroundColor: AppTheme.primaryColor,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: usersRef.orderBy('createdAt', descending: true).snapshots(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snap.hasError) {
//             return Center(child: Text("Error: ${snap.error}"));
//           }
//           if (!snap.hasData || snap.data!.docs.isEmpty) {
//             return const Center(child: Text("No users found"));
//           }

//           final docs = snap.data!.docs;

//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, i) {
//               final doc = docs[i];
//               final data = doc.data() as Map<String, dynamic>;
//               final email = data['email'] ?? 'unknown';
//               final uid = doc.id;
//               final role = data['role'] ?? 'guest';

//               return ListTile(
//                 leading: const Icon(Icons.person),
//                 title: Text(email),
//                 subtitle: Text('UID: $uid\nRole: $role'),
//                 isThreeLine: true,
//                 trailing: PopupMenuButton<String>(
//                   onSelected: (choice) async {
//                     await _setRole(uid, choice);
//                   },
//                   itemBuilder: (_) => [
//                     for (final r in ['student', 'teacher', 'parent', 'admin', 'guest'])
//                       PopupMenuItem(value: r, child: Text('Set role: $r')),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// //  LATER: make the role list (student, teacher, parent, admin, guest) configurable from a constant file so you don’t repeat it in multiple screens
// // user_list_screen.dart
// // Screen: User List (Admin)
// // - Shows all users from `users` collection.
// // - Each user document may have `roles` (array). A user is shown under every role they have.
// // - Admin can add/remove roles (role changes update the `roles` array).
// // - No status field used.

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:coursebuddy/constants/app_theme.dart';
// // import 'package:coursebuddy/widgets/status.dart'; // optional: reuse badge if you want

// class UserListScreen extends StatefulWidget {
//   const UserListScreen({super.key});

//   @override
//   State<UserListScreen> createState() => _UserListScreenState();
// }

// class _UserListScreenState extends State<UserListScreen> {
//   final CollectionReference usersRef =
//       FirebaseFirestore.instance.collection('users');

//   Future<void> _addRole(String uid, String role) async {
//     try {
//       await usersRef.doc(uid).update({
//         'roles': [role], 
//   'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error adding role: $e")),
//         );
//       }
//     }
//   }

//   Future<void> _removeRole(String uid, String role) async {
//     try {
//       await usersRef.doc(uid).update({
//         'roles':[role],
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error removing role: $e")),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("All Users"),
//         backgroundColor: AppTheme.primaryColor,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             tooltip: 'Add user',
//             onPressed: () async {
//               try {
//                 final added =
//                     await Navigator.pushNamed(context, '/admin/add-user');
//                 if (added == true && context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('User added')),
//                   );
//                 }
//               } catch (e) {
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Error: $e")),
//                   );
//                 }
//               }
//             },
//           )
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: usersRef.orderBy('createdAt', descending: true).snapshots(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snap.hasError) {
//             return Center(child: Text("Error: ${snap.error}"));
//           }
//           if (!snap.hasData || snap.data!.docs.isEmpty) {
//             return const Center(child: Text("No users found"));
//           }

//           final docs = snap.data!.docs;
//           // build mapping role -> list of docs
//           final Map<String, List<QueryDocumentSnapshot>> byRole = {};
//           for (final doc in docs) {
//             final data = doc.data() as Map<String, dynamic>;
//             final roles =
//                 (data['roles'] as List<dynamic>?)?.cast<String>() ?? ['guest'];
//             for (final r in roles) {
//               byRole.putIfAbsent(r, () => []);
//               byRole[r]!.add(doc);
//             }
//           }

//           final roleKeys = byRole.keys.toList()..sort();

//           return ListView.builder(
//             itemCount: roleKeys.length,
//             itemBuilder: (context, i) {
//               final role = roleKeys[i];
//               final users = byRole[role]!;
//               return ExpansionTile(
//                 title: Text(
//                   role.toUpperCase(),
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 children: users.map((userDoc) {
//                   final data = userDoc.data() as Map<String, dynamic>;
//                   final email = data['email'] ?? 'unknown';
//                   final uid = userDoc.id;
//                   final roles =
//                       (data['roles'] as List<dynamic>?)?.cast<String>() ?? [];

//                   return ListTile(
//                     leading: const Icon(Icons.person),
//                     title: Text(email),
//                     subtitle: Text('UID: $uid\nRoles: ${roles.join(', ')}'),
//                     isThreeLine: true,
//                     trailing: PopupMenuButton<String>(
//                       onSelected: (choice) async {
//                         if (choice == 'remove_role') {
//                           await _removeRole(uid, role);
//                         } else if (choice == 'add_role') {
//                           showModalBottomSheet(
//                             context: context,
//                             builder: (_) {
//                               return Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: ['student', 'teacher', 'parent', 'admin', 'guest']
//                                     .where((r) => !roles.contains(r))
//                                     .map((r) => ListTile(
//                                           title: Text('Add role: $r'),
//                                           onTap: () {
//                                             Navigator.pop(context);
//                                             _addRole(uid, r);
//                                           },
//                                         ))
//                                     .toList(),
//                               );
//                             },
//                           );
//                         }
//                       },
//                       itemBuilder: (_) => [
//                         const PopupMenuItem(
//                             value: 'add_role', child: Text('Add role')),
//                         PopupMenuItem(
//                             value: 'remove_role',
//                             child: Text('Remove role: $role')),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


// // // user_list_screen.dart
// // // Screen: User List (Admin)
// // // - Shows all users from `users` collection.
// // // - Each user document may have `roles` (array). A user is shown under every role they have.
// // // - Admin can add/remove roles (role changes update the `roles` array).
// // // - No status field used.

// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:coursebuddy/constants/app_theme.dart';
// // // import 'package:coursebuddy/widgets/status.dart'; // optional: reuse badge if you want

// // class UserListScreen extends StatefulWidget {
// //   const UserListScreen({super.key});

// //   @override
// //   State<UserListScreen> createState() => _UserListScreenState();
// // }

// // class _UserListScreenState extends State<UserListScreen> {
// //   final CollectionReference usersRef =
// //       FirebaseFirestore.instance.collection('users');

// //   Future<void> _addRole(String uid, String role) async {
// //     await usersRef.doc(uid).update({
// //       'roles': FieldValue.arrayUnion([role]),
// //       'updatedAt': FieldValue.serverTimestamp(),
// //     });
// //   }

// //   Future<void> _removeRole(String uid, String role) async {
// //     await usersRef.doc(uid).update({
// //       'roles': FieldValue.arrayRemove([role]),
// //       'updatedAt': FieldValue.serverTimestamp(),
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("All Users"),
// //         backgroundColor: AppTheme.primaryColor,
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.add),
// //             tooltip: 'Add user',
// //             onPressed: () async {
// //               final added = await Navigator.pushNamed(context, '/admin/add-user');
// //               if (added == true && context.mounted) {
// //                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User added')));
// //               }
// //             },
// //           )
// //         ],
// //       ),
// //       body: StreamBuilder<QuerySnapshot>(
// //         stream: usersRef.orderBy('createdAt', descending: true).snapshots(),
// //         builder: (context, snap) {
// //           if (snap.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }
// //           if (!snap.hasData || snap.data!.docs.isEmpty) {
// //             return const Center(child: Text("No users found"));
// //           }

// //           final docs = snap.data!.docs;
// //           // build mapping role -> list of docs
// //           final Map<String, List<QueryDocumentSnapshot>> byRole = {};
// //           for (final doc in docs) {
// //             final data = doc.data() as Map<String, dynamic>;
// //             final roles = (data['roles'] as List<dynamic>?)?.cast<String>() ?? ['guest'];
// //             for (final r in roles) {
// //               byRole.putIfAbsent(r, () => []);
// //               byRole[r]!.add(doc);
// //             }
// //           }

// //           final roleKeys = byRole.keys.toList()..sort();

// //           return ListView.builder(
// //             itemCount: roleKeys.length,
// //             itemBuilder: (context, i) {
// //               final role = roleKeys[i];
// //               final users = byRole[role]!;
// //               return ExpansionTile(
// //                 title: Text(role.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
// //                 children: users.map((userDoc) {
// //                   final data = userDoc.data() as Map<String, dynamic>;
// //                   final email = data['email'] ?? 'unknown';
// //                   final uid = userDoc.id;
// //                   final roles = (data['roles'] as List<dynamic>?)?.cast<String>() ?? [];

// //                   return ListTile(
// //                     leading: const Icon(Icons.person),
// //                     title: Text(email),
// //                     subtitle: Text('UID: $uid\nRoles: ${roles.join(', ')}'),
// //                     isThreeLine: true,
// //                     trailing: PopupMenuButton<String>(
// //                       onSelected: (choice) async {
// //                         if (choice == 'remove_role') {
// //                           await _removeRole(uid, role);
// //                         } else if (choice == 'add_role') {
// //                           // quick add demo: toggle a role menu
// //                           showModalBottomSheet(
// //                             context: context,
// //                             builder: (_) {
// //                               return Column(
// //                                 mainAxisSize: MainAxisSize.min,
// //                                 children: ['student', 'teacher', 'parent', 'admin', 'guest']
// //                                     .where((r) => !roles.contains(r))
// //                                     .map((r) => ListTile(
// //                                           title: Text('Add role: $r'),
// //                                           onTap: () {
// //                                             Navigator.pop(context);
// //                                             _addRole(uid, r);
// //                                           },
// //                                         ))
// //                                     .toList(),
// //                               );
// //                             },
// //                           );
// //                         }
// //                       },
// //                       itemBuilder: (_) => [
// //                         const PopupMenuItem(value: 'add_role', child: Text('Add role')),
// //                         PopupMenuItem(value: 'remove_role', child: Text('Remove role: $role')),
// //                       ],
// //                     ),
// //                   );
// //                 }).toList(),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
