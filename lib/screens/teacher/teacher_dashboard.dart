import 'package:coursebuddy/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:coursebuddy/constants/app_theme.dart';
import 'package:coursebuddy/screens/teacher/home_screen.dart';
import 'package:coursebuddy/screens/teacher/material_upload.dart';
import 'package:coursebuddy/screens/teacher/quiz_submission.dart';
import 'package:coursebuddy/screens/teacher/note_upload.dart';
import 'package:coursebuddy/screens/teacher/quiz_upload.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  bool _isRailExpanded = true;
  String? _userName;

  final List<Widget> _pages = const [
    HomeScreen(),
    MaterialUploadScreen(),
    NoteUploadScreen(),
    QuizUploadScreen(),
    QuizSubmissionScreen(),
  ];

  final List<String> _titles = const [
    "Dashboard",
    "Upload Material",
    "Upload Note",
    "Upload Quiz",
    "View Quiz Submissions",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userName = user?.displayName ?? "Teacher";
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Row(
          children: [
            const SizedBox(width: 50),
            Container(width: 1, height: 20, color: Colors.white54),
            const SizedBox(width: 16),
            Text(
              "Welcome, ${_userName ?? "Teacher"}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),

      // ✅ Mobile Drawer
      drawer: isMobile
          ? Drawer(
              width: 240,
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 100,
                    width: double.infinity,
                    color: AppTheme.primaryColor,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage(
                            "assets/images/coursebuddy_logo.png",
                          ),
                          radius: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Tech Talk Hub",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu items
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDrawerItem(
                          Icons.home_filled,
                          "Dashboard",
                          0,
                          context,
                        ),
                        _buildDrawerItem(
                          Icons.book,
                          "Upload Material",
                          1,
                          context,
                        ),
                        _buildDrawerItem(Icons.note, "Upload Note", 2, context),
                        _buildDrawerItem(Icons.quiz, "Upload Quiz", 3, context),
                        _buildDrawerItem(
                          Icons.assignment,
                          "Quiz Submissions",
                          4,
                          context,
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // ✅ Bottom section: collapse + logout
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isRailExpanded
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                          ),
                          onPressed: () {
                            setState(() {
                              _isRailExpanded = !_isRailExpanded;
                            });
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text("Logout"),
                          onTap: () async {
                            await AuthService().logout(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,

      // ✅ Web/Desktop Layout with NavigationRail
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              selectedIndex: _selectedIndex,
              extended: _isRailExpanded,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },

              // ✅ Top logo
              leading: Column(
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    backgroundImage: const AssetImage(
                      "assets/images/coursebuddy_logo.png",
                    ),
                    radius: _isRailExpanded ? 22 : 16,
                  ),
                  const SizedBox(height: 8),
                  if (_isRailExpanded)
                    const Text(
                      "Tech Talk Hub",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 16),
                ],
              ),

              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_filled),
                  label: Text("Dashboard"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.book),
                  label: Text("Material"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.note),
                  label: Text("Notes"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.quiz),
                  label: Text("Quizzes"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment),
                  label: Text("Submissions"),
                ),
              ],

              // ✅ Bottom: collapse + logout
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Divider(thickness: 1),
                  IconButton(
                    icon: Icon(
                      _isRailExpanded
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                    ),
                    onPressed: () {
                      setState(() {
                        _isRailExpanded = !_isRailExpanded;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      await AuthService().logout(context);
                    },
                    child: Row(
                      mainAxisAlignment: _isRailExpanded
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Colors.red),
                        if (_isRailExpanded) ...[
                          const SizedBox(width: 8),
                          const Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

          // ✅ Page content
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String text,
    int index,
    BuildContext context,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }
}

// // TeacherDashboard
// // ----------------
// // Main entry point for teachers.
// // - Upload external course materials (links, PDFs, videos).
// // - Upload authored notes (text-based, admin approval required).
// // - Upload quizzes (multi-question, approval workflow).
// // - View quiz submissions from students.
// import 'package:coursebuddy/services/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:coursebuddy/constants/app_theme.dart';
// import 'package:coursebuddy/screens/teacher/material_upload.dart';
// import 'package:coursebuddy/screens/teacher/quiz_submission.dart';
// import 'note_upload.dart';
// import 'quiz_upload.dart'; // NEW import

// class TeacherDashboard extends StatelessWidget {
//   const TeacherDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Teacher Dashboard"),
//         backgroundColor: AppTheme.primaryColor,
//         actions:[IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               // await FirebaseAuth.instance.signOut();
//               await AuthService().logout(context);
//             },
//           ),],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Upload external materials (PDF, video, links)
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const MaterialUploadScreen(),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.primaryColor,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text("Upload Material"),
//             ),
//             const SizedBox(height: 16),

//             // Upload text-based notes (teacher authored)
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const NoteUploadScreen(),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.primaryColor,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text("Upload Note"),
//             ),
//             const SizedBox(height: 16),

//             // Upload quizzes
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const QuizUploadScreen(),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.primaryColor,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text("Upload Quiz"),
//             ),
//             const SizedBox(height: 16),

//             // View quiz submissions from students
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const QuizSubmissionScreen(),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.primaryColor,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text("View Quiz Submissions"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
