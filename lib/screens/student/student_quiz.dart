/// StudentQuizScreen
/// -----------------
/// Reads approved quizzes from `quizzes/` collection (filtered by courseId).
/// Each quiz **doc can now contain multiple questions** in a `questions` array.
/// For each question:
/// - Multiple choice options are shown.
/// - On selecting an answer:
///   - Correct = green highlight ✅
///   - Wrong = red ❌ and correct answer shown in green.
/// Navigation:
/// - "Next" button collapses current question and opens the next.
/// - At the end, results are saved in `quiz_submissions/`.
///
/// Firestore schema expected for each quiz doc:
/// {
///   "courseId": "python",
///   "title": "Math Basics",
///   "questions": [
///     {
///       "q": "What is 2+2?",
///       "options": ["3", "4", "5", "6"],
///       "correctIndex": 1
///     },
///     {
///       "q": "What is 5-2?",
///       "options": ["1", "2", "3", "4"],
///       "correctIndex": 2
///     }
///   ],
///   "status": "approved"
/// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coursebuddy/constants/app_theme.dart';

class StudentQuizScreen extends StatefulWidget {
  final String quizId; // NOTE: updated to open a single quiz doc
  const StudentQuizScreen({super.key, required this.quizId});

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // questionIndex → chosen option
  int _score = 0;
  bool _submitted = false;

  Future<void> _submitResults(Map<String, dynamic> quizData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('quiz_submissions').add({
      'studentId': user.uid,
      'studentEmail': user.email,
      'quizId': widget.quizId,
      'courseId': quizData['courseId'],
      'score': _score,
      'answers': _selectedAnswers,
      'submittedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Quiz submitted successfully ✅")),
    );
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Quiz"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error"));
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Quiz not found 🕒"));
          }

          final quizData = snapshot.data!.data() as Map<String, dynamic>;
          final questions = List<Map<String, dynamic>>.from(
            quizData['questions'] ?? [],
          );
          if (questions.isEmpty) {
            return const Center(child: Text("No questions in this quiz 🕒"));
          }

          final question = questions[_currentIndex];
          final qText = question['q'] ?? "Untitled Question";
          final options = List<String>.from(question['options'] ?? []);
          final correctIndex = question['correctIndex'] ?? -1;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 8,
                  shadowColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Q${_currentIndex + 1}. $qText",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(options.length, (i) {
                          final selected = _selectedAnswers[_currentIndex];
                          final isCorrect = i == correctIndex;
                          Color? tileColor;

                          if (selected != null) {
                            if (i == selected && i == correctIndex) {
                              tileColor = Colors.green[100]; // ✅ correct
                            } else if (i == selected && i != correctIndex) {
                              tileColor = Colors.red[100]; // ❌ wrong
                            } else if (i == correctIndex) {
                              tileColor = Colors.green[50]; // highlight answer
                            }
                          }

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              tileColor: tileColor,
                              title: Text(options[i]),
                              onTap: selected == null
                                  ? () {
                                      setState(() {
                                        _selectedAnswers[_currentIndex] = i;
                                        if (i == correctIndex) _score++;
                                      });
                                    }
                                  : null,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_currentIndex < questions.length - 1)
                  ElevatedButton(
                    onPressed: _selectedAnswers[_currentIndex] == null
                        ? null
                        : () {
                            setState(() => _currentIndex++);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Next ➡️"),
                  )
                else if (!_submitted)
                  ElevatedButton(
                    onPressed: _selectedAnswers[_currentIndex] == null
                        ? null
                        : () => _submitResults(quizData),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Finish ✅"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
