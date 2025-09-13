/// QuizUploadScreen
/// ----------------
/// Screen for teachers to create and upload new quizzes.
/// Each quiz doc is stored in `quizzes/` collection.
/// Schema:
/// {
///   "courseId": "python",
///   "title": "Math Basics",
///   "questions": [
///     {
///       "q": "What is 2+2?",
///       "options": ["3", "4", "5", "6"],
///       "correctIndex": 1
///     }
///   ],
///   "status": "waiting_approval", // Admin will later approve/reject
///   "createdAt": Timestamp
/// }
///
/// Features:
/// - Teacher can set quiz title + courseId.
/// - Teacher can add multiple questions.
/// - Each question has text, multiple options, and correct answer index.
/// - Submits quiz to Firestore with `waiting_approval` status.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:coursebuddy/constants/app_theme.dart';

class QuizUploadScreen extends StatefulWidget {
  const QuizUploadScreen({super.key});

  @override
  State<QuizUploadScreen> createState() => _QuizUploadScreenState();
}

class _QuizUploadScreenState extends State<QuizUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseIdController = TextEditingController();

  final List<Map<String, dynamic>> _questions = [];

  void _addQuestion() {
    setState(() {
      _questions.add({
        "q": "",
        "options": ["", "", "", ""],
        "correctIndex": 0,
      });
    });
  }

  Future<void> _submitQuiz() async {
    if (!_formKey.currentState!.validate() || _questions.isEmpty) return;

    await FirebaseFirestore.instance.collection('quizzes').add({
      "courseId": _courseIdController.text.trim(),
      "title": _titleController.text.trim(),
      "questions": _questions,
      "status": "waiting_approval",
      "createdAt": FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Quiz submitted (waiting approval) ✅")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Quiz"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Quiz Title"),
              validator: (v) =>
                  v == null || v.isEmpty ? "Enter quiz title" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _courseIdController,
              decoration: const InputDecoration(labelText: "Course ID"),
              validator: (v) =>
                  v == null || v.isEmpty ? "Enter course ID" : null,
            ),
            const SizedBox(height: 20),
            const Text("Questions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._questions.asMap().entries.map((entry) {
              final qIndex = entry.key;
              final qData = entry.value;
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: qData["q"],
                        decoration: InputDecoration(
                            labelText: "Question ${qIndex + 1}"),
                        onChanged: (val) => qData["q"] = val,
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(4, (i) {
                        return TextFormField(
                          initialValue: qData["options"][i],
                          decoration:
                              InputDecoration(labelText: "Option ${i + 1}"),
                          onChanged: (val) => qData["options"][i] = val,
                        );
                      }),
                      const SizedBox(height: 8),
                      DropdownButton<int>(
                        value: qData["correctIndex"],
                        items: List.generate(4, (i) {
                          return DropdownMenuItem(
                            value: i,
                            child: Text("Correct Answer: Option ${i + 1}"),
                          );
                        }),
                        onChanged: (val) {
                          setState(() {
                            qData["correctIndex"] = val ?? 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("➕ Add Question"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Submit Quiz"),
            ),
          ],
        ),
      ),
    );
  }
}
