// ----------------------------
// StudentDashboard.dart
// ----------------------------
import 'package:coursebuddy/screens/student/full_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:coursebuddy/screens/student/home_screen.dart'; // Dashboard / home screen
import 'package:coursebuddy/screens/student/student_material.dart';
import 'package:coursebuddy/screens/student/student_quiz.dart';
import 'package:coursebuddy/services/auth_service.dart';
import 'package:coursebuddy/constants/app_theme.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:table_calendar/table_calendar.dart';

class StudentDashboard extends StatefulWidget {
  final String courseId;
  final String status;

  const StudentDashboard({
    super.key,
    required this.courseId,
    required this.status,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool _isCollapsed = false;
  int _selectedIndex = 0;

  // Hardcoded student info (replace with Firestore later)
  final String studentName = "John Doe";
  final String studentImage = "https://i.pravatar.cc/150?img=3";

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: isWide
          ? null
          : AppBar(
              title: const Text('Student Dashboard'),
              backgroundColor: AppTheme.primaryColor,
            ),
      drawer: isWide ? null : _buildDrawer(),
      body: Row(
        children: [
          if (isWide) _buildSidebar(),
          Expanded(child: _buildPageContent(_selectedIndex)),
        ],
      ),
    );
  }

  // ---------------- DRAWER FOR MOBILE ----------------
  Widget _buildDrawer() {
    return SizedBox(
      width: _isCollapsed ? 80 : 240,
      child: Drawer(
        child: Column(
          children: [
            _buildProfile(),
            _buildNavItems(isWide: false),
            const Spacer(),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  // ---------------- SIDEBAR FOR WIDE SCREENS ----------------
  Widget _buildSidebar() {
    return Container(
      width: _isCollapsed ? 80 : 240,
      color: Colors.grey[200],
      child: Column(
        children: [
          _buildProfile(),
          _buildNavItems(isWide: true),
          const Spacer(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  // ---------------- PROFILE ----------------
  Widget _buildProfile() {
    return DrawerHeader(
      decoration: BoxDecoration(color: AppTheme.primaryColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(studentImage),
            radius: _isCollapsed ? 24 : 36,
          ),
          if (!_isCollapsed) ...[
            const SizedBox(height: 8),
            Text(
              studentName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- NAVIGATION ITEMS ----------------
  Widget _buildNavItems({required bool isWide}) {
    final items = [
      {"icon": Icons.home_filled, "label": "Dashboard"},
      {"icon": Icons.book, "label": "Materials"},
      {"icon": Icons.quiz, "label": "Quizzes"},
      {"icon": Icons.assignment, "label": "Projects"},
      {"icon": Icons.calendar_today, "label": "Calendar"},
    ];

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final bool selected = _selectedIndex == index;
        final iconData = item['icon'] as IconData;
        final label = item['label'] as String;

        if (_isCollapsed) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _selectedIndex = index);
                if (!isWide && Navigator.canPop(context))
                  Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: 48,
                alignment: Alignment.center,
                decoration: selected
                    ? BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Icon(
                  iconData,
                  color: selected ? AppTheme.primaryColor : null,
                ),
              ),
            ),
          );
        }

        return ListTile(
          leading: Icon(
            iconData,
            color: selected ? AppTheme.primaryColor : null,
          ),
          title: Text(label),
          selected: selected,
          selectedTileColor: AppTheme.primaryColor.withOpacity(0.12),
          onTap: () {
            setState(() => _selectedIndex = index);
            if (!isWide && Navigator.canPop(context)) Navigator.pop(context);
          },
        );
      }),
    );
  }

  // ---------------- BOTTOM CONTROLS ----------------
  Widget _buildBottomControls() {
    if (_isCollapsed) {
      return Column(
        children: [
          const SizedBox(height: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async => await AuthService().logout(context),
            child: Container(
              width: double.infinity,
              height: 48,
              alignment: Alignment.center,
              child: const Icon(Icons.logout),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: Icon(
                _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
              ),
              onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Logout"),
          onTap: () async => await AuthService().logout(context),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            icon: Icon(_isCollapsed ? Icons.chevron_right : Icons.chevron_left),
            onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // ---------------- PAGE CONTENT ----------------
  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        // return StudentMaterialsScreen(courseId: widget.courseId);
        return StudentNotesScreen();
      case 2:
        return _buildQuizzesPage();
      case 3:
        return _buildProjectsPage();
      case 4:
        return const StudentCalendarPage(); // Fully adaptive calendar page
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  // ---------------- Quizzes content ----------------
  Widget _buildQuizzesPage() {
    final quizRef = FirebaseFirestore.instance
        .collection('quizzes')
        .where('courseId', isEqualTo: widget.courseId)
        .where('status', isEqualTo: 'approved');

    return StreamBuilder<QuerySnapshot>(
      stream: quizRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('🕒 No quizzes yet.'));
        }
        final docs = snapshot.data!.docs;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return Card(
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(data['title'] ?? 'Untitled Quiz'),
                subtitle: data.containsKey('question')
                    ? Text(
                        (data['question'] ?? '').toString().substring(0, 30),
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: const Icon(Icons.play_circle_outline),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentQuizScreen(quizId: doc.id),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ---------------- Projects content ----------------
  Widget _buildProjectsPage() {
    final projectRef = FirebaseFirestore.instance
        .collection('projects')
        .where('courseId', isEqualTo: widget.courseId)
        .where('status', isEqualTo: 'approved');

    return StreamBuilder<QuerySnapshot>(
      stream: projectRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('🕒 No projects yet.'));
        }
        final docs = snapshot.data!.docs;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return Card(
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(data['title'] ?? 'Untitled Project'),
                trailing: const Icon(Icons.assignment),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Open Project: ${data['title'] ?? 'Untitled'}",
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:coursebuddy/screens/student/home_screen.dart'; // Dashboard / home screen
// import 'package:coursebuddy/screens/student/student_material.dart';
// import 'package:coursebuddy/screens/student/student_quiz.dart';
// import 'package:coursebuddy/services/auth_service.dart';
// import 'package:coursebuddy/constants/app_theme.dart';

// class StudentDashboard extends StatefulWidget {
//   final String courseId;
//   final String status;

//   const StudentDashboard({
//     super.key,
//     required this.courseId,
//     required this.status,
//   });

//   @override
//   State<StudentDashboard> createState() => _StudentDashboardState();
// }

// class _StudentDashboardState extends State<StudentDashboard> {
//   bool _isCollapsed = false;
//   int _selectedIndex = 0;

//   // Hardcoded student info (replace with Firestore later)
//   final String studentName = "John Doe";
//   final String studentImage = "https://i.pravatar.cc/150?img=3";

//   @override
//   Widget build(BuildContext context) {
//     final isWide = MediaQuery.of(context).size.width >= 800;

//     return Scaffold(
//       // show AppBar on mobile only
//       appBar: isWide
//           ? null
//           : AppBar(
//               title: const Text('Student Dashboard'),
//               backgroundColor: AppTheme.primaryColor,
//             ),

//       // Drawer for mobile, null for wide (persistent sidebar used)
//       drawer: isWide ? null : _buildDrawer(),

//       body: Row(
//         children: [
//           if (isWide) _buildSidebar(),
//           // main content area
//           Expanded(child: _buildPageContent(_selectedIndex)),
//         ],
//       ),
//     );
//   }

//   // ---------------- DRAWER FOR MOBILE ----------------
//   Widget _buildDrawer() {
//     return SizedBox(
//       width: _isCollapsed ? 80 : 240,
//       child: Drawer(
//         child: Column(
//           children: [
//             _buildProfile(),
//             _buildNavItems(isWide: false),
//             const Spacer(),
//             _buildBottomControls(),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------------- SIDEBAR FOR WIDE SCREENS ----------------
//   Widget _buildSidebar() {
//     return Container(
//       width: _isCollapsed ? 80 : 240,
//       color: Colors.grey[200],
//       child: Column(
//         children: [
//           _buildProfile(),
//           _buildNavItems(isWide: true),
//           const Spacer(),
//           _buildBottomControls(),
//         ],
//       ),
//     );
//   }

//   // ---------------- PROFILE ----------------
//   Widget _buildProfile() {
//     return DrawerHeader(
//       decoration: BoxDecoration(color: AppTheme.primaryColor),
//       // keep avatar centered whether collapsed or not
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             backgroundImage: NetworkImage(studentImage),
//             radius: _isCollapsed ? 24 : 36,
//           ),
//           if (!_isCollapsed) ...[
//             const SizedBox(height: 8),
//             Text(
//               studentName,
//               style: const TextStyle(color: Colors.white, fontSize: 16),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // ---------------- NAVIGATION ITEMS ----------------
//   Widget _buildNavItems({required bool isWide}) {
//     final items = [
//       {"icon": Icons.home_filled, "label": "Dashboard"},
//       {"icon": Icons.book, "label": "Materials"},
//       {"icon": Icons.quiz, "label": "Quizzes"},
//       {"icon": Icons.assignment, "label": "Projects"},
//       {"icon": Icons.calendar, "label": "Calender"}
//     ];

//     return Column(
//       children: List.generate(items.length, (index) {
//         final item = items[index];
//         final bool selected = _selectedIndex == index;
//         final iconData = item['icon'] as IconData;
//         final label = item['label'] as String;

//         if (_isCollapsed) {
//           // Collapsed: show centered icon with a tappable container (balanced)
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6.0),
//             child: GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onTap: () {
//                 setState(() => _selectedIndex = index);
//                 // if it's a mobile drawer, close it
//                 if (!isWide && Navigator.canPop(context)) Navigator.pop(context);
//               },
//               child: Container(
//                 width: double.infinity,
//                 height: 48,
//                 alignment: Alignment.center,
//                 decoration: selected
//                     ? BoxDecoration(
//                         color: AppTheme.primaryColor.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(8),
//                       )
//                     : null,
//                 child: Icon(
//                   iconData,
//                   color: selected ? AppTheme.primaryColor : null,
//                 ),
//               ),
//             ),
//           );
//         }

//         // Expanded: normal ListTile with selected highlight
//         return ListTile(
//           leading: Icon(iconData, color: selected ? AppTheme.primaryColor : null),
//           title: Text(label),
//           selected: selected,
//           selectedTileColor: AppTheme.primaryColor.withOpacity(0.12),
//           onTap: () {
//             setState(() => _selectedIndex = index);
//             // close mobile drawer if open
//             if (!isWide && Navigator.canPop(context)) Navigator.pop(context);
//           },
//         );
//       }),
//     );
//   }

//   // ---------------- BOTTOM CONTROLS ----------------
//   Widget _buildBottomControls() {
//     if (_isCollapsed) {
//       // collapsed layout: logout icon centered, then chevron
//       return Column(
//         children: [
//           const SizedBox(height: 6),
//           GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTap: () async {
//               await AuthService().logout(context);
//             },
//             child: Container(
//               width: double.infinity,
//               height: 48,
//               alignment: Alignment.center,
//               child: const Icon(Icons.logout),
//             ),
//           ),
//           const SizedBox(height: 6),
//           Align(
//             alignment: Alignment.bottomRight,
//             child: IconButton(
//               icon: Icon(_isCollapsed ? Icons.chevron_right : Icons.chevron_left),
//               onPressed: () {
//                 setState(() {
//                   _isCollapsed = !_isCollapsed;
//                 });
//               },
//             ),
//           ),
//           const SizedBox(height: 12),
//         ],
//       );
//     }

//     // expanded layout: ListTile for logout + chevron
//     return Column(
//       children: [
//         ListTile(
//           leading: const Icon(Icons.logout),
//           title: const Text("Logout"),
//           onTap: () async {
//             await AuthService().logout(context);
//           },
//         ),
//         Align(
//           alignment: Alignment.bottomRight,
//           child: IconButton(
//             icon: Icon(_isCollapsed ? Icons.chevron_right : Icons.chevron_left),
//             onPressed: () {
//               setState(() {
//                 _isCollapsed = !_isCollapsed;
//               });
//             },
//           ),
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }

//   // ---------------- PAGE CONTENT ----------------
//   Widget _buildPageContent(int index) {
//     switch (index) {
//       case 0:
//         // Dashboard / HomeScreen (imported from home_screen.dart)
//         return const HomeScreen();
//       case 1:
//         return StudentMaterialsScreen(courseId: widget.courseId);
//       case 2:
//         return _buildQuizzesPage();
//       case 3:
//         return _buildProjectsPage();
//       default:
//         return const Center(child: Text("Page not found"));
//     }
//   }

//   // ---------------- Quizzes content (keeps original logic) ----------------
//   Widget _buildQuizzesPage() {
//     final quizRef = FirebaseFirestore.instance
//         .collection('quizzes')
//         .where('courseId', isEqualTo: widget.courseId)
//         .where('status', isEqualTo: 'approved');

//     return StreamBuilder<QuerySnapshot>(
//       stream: quizRef.snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('🕒 No quizzes yet.'));
//         }
//         final docs = snapshot.data!.docs;
//         return ListView(
//           padding: const EdgeInsets.all(16),
//           children: docs.map((doc) {
//             final data = doc.data() as Map<String, dynamic>? ?? {};
//             return Card(
//               elevation: 6,
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               child: ListTile(
//                 title: Text(data['title'] ?? 'Untitled Quiz'),
//                 subtitle: data.containsKey('question')
//                     ? Text(
//                         (data['question'] ?? '').toString().substring(0, 30),
//                         overflow: TextOverflow.ellipsis,
//                       )
//                     : null,
//                 trailing: const Icon(Icons.play_circle_outline),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => StudentQuizScreen(quizId: doc.id),
//                     ),
//                   );
//                 },
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   // ---------------- Projects content (keeps original logic) ----------------
//   Widget _buildProjectsPage() {
//     final projectRef = FirebaseFirestore.instance
//         .collection('projects')
//         .where('courseId', isEqualTo: widget.courseId)
//         .where('status', isEqualTo: 'approved');

//     return StreamBuilder<QuerySnapshot>(
//       stream: projectRef.snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('🕒 No projects yet.'));
//         }
//         final docs = snapshot.data!.docs;
//         return ListView(
//           padding: const EdgeInsets.all(16),
//           children: docs.map((doc) {
//             final data = doc.data() as Map<String, dynamic>? ?? {};
//             return Card(
//               elevation: 6,
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               child: ListTile(
//                 title: Text(data['title'] ?? 'Untitled Project'),
//                 trailing: const Icon(Icons.assignment),
//                 onTap: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         "Open Project: ${data['title'] ?? 'Untitled'}",
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }



// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:coursebuddy/screens/student/student_material.dart';
// // import 'package:coursebuddy/screens/student/student_quiz.dart';
// // import 'package:coursebuddy/services/auth_service.dart';
// // import 'package:coursebuddy/constants/app_theme.dart';

// // class StudentDashboard extends StatefulWidget {
// //   final String courseId;
// //   final String status;

// //   const StudentDashboard({
// //     super.key,
// //     required this.courseId,
// //     required this.status,
// //   });

// //   @override
// //   State<StudentDashboard> createState() => _StudentDashboardState();
// // }

// // class _StudentDashboardState extends State<StudentDashboard> {
// //   bool _isCollapsed = false;

// //   @override
// //   Widget build(BuildContext context) {
// //     final quizRef = FirebaseFirestore.instance
// //         .collection('quizzes')
// //         .where('courseId', isEqualTo: widget.courseId)
// //         .where('status', isEqualTo: 'approved');

// //     final projectRef = FirebaseFirestore.instance
// //         .collection('projects')
// //         .where('courseId', isEqualTo: widget.courseId)
// //         .where('status', isEqualTo: 'approved');

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Student Dashboard'),
// //         backgroundColor: AppTheme.primaryColor,
// //       ),
// //       drawer: SizedBox(
// //         width: _isCollapsed ? 80 : 240, // collapse width vs expanded width
// //         child: Drawer(
// //           child: Column(
// //             children: [
// //               DrawerHeader(
// //                 decoration: BoxDecoration(color: AppTheme.primaryColor),
// //                 child: Align(
// //                   alignment: Alignment.bottomLeft,
// //                   child: _isCollapsed
// //                       ? const Icon(Icons.menu, color: Colors.white, size: 28)
// //                       : const Text(
// //                           "Menu",
// //                           style: TextStyle(color: Colors.white, fontSize: 22),
// //                         ),
// //                 ),
// //               ),
// //               _buildNavItem(
// //                 icon: Icons.home,
// //                 label: "Dashboard",
// //                 onTap: () => Navigator.pop(context),
// //               ),
// //               _buildNavItem(
// //                 icon: Icons.menu_book,
// //                 label: "Materials",
// //                 onTap: () {
// //                   Navigator.push(
// //                     context,
// //                     MaterialPageRoute(
// //                       builder: (_) =>
// //                           StudentMaterialsScreen(courseId: widget.courseId),
// //                     ),
// //                   );
// //                 },
// //               ),
// //               const Spacer(),
// //               _buildNavItem(
// //                 icon: Icons.logout,
// //                 label: "Logout",
// //                 onTap: () async {
// //                   await AuthService().logout(context);
// //                 },
// //               ),
// //               Align(
// //                 alignment: Alignment.bottomRight,
// //                 child: IconButton(
// //                   icon: Icon(
// //                     _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
// //                   ),
// //                   onPressed: () {
// //                     setState(() {
// //                       _isCollapsed = !_isCollapsed;
// //                     });
// //                   },
// //                 ),
// //               ),
// //               const SizedBox(height: 12),
// //             ],
// //           ),
// //         ),
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text(
// //               '📚 Your Materials',
// //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 10),
// //             ElevatedButton(
// //               onPressed: () {
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                     builder: (_) =>
// //                         StudentMaterialsScreen(courseId: widget.courseId),
// //                   ),
// //                 );
// //               },
// //               child: const Text('Go to Materials'),
// //             ),
// //             const SizedBox(height: 30),
// //             const Divider(),
// //             const Text(
// //               '📝 Quizzes',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             StreamBuilder(
// //               stream: quizRef.snapshots(),
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.waiting) {
// //                   return const CircularProgressIndicator();
// //                 }
// //                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //                   return const Text('🕒 No quizzes yet.');
// //                 }
// //                 final docs = snapshot.data!.docs;
// //                 return Column(
// //                   children: docs.map((doc) {
// //                     final data = doc.data() as Map<String, dynamic>? ?? {};
// //                     return Card(
// //                       elevation: 6,
// //                       margin: const EdgeInsets.symmetric(vertical: 8),
// //                       child: ListTile(
// //                         title: Text(data['title'] ?? 'Untitled Quiz'),
// //                         subtitle: data.containsKey('question')
// //                             ? Text(
// //                                 (data['question'] ?? '').toString().substring(0, 30),
// //                                 overflow: TextOverflow.ellipsis,
// //                               )
// //                             : null,
// //                         trailing: const Icon(Icons.play_circle_outline),
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (_) => StudentQuizScreen(quizId: doc.id),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     );
// //                   }).toList(),
// //                 );
// //               },
// //             ),
// //             const SizedBox(height: 20),
// //             const Divider(),
// //             const Text(
// //               '💼 Projects',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             StreamBuilder(
// //               stream: projectRef.snapshots(),
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.waiting) {
// //                   return const CircularProgressIndicator();
// //                 }
// //                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //                   return const Text('🕒 No projects yet.');
// //                 }
// //                 final docs = snapshot.data!.docs;
// //                 return Column(
// //                   children: docs.map((doc) {
// //                     final data = doc.data() as Map<String, dynamic>? ?? {};
// //                     return Card(
// //                       elevation: 6,
// //                       margin: const EdgeInsets.symmetric(vertical: 8),
// //                       child: ListTile(
// //                         title: Text(data['title'] ?? 'Untitled Project'),
// //                         trailing: const Icon(Icons.assignment),
// //                         onTap: () {
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             SnackBar(
// //                               content: Text(
// //                                 "Open Project: ${data['title'] ?? 'Untitled'}",
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     );
// //                   }).toList(),
// //                 );
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildNavItem({
// //     required IconData icon,
// //     required String label,
// //     required VoidCallback onTap,
// //   }) {
// //     return ListTile(
// //       leading: Icon(icon),
// //       title: _isCollapsed ? null : Text(label),
// //       onTap: onTap,
// //     );
// //   }
// // }



// // // // CHECK
// // // // MaterialPageRoute(
// // // //                               builder: (_) => StudentQuizScreen(
// // // //                                 quizId: doc.id,
// // // //                                 //quizData: data,
// // // //                               ),
// // // // /// StudentDashboard
// // // // ************
// // // // This widget is the main dashboard for students.
// // // // It displays:
// // // // - A button to access approved course notes/materials.
// // // // - A list of active quizzes for the course.
// // // // - A list of active projects for the course.
// // // //
// // // // Data rules applied from Firestore schema:
// // // // - Quizzes are stored in top-level `quizzes/` collection (filtered by courseId + approved).
// // // // - Projects are stored in top-level `projects/` collection (filtered by courseId + approved).
// // // // - Only content with `status == 'approved'` is shown to students.
// // // // - Teachers/Admins control approval in the workflow.

// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // import 'package:coursebuddy/widgets/status.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:coursebuddy/screens/student/student_material.dart';
// // // import 'package:coursebuddy/screens/student/student_quiz.dart';
// // // import 'package:coursebuddy/services/auth_service.dart';
// // // import 'package:coursebuddy/constants/app_theme.dart';

// // // class StudentDashboard extends StatelessWidget {
// // //   final String courseId;
// // //   final String status;

// // //   const StudentDashboard({
// // //     super.key,
// // //     required this.courseId,
// // //     required this.status,
// // //   });

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Reference quizzes for this course (only approved)
// // //     final quizRef = FirebaseFirestore.instance
// // //         .collection('quizzes')
// // //         .where('courseId', isEqualTo: courseId)
// // //         .where('status', isEqualTo: 'approved');

// // //     // Reference projects for this course (only approved)
// // //     final projectRef = FirebaseFirestore.instance
// // //         .collection('projects')
// // //         .where('courseId', isEqualTo: courseId)
// // //         .where('status', isEqualTo: 'approved');

// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('Student Dashboard'),
// // //         backgroundColor: AppTheme.primaryColor,
// // //         actions:[IconButton(
// // //             icon: const Icon(Icons.logout),
// // //             onPressed: () async {
// // //               // await FirebaseAuth.instance.signOut();
// // //               await AuthService().logout(context);
// // //             },
// // //           ),],
// // //         // actions: [StatusBadge(status: status)],
// // //       ),
      
// // //       body: SingleChildScrollView(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             const Text(
// // //               '📚 Your Materials',
// // //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// // //             ),
// // //             const SizedBox(height: 10),
// // //             ElevatedButton(
// // //               onPressed: () {
// // //                 Navigator.push(
// // //                   context,
// // //                   MaterialPageRoute(
// // //                     builder: (_) => StudentMaterialsScreen(courseId: courseId),
// // //                   ),
// // //                 );
// // //               },
// // //               child: const Text('Go to Materials'),
// // //             ),
// // //             const SizedBox(height: 30),
// // //             const Divider(),
// // //             const Text(
// // //               '📝 Quizzes',
// // //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //             ),
// // //             StreamBuilder(
// // //               stream: quizRef.snapshots(),
// // //               builder: (context, snapshot) {
// // //                 if (snapshot.connectionState == ConnectionState.waiting) {
// // //                   return const CircularProgressIndicator();
// // //                 }
// // //                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// // //                   return const Text('🕒 No quizzes yet.');
// // //                 }
// // //                 final docs = snapshot.data!.docs;
// // //                 return Column(
// // //                   children: docs.map((doc) {
// // //                     final data = doc.data() as Map<String, dynamic>? ?? {};
// // //                     return Card(
// // //                       elevation: 6,
// // //                       margin: const EdgeInsets.symmetric(vertical: 8),
// // //                       child: ListTile(
// // //                         title: Text(data['title'] ?? 'Untitled Quiz'),
// // //                         subtitle: data.containsKey('question')
// // //                             ? Text(
// // //                                 (data['question'] ?? '').toString().substring(
// // //                                   0,
// // //                                   30,
// // //                                 ),
// // //                                 overflow: TextOverflow.ellipsis,
// // //                               )
// // //                             : null,
// // //                         trailing: const Icon(Icons.play_circle_outline),
// // //                         onTap: () {
// // //                           Navigator.push(
// // //                             context,
// // //                             MaterialPageRoute(
// // //                               builder: (_) => StudentQuizScreen(
// // //                                 quizId: doc.id,
// // //                                 //quizData: data,
// // //                               ),
// // //                             ),
// // //                           );
// // //                         },
// // //                       ),
// // //                     );
// // //                   }).toList(),
// // //                 );
// // //               },
// // //             ),
// // //             const SizedBox(height: 20),
// // //             const Divider(),
// // //             const Text(
// // //               '💼 Projects',
// // //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //             ),
// // //             StreamBuilder(
// // //               stream: projectRef.snapshots(),
// // //               builder: (context, snapshot) {
// // //                 if (snapshot.connectionState == ConnectionState.waiting) {
// // //                   return const CircularProgressIndicator();
// // //                 }
// // //                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// // //                   return const Text('🕒 No projects yet.');
// // //                 }
// // //                 final docs = snapshot.data!.docs;
// // //                 return Column(
// // //                   children: docs.map((doc) {
// // //                     final data = doc.data() as Map<String, dynamic>? ?? {};
// // //                     return Card(
// // //                       elevation: 6,
// // //                       margin: const EdgeInsets.symmetric(vertical: 8),
// // //                       child: ListTile(
// // //                         title: Text(data['title'] ?? 'Untitled Project'),
// // //                         trailing: const Icon(Icons.assignment),
// // //                         onTap: () {
// // //                           ScaffoldMessenger.of(context).showSnackBar(
// // //                             SnackBar(
// // //                               content: Text(
// // //                                 "Open Project: ${data['title'] ?? 'Untitled'}",
// // //                               ),
// // //                             ),
// // //                           );
// // //                         },
// // //                       ),
// // //                     );
// // //                   }).toList(),
// // //                 );
// // //               },
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
