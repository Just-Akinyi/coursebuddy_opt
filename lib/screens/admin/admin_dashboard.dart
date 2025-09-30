import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursebuddy/screens/admin/add_course.dart';
import 'package:coursebuddy/screens/admin/course_list.dart';
import 'package:coursebuddy/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:coursebuddy/constants/app_theme.dart';
import 'package:coursebuddy/screens/admin/add_user.dart';
import 'package:coursebuddy/screens/admin/user_list.dart';
import 'package:coursebuddy/services/role_based_calendar.dart';
import 'package:coursebuddy/screens/admin/material_approval.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final Query allEventsQuery = FirebaseFirestore.instance.collection(
      'events',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add user',
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddUserScreen()),
              );
              if (added == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("User created/updated successfully"),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              onPressed: () async {
                try {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserListScreen()),
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                }
              },
              child: const Text("View Users & Roles"),
            ),
            const SizedBox(height: 12),
            const Text(
              'Use the "View Users & Roles" screen to manage roles. '
              'The add button at the top-right allows quick user creation.',
            ),
            const SizedBox(height: 24),

            // ✅ Materials Management Section
            const Text(
              "Materials Management",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            //             SizedBox(
            //     height: 300, // Choose a reasonable, fixed height
            //     child: const AdminApprovalScreen(),
            // ),
            const AdminApprovalScreen(),
            // New Section Header for Courses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "All Courses",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // Re-implement navigation to AddCourseScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddCourseScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 24),
            CourseListScreen(),

            const SizedBox(height: 24),

            // ✅ Calendar Section
            const Text(
              "Events Calendar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 500,
              child: RoleBasedCalendar(
                classQuery: allEventsQuery,
                title: 'All Events',
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// // // admin_dashboard.dart
// // // Screen: Admin Dashboard
// // // - Shows top-level admin actions (View Users).
// // // - Add button placed top-right to open AddUserScreen.
// // // - Admin can see all users (navigates to UserListScreen).
// // import 'package:coursebuddy/services/auth_service.dart';
// // import 'package:flutter/material.dart';
// // import 'package:coursebuddy/constants/app_theme.dart';
// // import 'package:coursebuddy/screens/admin/add_user.dart';
// // import 'package:coursebuddy/screens/admin/user_list.dart';
// // import 'package:coursebuddy/services/role_based_calendar.dart';
// // admin_dashboard.dart
// // Screen: Admin Dashboard
// // - Shows top-level admin actions (View Users).
// // - Add button placed top-right to open AddUserScreen.
// // - Admin can see all users (navigates to UserListScreen).

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:coursebuddy/services/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:coursebuddy/constants/app_theme.dart';
// import 'package:coursebuddy/screens/admin/add_user.dart';
// import 'package:coursebuddy/screens/admin/user_list.dart';
// import 'package:coursebuddy/services/role_based_calendar.dart';
// import 'package:coursebuddy/screens/admin/material_approval.dart';

// class AdminDashboard extends StatelessWidget {
//   const AdminDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // 💡 Create the Firestore query to get all events.
//     final Query allEventsQuery = FirebaseFirestore.instance.collection('events');

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Admin Dashboard"),
//         backgroundColor: AppTheme.primaryColor,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             tooltip: 'Add user',
//             onPressed: () async {
//               final added = await Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const AddUserScreen()),
//               );
//               if (added == true && context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("User created/updated successfully"),
//                   ),
//                 );
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await AuthService().logout(context);
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView( // 💡 Use SingleChildScrollView to prevent overflow
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primaryColor,
//                 ),
//                 onPressed: () async {
//                   try {
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const UserListScreen()),
//                     );
//                   } catch (e) {
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(
//                         context,
//                       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//                     }
//                   }
//                 },
//                 child: const Text("View Users & Roles"),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 'Use the "View Users & Roles" screen to manage roles. The add button at the top-right allows quick user creation.',
//               ),
//               const SizedBox(height: 24), // 💡 Add space between sections
//               AdminApprovalScreen(),
//               // 💡 Integrate the RoleBasedCalendar here 👇
//               const Text("Events Calendar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               SizedBox( // Wrap in a SizedBox to constrain the height
//                 height: 500, // Adjust height as needed
//                 child: RoleBasedCalendar(
//                   classQuery: allEventsQuery,
//                   title: 'All Events',
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// // class AdminDashboard extends StatelessWidget {
// //   const AdminDashboard({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Admin Dashboard"),

// //         backgroundColor: AppTheme.primaryColor,
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.add),
// //             tooltip: 'Add user',
// //             onPressed: () async {
// //               final added = await Navigator.push(
// //                 context,
// //                 MaterialPageRoute(builder: (_) => const AddUserScreen()),
// //               );
// //               if (added == true && context.mounted) {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   const SnackBar(
// //                     content: Text("User created/updated successfully"),
// //                   ),
// //                 );
// //               }
// //             },
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.logout),
// //             onPressed: () async {
// //               // await FirebaseAuth.instance.signOut();
// //               await AuthService().logout(context);
// //             },
// //           ),
// //         ],
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             ElevatedButton(
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: AppTheme.primaryColor,
// //               ),
// //               onPressed: () async {
// //                 try {
// //                   await Navigator.push(
// //                     context,
// //                     MaterialPageRoute(builder: (_) => const UserListScreen()),
// //                   );
// //                 } catch (e) {
// //                   if (context.mounted) {
// //                     ScaffoldMessenger.of(
// //                       context,
// //                     ).showSnackBar(SnackBar(content: Text("Error: $e")));
// //                   }
// //                 }
// //               },
// //               child: const Text("View Users & Roles"),
// //             ),
// //             const SizedBox(height: 12),
// //             const Text(
// //               'Use the "View Users & Roles" screen to manage roles. The add button at the top-right allows quick user creation.',
// //             ),
// //           ],
// //         ),
        
        

// //       ),
// //     );
// //   }
// // }

// // // // admin_dashboard.dart
// // // // Screen: Admin Dashboard
// // // // - Shows top-level admin actions (View Users).
// // // // - Add button placed top-right to open AddUserScreen.
// // // // - Admin can see all users (navigates to UserListScreen).

// // // import 'package:flutter/material.dart';
// // // import 'package:coursebuddy/constants/app_theme.dart';
// // // import 'package:coursebuddy/screens/admin/add_user.dart';
// // // import 'package:coursebuddy/screens/admin/user_list.dart';

// // // class AdminDashboard extends StatelessWidget {
// // //   const AdminDashboard({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text("Admin Dashboard"),
// // //         backgroundColor: AppTheme.primaryColor,
// // //         actions: [
// // //           IconButton(
// // //             icon: const Icon(Icons.add),
// // //             tooltip: 'Add user',
// // //             onPressed: () async {
// // //               final added = await Navigator.push(
// // //                 context,
// // //                 MaterialPageRoute(builder: (_) => const AddUserScreen()),
// // //               );
// // //               if (added == true && context.mounted) {
// // //                 ScaffoldMessenger.of(context).showSnackBar(
// // //                   const SnackBar(content: Text("User created/updated successfully")),
// // //                 );
// // //               }
// // //             },
// // //           ),
// // //         ],
// // //       ),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.stretch,
// // //           children: [
// // //             ElevatedButton(
// // //               style: ElevatedButton.styleFrom(
// // //                 backgroundColor: AppTheme.primaryColor,
// // //               ),
// // //               onPressed: () {
// // //                 Navigator.push(
// // //                   context,
// // //                   MaterialPageRoute(builder: (_) => const UserListScreen()),
// // //                 );
// // //               },
// // //               child: const Text("View Users & Roles"),
// // //             ),
// // //             const SizedBox(height: 12),
// // //             const Text(
// // //               'Use the "View Users & Roles" screen to manage roles. The add button at the top-right allows quick user creation.',
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
