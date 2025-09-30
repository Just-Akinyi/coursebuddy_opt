// add_user_screen.dart
// Screen: Admin Add User
// - Calls callable Cloud Function `createUser` to create or fetch a Firebase Auth user by email.
// - Ensures Firestore `users/{uid}` doc exists.
// - If student, also assigns courseId, xp, level, badges.
// - Navigates back with true on success.

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursebuddy/widgets/error_dialog.dart';
import 'package:coursebuddy/constants/app_theme.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _emailController = TextEditingController();
  String _role = 'teacher';
  String? _selectedCourseId;
  bool _loading = false;

  Future<void> _addUser() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required')),
      );
      return;
    }

    if (_role == "student" && _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course for student')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('createUser');
      final result = await callable.call({
        'email': email,
        'requestedRole': _role,
      });

      // result.data should be a map with uid and created boolean
      final data = Map<String, dynamic>.from(result.data as Map);
      final uid = data['uid'] as String;

      // Ensure Firestore users/{uid} exists
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      final baseData = {
        'uid': uid,
        'email': email,
        'name': email.split('@').first, // default, can update later
        'role': _role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_role == "student") {
        baseData.addAll({
          'courseId': _selectedCourseId!,
          'xp': 0,
          'level': 1,
          'badges': [],
        });
      }

      await userRef.set(baseData, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) await showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add User"),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Note'),
                  content: Text(
                    'This will create (or locate) an Auth user by email and add the selected role to their Firestore profile. '
                    'If role = student, you must assign a course. No duplicates will be created if an account already exists.',
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: "teacher", child: Text("Teacher")),
                DropdownMenuItem(value: "parent", child: Text("Parent")),
                DropdownMenuItem(value: "student", child: Text("Student")),
                DropdownMenuItem(value: "admin", child: Text("Admin")),
              ],
              onChanged: (val) => setState(() => _role = val ?? "teacher"),
            ),
            const SizedBox(height: 12),

            // Conditionally show course selector
            if (_role == "student")
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .orderBy('title')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final docs = snapshot.data!.docs;
                  return DropdownButton<String>(
                    hint: const Text("Select Course"),
                    value: _selectedCourseId,
                    items: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(data['title'] ?? doc.id),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCourseId = val),
                  );
                },
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _addUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : const Text("Add User"),
            ),
          ],
        ),
      ),
    );
  }
}

// // add_user_screen.dart
// // Screen: Admin Add User
// // - Calls callable Cloud Function `createUser` to create or fetch a Firebase Auth user by email.
// // - Ensures Firestore `users/{uid}` doc exists and merges `roles` via arrayUnion (supports multirole).
// // - Does NOT use `status`. Sets `username` to the uid.
// // - Navigates back with true on success.

// import 'package:flutter/material.dart';
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:coursebuddy/widgets/error_dialog.dart';
// import 'package:coursebuddy/constants/app_theme.dart';

// class AddUserScreen extends StatefulWidget {
//   const AddUserScreen({super.key});

//   @override
//   State<AddUserScreen> createState() => _AddUserScreenState();
// }

// class _AddUserScreenState extends State<AddUserScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   String _role = 'teacher';
//   bool _loading = false;

//   Future<void> _addUser() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Email and password required')),
//       );
//       return;
//     }

//     setState(() => _loading = true);
//     try {
//       final callable = FirebaseFunctions.instance.httpsCallable('createUser');
//       final result = await callable.call({
//         'email': email,
//         'password': password,
//         'requestedRole': _role,
//       });

//       // result.data should be a map with uid and created boolean
//       final data = Map<String, dynamic>.from(result.data as Map);
//       final uid = data['uid'] as String;

//       // Ensure Firestore users/{uid} exists and merge roles (multi-role)
//       final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
//       await userRef.set({
//         'email': email,
//         'username': uid,
//         // 'roles':_role,
//         'role':_role,
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       if (!mounted) return;
//       Navigator.pop(context, true);
//     } catch (e) {
//       if (mounted) await showError(context, e);
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add User"),
//         backgroundColor: AppTheme.primaryColor,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.help_outline),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (_) => AlertDialog(
//                   title: const Text('Note'),
//                   content: const Text(
//                     'This will create (or locate) an Auth user by email and add the selected role to their Firestore profile. No duplicates will be created if an account already exists for that email.',
//                   ),
//                   actions: [
//                     TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
//                   ],
//                 ),
//               );
//             },
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: "Email"),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: "Password"),
//             ),
//             const SizedBox(height: 12),
//             DropdownButton<String>(
//               value: _role,
//               items: const [
//                 DropdownMenuItem(value: "teacher", child: Text("Teacher")),
//                 DropdownMenuItem(value: "parent", child: Text("Parent")),
//                 DropdownMenuItem(value: "student", child: Text("Student")),
//                 DropdownMenuItem(value: "admin", child: Text("Admin")),
//               ],
//               onChanged: (val) => setState(() => _role = val ?? "teacher"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loading ? null : _addUser,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.primaryColor,
//               ),
//               child: _loading
//                   ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
//                   : const Text("Add User"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
