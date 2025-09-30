import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursebuddy/constants/app_theme.dart';
// import 'add_course.dart'; // ✅ Import your AddCourseScreen

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coursesRef = FirebaseFirestore.instance.collection('courses');

    return StreamBuilder<QuerySnapshot>(
      stream: coursesRef.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No courses found"),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'] ?? doc.id;
            final desc = data['description'] ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.book),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(desc),
                trailing: PopupMenuButton<String>(
                  onSelected: (choice) async {
                    if (choice == "delete") {
                      await doc.reference.delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Course '$title' deleted")),
                      );
                    } else if (choice == "edit") {
                      _showEditDialog(context, doc.id, data);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "edit", child: Text("Edit")),
                    PopupMenuItem(value: "delete", child: Text("Delete")),
                  ],
                ),
              ),
            );
          },
        );
      },
    ); // ✅ Removed one extra parenthesis here
  }

  void _showEditDialog(
    BuildContext context,
    String courseId,
    Map<String, dynamic> data,
  ) {
    final titleController = TextEditingController(
      text: data['title'] ?? courseId,
    );
    final descController = TextEditingController(
      text: data['description'] ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Course"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = titleController.text.trim();
              final newDesc = descController.text.trim();
              if (newTitle.isEmpty) return;

              final courseRef = FirebaseFirestore.instance
                  .collection('courses')
                  .doc(courseId);

              if (newTitle != courseId) {
                final newRef = FirebaseFirestore.instance
                    .collection('courses')
                    .doc(newTitle);

                final exists = await newRef.get();
                if (exists.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Course '$newTitle' already exists"),
                    ),
                  );
                  return;
                }

                await newRef.set({
                  "title": newTitle,
                  "description": newDesc,
                  "createdAt":
                      data['createdAt'] ?? FieldValue.serverTimestamp(),
                  "updatedAt": FieldValue.serverTimestamp(),
                });
                await courseRef.delete();
              } else {
                await courseRef.update({
                  "description": newDesc,
                  "updatedAt": FieldValue.serverTimestamp(),
                });
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
