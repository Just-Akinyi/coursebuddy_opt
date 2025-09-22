// make it so the student only sees approved notes from their enrolled courseId, not all courses
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentNotesScreen extends StatelessWidget {
  const StudentNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesRef = FirebaseFirestore.instance
        .collection('notes')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("Learning Materials")),
      body: StreamBuilder<QuerySnapshot>(
        stream: notesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("📭 No approved materials available"),
            );
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>? ?? {};

              final title = data['title'] ?? 'Untitled';
              final content = data['content'] ?? '';
              final createdAt = (data['createdAt'] is Timestamp)
                  ? (data['createdAt'] as Timestamp).toDate()
                  : null;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: ListTile(
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (createdAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "📅 ${createdAt.toLocal()}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class StudentNotesScreen extends StatelessWidget {
//   const StudentNotesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Learning Materials")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('notes')
//             .where('status', isEqualTo: 'approved')
//             .orderBy('createdAt', descending: true) // newest first
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No approved materials available"));
//           }

//           final docs = snapshot.data!.docs;
//           return ListView(
//             children: docs.map((doc) {
//               final data = doc.data() as Map<String, dynamic>;
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 child: ListTile(
//                   title: Text(data['title'] ?? ''),
//                   subtitle: Text(data['content'] ?? ''),
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_highlight/flutter_highlight.dart';
// import 'package:flutter_html/flutter_html.dart';

// class StudentLessonsScreen extends StatelessWidget {
//   const StudentLessonsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Lessons")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('notes')
//             .where("status", isEqualTo: "approved")
//             .orderBy("createdAt", descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data!.docs;

//           if (docs.isEmpty) {
//             return const Center(child: Text("No lessons available"));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;

//               final content = data["content"] ?? "";
//               final exampleCode = data["exampleCode"] ?? "";
//               final title = data["title"] ?? "Lesson";

//               return Card(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // 🔹 Title
//                       Text(title,
//                           style: Theme.of(context).textTheme.titleLarge),

//                       const SizedBox(height: 8),

//                       // 🔹 Explanation
//                       Text(content,
//                           style: Theme.of(context).textTheme.bodyMedium),

//                       const SizedBox(height: 16),

//                       // 🔹 Code Example
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: HighlightView(
//                           exampleCode,
//                           language: 'html',
//                           theme: {
//                             "root": TextStyle(color: Colors.black),
//                             "tag": TextStyle(color: Colors.blue),
//                             "attr": TextStyle(color: Colors.red),
//                           },
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       // 🔹 Output Preview
//                       Card(
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Html(data: exampleCode),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// // // This widget displays the **approved notes/materials** for a course.
// // // - Pulls from the top-level `notes/` collection.
// // // - Filters by `courseId` and `status == 'approved'`.
// // // - Supports both `text` and `code_output` note types.
// // //   - Text notes are shown as Markdown.
// // //   - Code_output notes show code (monospace) + terminal output.
// // // - Each note is ordered by `index`.

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';

// // class StudentMaterialsScreen extends StatelessWidget {
// //   final String courseId;

// //   const StudentMaterialsScreen({super.key, required this.courseId});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Course Materials')),
// //       body: StreamBuilder<QuerySnapshot>(
// //         stream: FirebaseFirestore.instance
// //             .collection('notes')
// //             .where('courseId', isEqualTo: courseId)
// //             .where('status', isEqualTo: 'approved')
// //             .orderBy('index')
// //             .snapshots(),
// //         builder: (context, snapshot) {
// //           if (snapshot.hasError) {
// //             return const Center(child: Text('Something went wrong'));
// //           }
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }

// //           final notes = snapshot.data?.docs ?? [];
// //           if (notes.isEmpty) {
// //             return const Center(child: Text('No materials approved yet.'));
// //           }

// //           return ListView.builder(
// //             itemCount: notes.length,
// //             itemBuilder: (context, index) {
// //               final note = notes[index].data() as Map<String, dynamic>;

// //               if (note['type'] == 'code_output') {
// //                 return Card(
// //                   margin:
// //                       const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(12),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(note['code'] ?? "",
// //                             style: const TextStyle(
// //                                 fontFamily: 'monospace',
// //                                 backgroundColor: Color(0xFFF0F0F0))),
// //                         const SizedBox(height: 6),
// //                         Text("➡️ Output:\n${note['output'] ?? ''}",
// //                             style: const TextStyle(color: Colors.green)),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //               }

// //               // Default to text note
// //               return ListTile(
// //                 leading: const Icon(Icons.description),
// //                 title: Text(note['content'] ?? "Empty note"),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
