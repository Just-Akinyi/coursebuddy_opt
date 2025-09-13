/// This widget displays the **approved notes/materials** for a course.
/// - Pulls from the top-level `notes/` collection.
/// - Filters by `courseId` and `status == 'approved'`.
/// - Supports both `text` and `code_output` note types.
///   - Text notes are shown as Markdown.
///   - Code_output notes show code (monospace) + terminal output.
/// - Each note is ordered by `index`.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentMaterialsScreen extends StatelessWidget {
  final String courseId;

  const StudentMaterialsScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Materials')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .where('courseId', isEqualTo: courseId)
            .where('status', isEqualTo: 'approved')
            .orderBy('index')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data?.docs ?? [];
          if (notes.isEmpty) {
            return const Center(child: Text('No materials approved yet.'));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index].data() as Map<String, dynamic>;

              if (note['type'] == 'code_output') {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note['code'] ?? "",
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                backgroundColor: Color(0xFFF0F0F0))),
                        const SizedBox(height: 6),
                        Text("➡️ Output:\n${note['output'] ?? ''}",
                            style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                );
              }

              // Default to text note
              return ListTile(
                leading: const Icon(Icons.description),
                title: Text(note['content'] ?? "Empty note"),
              );
            },
          );
        },
      ),
    );
  }
}
