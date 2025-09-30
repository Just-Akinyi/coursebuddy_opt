import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🪵 Story Widget
class MarkdownStory extends StatelessWidget {
  final String text;
  const MarkdownStory({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD7A86E), Color(0xFFEAD196)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown, width: 2),
        boxShadow: [
          BoxShadow(
            // color: Colors.brown.withOpacity(0.3),
            color: Colors.brown.withAlpha((0.3 * 255).round()),
            blurRadius: 6,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: MarkdownBody(
        data: text,
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          h2: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          p: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          listBullet: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}

// 💻 Highlighted Code
class HighlightedCodeBlock extends StatelessWidget {
  final String code;
  const HighlightedCodeBlock({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.greenAccent, width: 1.5),
      ),
      child: HighlightView(
        code,
        language: 'python',
        theme: githubTheme,
        padding: const EdgeInsets.all(12),
        textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 16),
      ),
    );
  }
}

// 📚 LessonCard auto-filters by logged-in student's courseId
class LessonCard extends StatefulWidget {
  const LessonCard({super.key});

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  bool _showOutput = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    final userDoc = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: userDoc,
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnap.data!.exists) {
          return const Center(child: Text("No user profile found"));
        }

        final userData = userSnap.data!.data() as Map<String, dynamic>;
        final courseId = userData["courseId"];

        if (courseId == null) {
          return const Center(child: Text("No course assigned"));
        }

        final lessonsRef = FirebaseFirestore.instance
            .collection('lessons')
            .where('status', isEqualTo: 'approved')
            .where('courseId', isEqualTo: courseId)
            .orderBy('createdAt', descending: true);

        return StreamBuilder<QuerySnapshot>(
          stream: lessonsRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(
                child: Text("No lessons available for your course"),
              );
            }

            // ✅ Now scrolls properly
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;

                final title = data["title"] ?? "Untitled Lesson";
                final story = data["story"] ?? "No story available";
                final code = data["code"] ?? "print('No code available')";
                final output = data["output"] ?? "No output available";
                final xpReward = data["xpReward"] ?? 0;
                final courseId = data["courseId"] ?? "Unknown Course";
                final status = data["status"] ?? "waiting_for_approval";
                final createdBy = data["createdByEmail"] ?? "unknown";

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📌 Title + XP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text("$xpReward XP"),
                              backgroundColor: Colors.green.shade100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Course: $courseId • Status: $status",
                          style: TextStyle(
                            fontSize: 14,
                            color: status == "approved"
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        Text(
                          "Created by: $createdBy",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 🪵 Story
                        MarkdownStory(text: story),
                        const SizedBox(height: 16),

                        // 💻 Code
                        HighlightedCodeBlock(code: code),
                        const SizedBox(height: 12),

                        // ▶ Run button
                        ElevatedButton.icon(
                          onPressed: () =>
                              setState(() => _showOutput = !_showOutput),
                          icon: Icon(
                            _showOutput
                                ? Icons.visibility_off
                                : Icons.play_arrow,
                          ),
                          label: Text(_showOutput ? "Hide Output" : "Run Code"),
                        ),
                        const SizedBox(height: 16),

                        // 📟 Output
                        if (_showOutput)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.greenAccent,
                                width: 1.5,
                              ),
                            ),
                            child: SelectableText(
                              output,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 16,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
