// CHECK
// MaterialPageRoute(
//                               builder: (_) => StudentQuizScreen(
//                                 quizId: doc.id,
//                                 //quizData: data,
//                               ),
// /// StudentDashboard
// ************
/// This widget is the main dashboard for students.
/// It displays:
/// - A button to access approved course notes/materials.
/// - A list of active quizzes for the course.
/// - A list of active projects for the course.
///
/// Data rules applied from Firestore schema:
/// - Quizzes are stored in top-level `quizzes/` collection (filtered by courseId + approved).
/// - Projects are stored in top-level `projects/` collection (filtered by courseId + approved).
/// - Only content with `status == 'approved'` is shown to students.
/// - Teachers/Admins control approval in the workflow.

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:coursebuddy/widgets/status.dart';
import 'package:flutter/material.dart';
import 'package:coursebuddy/screens/student/student_material.dart';
import 'package:coursebuddy/screens/student/student_quiz.dart';

class StudentDashboard extends StatelessWidget {
  final String courseId;
  final String status;

  const StudentDashboard({
    super.key,
    required this.courseId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Reference quizzes for this course (only approved)
    final quizRef = FirebaseFirestore.instance
        .collection('quizzes')
        .where('courseId', isEqualTo: courseId)
        .where('status', isEqualTo: 'approved');

    // Reference projects for this course (only approved)
    final projectRef = FirebaseFirestore.instance
        .collection('projects')
        .where('courseId', isEqualTo: courseId)
        .where('status', isEqualTo: 'approved');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        // actions: [StatusBadge(status: status)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📚 Your Materials',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentMaterialsScreen(courseId: courseId),
                  ),
                );
              },
              child: const Text('Go to Materials'),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const Text(
              '📝 Quizzes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            StreamBuilder(
              stream: quizRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('🕒 No quizzes yet.');
                }
                final docs = snapshot.data!.docs;
                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    return Card(
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(data['title'] ?? 'Untitled Quiz'),
                        subtitle: data.containsKey('question')
                            ? Text(
                                (data['question'] ?? '').toString().substring(
                                  0,
                                  30,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: const Icon(Icons.play_circle_outline),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentQuizScreen(
                                quizId: doc.id,
                                //quizData: data,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              '💼 Projects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            StreamBuilder(
              stream: projectRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('🕒 No projects yet.');
                }
                final docs = snapshot.data!.docs;
                return Column(
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
            ),
          ],
        ),
      ),
    );
  }
}
