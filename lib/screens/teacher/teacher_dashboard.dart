/// TeacherDashboard
/// ----------------
/// Main entry point for teachers.
/// - Upload external course materials (links, PDFs, videos).
/// - Upload authored notes (text-based, admin approval required).
/// - Upload quizzes (multi-question, approval workflow).
/// - View quiz submissions from students.

import 'package:flutter/material.dart';
import 'package:coursebuddy/constants/app_theme.dart';
import 'package:coursebuddy/screens/teacher/material_upload.dart';
import 'package:coursebuddy/screens/teacher/quiz_submission.dart';
import 'note_upload.dart';
import 'quiz_upload.dart'; // NEW import

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Upload external materials (PDF, video, links)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MaterialUploadScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Upload Material"),
            ),
            const SizedBox(height: 16),

            // Upload text-based notes (teacher authored)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NoteUploadScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Upload Note"),
            ),
            const SizedBox(height: 16),

            // Upload quizzes
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuizUploadScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Upload Quiz"),
            ),
            const SizedBox(height: 16),

            // View quiz submissions from students
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuizSubmissionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("View Quiz Submissions"),
            ),
          ],
        ),
      ),
    );
  }
}
