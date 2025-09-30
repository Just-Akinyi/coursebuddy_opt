import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';

// --- Reusable Widgets ---

// 🪵 Story Widget
class MarkdownStory extends StatelessWidget {
  final String text;
  const MarkdownStory({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet(
        h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        p: const TextStyle(fontSize: 18, fontWeight: FontWeight.w200),
        listBullet: const TextStyle(fontSize: 16),
      ),
    );
  }
}

// 💻 Highlighted Code Block
class HighlightedCodeBlock extends StatelessWidget {
  final String code;
  const HighlightedCodeBlock({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return HighlightView(
      code,
      language: 'python',
      theme: githubTheme,
      padding: const EdgeInsets.all(12),
      textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 16),
    );
  }
}

// --- Admin Components ---

// 📝 Admin Lesson Card
class AdminLessonCard extends StatefulWidget {
  final DocumentSnapshot doc;
  final bool showActions;

  const AdminLessonCard({
    super.key,
    required this.doc,
    required this.showActions,
  });

  @override
  State<AdminLessonCard> createState() => _AdminLessonCardState();
}

class _AdminLessonCardState extends State<AdminLessonCard> {
  bool _showOutput = false;

  Widget _buildScrollableContent(Widget content, double maxHeight) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(child: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>?;
    if (data == null) return const SizedBox.shrink();

    final title = data["title"] ?? "Untitled Lesson";
    final story = data["story"] ?? "No story available";
    final code = data["code"] ?? "print('No code available')";
    final output = data["output"] ?? "No output available";
    final xpReward = data["xpReward"] ?? 0;
    final badges = List<String>.from(data["badges"] ?? []);
    final courseId = data["courseId"] ?? "Unknown Course";
    final status = data["status"] ?? "waiting_approval";
    final createdByEmail = data["createdByEmail"] ?? "unknown";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + XP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
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
                color: status == "approved" ? Colors.green : Colors.orange,
              ),
            ),
            Text(
              "Created by: $createdByEmail",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Badges
            if (badges.isNotEmpty)
              Wrap(
                spacing: 6,
                children: badges
                    .map(
                      (b) => Chip(
                        label: Text(b),
                        backgroundColor: Colors.amber.shade100,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            if (badges.isNotEmpty) const SizedBox(height: 12),

            // Story
            _buildScrollableContent(MarkdownStory(text: story), 150.0),
            const SizedBox(height: 12),

            // Code
            _buildScrollableContent(HighlightedCodeBlock(code: code), 120.0),
            const SizedBox(height: 12),

            // Run Code Button
            ElevatedButton.icon(
              onPressed: () => setState(() => _showOutput = !_showOutput),
              icon: Icon(_showOutput ? Icons.visibility_off : Icons.play_arrow),
              label: Text(_showOutput ? "Hide Output" : "Run Code"),
            ),
            const SizedBox(height: 12),

            // Output
            if (_showOutput)
              _buildScrollableContent(
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.greenAccent, width: 1.5),
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
                100.0,
              ),

            // Admin Actions
            if (widget.showActions)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () =>
                        widget.doc.reference.update({"status": "approved"}),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () =>
                        widget.doc.reference.update({"status": "rejected"}),
                  ),
                ],
              )
            else if (status == "rejected")
              IconButton(
                icon: const Icon(Icons.restore, color: Colors.orange),
                tooltip: "Restore to waiting",
                onPressed: () => widget.doc.reference
                    .update({"status": "waiting_approval"}),
              ),
          ],
        ),
      ),
    );
  }
}

// 📝 Admin Approval Screen
class AdminApprovalScreen extends StatelessWidget {
  const AdminApprovalScreen({super.key});

  Widget _buildSection({
    required String title,
    required String status,
    required bool showActions,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lessons')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("No $title"),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) =>
              AdminLessonCard(doc: docs[index], showActions: showActions),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            title: const Text(
              "Pending Lessons",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: [
              _buildSection(
                title: "Pending Lessons",
                status: "waiting_approval",
                showActions: true,
              ),
            ],
          ),
          ExpansionTile(
            title: const Text(
              "Approved Lessons",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: [
              _buildSection(
                title: "Approved Lessons",
                status: "approved",
                showActions: false,
              ),
            ],
          ),
          ExpansionTile(
            title: const Text(
              "Rejected Lessons",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: [
              _buildSection(
                title: "Rejected Lessons",
                status: "rejected",
                showActions: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:flutter_highlight/flutter_highlight.dart';
// import 'package:flutter_highlight/themes/github.dart';

// // --- Reusable Widgets ---

// // 🪵 Story Widget
// class MarkdownStory extends StatelessWidget {
//   final String text;
//   const MarkdownStory({super.key, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     // Note: Using MarkdownBody is usually better when the parent widget
//     // provides the scrolling/layout, but if Markdown is required for complex
//     // rendering, ensure it's constrained.
//     return MarkdownBody(
//       // Changed to MarkdownBody to avoid internal scrolling
//       data: text,
//       styleSheet: MarkdownStyleSheet(
//         h1: const TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           color: Colors.black87,
//         ),
//         h2: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: Colors.black87,
//         ),
//         p: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: Colors.black87,
//         ),
//         listBullet: const TextStyle(fontSize: 16, color: Colors.black87),
//       ),
//     );
//   }
// }

// // 💻 Highlighted Code Block
// class HighlightedCodeBlock extends StatelessWidget {
//   final String code;
//   const HighlightedCodeBlock({super.key, required this.code});

//   @override
//   Widget build(BuildContext context) {
//     // HighlightView is a non-scrolling widget; we rely on the parent
//     // (SingleChildScrollView) to handle overflow.
//     return HighlightView(
//       code,
//       language: 'python',
//       theme: githubTheme,
//       padding: const EdgeInsets.all(12),
//       textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 16),
//     );
//   }
// }

// // --- Admin Components ---

// // 📝 Admin Lesson Card
// class AdminLessonCard extends StatefulWidget {
//   final DocumentSnapshot doc;
//   final bool showActions;

//   const AdminLessonCard({
//     super.key,
//     required this.doc,
//     required this.showActions,
//   });

//   @override
//   State<AdminLessonCard> createState() => _AdminLessonCardState();
// }

// class _AdminLessonCardState extends State<AdminLessonCard> {
//   bool _showOutput = false;

//   // Utility method to wrap scrollable content with constraints
//   Widget _buildScrollableContent(Widget content, double maxHeight) {
//     return Container(
//       constraints: BoxConstraints(maxHeight: maxHeight),
//       // This SingleChildScrollView now directly wraps the content,
//       // ensuring the content only scrolls within the maxHeight boundary.
//       child: SingleChildScrollView(child: content),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final data = widget.doc.data() as Map<String, dynamic>?;
//     if (data == null) return const SizedBox.shrink();

//     final title = data["title"] ?? "Untitled Lesson";
//     final story = data["story"] ?? "No story available";
//     final code = data["code"] ?? "print('No code available')";
//     final output = data["output"] ?? "No output available";
//     final xpReward = data["xpReward"] ?? 0;
//     final badges = List<String>.from(data["badges"] ?? []);
//     final courseId = data["courseId"] ?? "Unknown Course";
//     final status = data["status"] ?? "waiting_approval";
//     final createdBy = data["createdByEmail"] ?? "unknown";

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title + XP
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Chip(
//                   label: Text("$xpReward XP"),
//                   backgroundColor: Colors.green.shade100,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               "Course: $courseId • Status: $status",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: status == "approved" ? Colors.green : Colors.orange,
//               ),
//             ),
//             Text(
//               "Created by: $createdBy",
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),

//             // Badges
//             if (badges.isNotEmpty)
//               Wrap(
//                 spacing: 6,
//                 children: badges
//                     .map(
//                       (b) => Chip(
//                         label: Text(b),
//                         backgroundColor: Colors.amber.shade100,
//                         visualDensity: VisualDensity.compact,
//                       ),
//                     )
//                     .toList(),
//               ),
//             if (badges.isNotEmpty) const SizedBox(height: 12),

//             // Story (FIX: Use wrapper function to constrain scroll)
//             _buildScrollableContent(MarkdownStory(text: story), 150.0),
//             const SizedBox(height: 12),

//             // Code (FIX: Use wrapper function to constrain scroll)
//             _buildScrollableContent(HighlightedCodeBlock(code: code), 120.0),
//             const SizedBox(height: 12),

//             // Run Code Button
//             ElevatedButton.icon(
//               onPressed: () => setState(() => _showOutput = !_showOutput),
//               icon: Icon(_showOutput ? Icons.visibility_off : Icons.play_arrow),
//               label: Text(_showOutput ? "Hide Output" : "Run Code"),
//             ),
//             const SizedBox(height: 12),

//             // Output (FIX: Use wrapper function to constrain scroll)
//             if (_showOutput)
//               _buildScrollableContent(
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Colors.greenAccent, width: 1.5),
//                   ),
//                   child: SelectableText(
//                     output,
//                     style: const TextStyle(
//                       fontFamily: 'monospace',
//                       fontSize: 16,
//                       color: Colors.greenAccent,
//                     ),
//                   ),
//                 ),
//                 100.0,
//               ),

//             // Admin Actions
//             if (widget.showActions)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.check, color: Colors.green),
//                     onPressed: () =>
//                         widget.doc.reference.update({"status": "approved"}),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.red),
//                     onPressed: () =>
//                         widget.doc.reference.update({"status": "rejected"}),
//                   ),
//                 ],
//               )
//             else if (status == "rejected")
//               IconButton(
//                 icon: const Icon(Icons.restore, color: Colors.orange),
//                 tooltip: "Restore to waiting",
//                 onPressed: () =>
//                     widget.doc.reference.update({"status": "waiting_approval"}),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 📝 Admin Approval Screen
// class AdminApprovalScreen extends StatelessWidget {
//   const AdminApprovalScreen({super.key});

//   Widget _buildSection({
//     required String title,
//     required String status,
//     required bool showActions,
//   }) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('lessons')
//           .where('status', isEqualTo: status)
//           .orderBy('createdAt', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Padding(
//             padding: EdgeInsets.all(12),
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }

//         final docs = snapshot.data!.docs;
//         if (docs.isEmpty) {
//           return Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Text("No $title"),
//           );
//         }

//         return ListView.builder(
//           // These two properties are essential for nested list views inside the parent ListView
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: docs.length,
//           itemBuilder: (context, index) =>
//               AdminLessonCard(doc: docs[index], showActions: showActions),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       // The main scrollable area
//       children: [
//         ExpansionTile(
//           title: const Text(
//             "Pending Lessons",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           children: [
//             _buildSection(
//               title: "Pending Lessons",
//               status: "waiting_approval",
//               showActions: true,
//             ),
//           ],
//         ),
//         ExpansionTile(
//           title: const Text(
//             "Approved Lessons",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           children: [
//             _buildSection(
//               title: "Approved Lessons",
//               status: "approved",
//               showActions: false,
//             ),
//           ],
//         ),
//         ExpansionTile(
//           title: const Text(
//             "Rejected Lessons",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           children: [
//             _buildSection(
//               title: "Rejected Lessons",
//               status: "rejected",
//               showActions: false,
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter_markdown/flutter_markdown.dart';
// // import 'package:flutter_highlight/flutter_highlight.dart';
// // import 'package:flutter_highlight/themes/github.dart';

// // // 🪵 Story Widget
// // class MarkdownStory extends StatelessWidget {
// //   final String text;
// //   const MarkdownStory({super.key, required this.text});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Markdown(
// //       data: text,
// //       shrinkWrap: true,
// //       styleSheet: MarkdownStyleSheet(
// //         h1: const TextStyle(
// //           fontSize: 24,
// //           fontWeight: FontWeight.bold,
// //           color: Colors.black87,
// //         ),
// //         h2: const TextStyle(
// //           fontSize: 20,
// //           fontWeight: FontWeight.w600,
// //           color: Colors.black87,
// //         ),
// //         p: const TextStyle(
// //           fontSize: 18,
// //           fontWeight: FontWeight.w600,
// //           color: Colors.black87,
// //         ),
// //         listBullet: const TextStyle(fontSize: 16, color: Colors.black87),
// //       ),
// //     );
// //   }
// // }

// // // 💻 Highlighted Code Block
// // class HighlightedCodeBlock extends StatelessWidget {
// //   final String code;
// //   const HighlightedCodeBlock({super.key, required this.code});

// //   @override
// //   Widget build(BuildContext context) {
// //     return HighlightView(
// //       code,
// //       language: 'python',
// //       theme: githubTheme,
// //       padding: const EdgeInsets.all(12),
// //       textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 16),
// //     );
// //   }
// // }

// // // 📝 Admin Lesson Card
// // class AdminLessonCard extends StatefulWidget {
// //   final DocumentSnapshot doc;
// //   final bool showActions;

// //   const AdminLessonCard({
// //     super.key,
// //     required this.doc,
// //     required this.showActions,
// //   });

// //   @override
// //   State<AdminLessonCard> createState() => _AdminLessonCardState();
// // }

// // class _AdminLessonCardState extends State<AdminLessonCard> {
// //   bool _showOutput = false;

// //   @override
// //   Widget build(BuildContext context) {
// //     final data = widget.doc.data() as Map<String, dynamic>;
// //     final title = data["title"] ?? "Untitled Lesson";
// //     final story = data["story"] ?? "No story available";
// //     final code = data["code"] ?? "print('No code available')";
// //     final output = data["output"] ?? "No output available";
// //     final xpReward = data["xpReward"] ?? 0;
// //     final badges = List<String>.from(data["badges"] ?? []);
// //     final courseId = data["courseId"] ?? "Unknown Course";
// //     final status = data["status"] ?? "waiting_approval";
// //     final createdBy = data["createdByEmail"] ?? "unknown";

// //     return Card(
// //       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
// //       elevation: 3,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       child: Container(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Title + XP
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(
// //                   title,
// //                   style: const TextStyle(
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 Chip(
// //                   label: Text("$xpReward XP"),
// //                   backgroundColor: Colors.green.shade100,
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               "Course: $courseId • Status: $status",
// //               style: TextStyle(
// //                 fontSize: 14,
// //                 color: status == "approved" ? Colors.green : Colors.orange,
// //               ),
// //             ),
// //             Text(
// //               "Created by: $createdBy",
// //               style: const TextStyle(fontSize: 12, color: Colors.grey),
// //             ),
// //             const SizedBox(height: 8),

// //             // Badges
// //             if (badges.isNotEmpty)
// //               Wrap(
// //                 spacing: 6,
// //                 children: badges
// //                     .map(
// //                       (b) => Chip(
// //                         label: Text(b),
// //                         backgroundColor: Colors.amber.shade100,
// //                         visualDensity: VisualDensity.compact,
// //                       ),
// //                     )
// //                     .toList(),
// //               ),
// //             if (badges.isNotEmpty) const SizedBox(height: 12),

// //             // Story
// //             Container(
// //               constraints: const BoxConstraints(maxHeight: 150),
// //               child: SingleChildScrollView(child: MarkdownStory(text: story)),
// //             ),
// //             const SizedBox(height: 12),

// //             // Code
// //             Container(
// //               constraints: const BoxConstraints(maxHeight: 120),
// //               child: SingleChildScrollView(
// //                 child: HighlightedCodeBlock(code: code),
// //               ),
// //             ),
// //             const SizedBox(height: 12),

// //             // Run Code Button
// //             ElevatedButton.icon(
// //               onPressed: () => setState(() => _showOutput = !_showOutput),
// //               icon: Icon(_showOutput ? Icons.visibility_off : Icons.play_arrow),
// //               label: Text(_showOutput ? "Hide Output" : "Run Code"),
// //             ),
// //             const SizedBox(height: 12),

// //             // Output
// //             if (_showOutput)
// //               Container(
// //                 constraints: const BoxConstraints(maxHeight: 100),
// //                 child: SingleChildScrollView(
// //                   child: Container(
// //                     width: double.infinity,
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.black,
// //                       borderRadius: BorderRadius.circular(10),
// //                       border: Border.all(color: Colors.greenAccent, width: 1.5),
// //                     ),
// //                     child: SelectableText(
// //                       output,
// //                       style: const TextStyle(
// //                         fontFamily: 'monospace',
// //                         fontSize: 16,
// //                         color: Colors.greenAccent,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),

// //             // Admin Actions
// //             if (widget.showActions)
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.end,
// //                 children: [
// //                   IconButton(
// //                     icon: const Icon(Icons.check, color: Colors.green),
// //                     onPressed: () =>
// //                         widget.doc.reference.update({"status": "approved"}),
// //                   ),
// //                   IconButton(
// //                     icon: const Icon(Icons.close, color: Colors.red),
// //                     onPressed: () =>
// //                         widget.doc.reference.update({"status": "rejected"}),
// //                   ),
// //                 ],
// //               )
// //             else if (status == "rejected")
// //               IconButton(
// //                 icon: const Icon(Icons.restore, color: Colors.orange),
// //                 tooltip: "Restore to waiting",
// //                 onPressed: () =>
// //                     widget.doc.reference.update({"status": "waiting_approval"}),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // 📝 Admin Approval Screen
// // class AdminApprovalScreen extends StatelessWidget {
// //   const AdminApprovalScreen({super.key});

// //   Widget _buildSection({
// //     required String title,
// //     required String status,
// //     required bool showActions,
// //   }) {
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: FirebaseFirestore.instance
// //           .collection('lessons')
// //           .where('status', isEqualTo: status)
// //           .orderBy('createdAt', descending: true)
// //           .snapshots(),
// //       builder: (context, snapshot) {
// //         if (!snapshot.hasData) {
// //           return const Padding(
// //             padding: EdgeInsets.all(12),
// //             child: Center(child: CircularProgressIndicator()),
// //           );
// //         }

// //         final docs = snapshot.data!.docs;
// //         if (docs.isEmpty) {
// //           return Padding(
// //             padding: const EdgeInsets.all(12.0),
// //             child: Text("No $title"),
// //           );
// //         }

// //         return ListView.builder(
// //           shrinkWrap: true,
// //           physics: const NeverScrollableScrollPhysics(),
// //           itemCount: docs.length,
// //           itemBuilder: (context, index) =>
// //               AdminLessonCard(doc: docs[index], showActions: showActions),
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Admin Approval")),
// //       body: ListView(
// //         children: [
// //           ExpansionTile(
// //             title: const Text(
// //               "Pending Lessons",
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             children: [
// //               _buildSection(
// //                 title: "Pending Lessons",
// //                 status: "waiting_approval",
// //                 showActions: true,
// //               ),
// //             ],
// //           ),
// //           ExpansionTile(
// //             title: const Text(
// //               "Approved Lessons",
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             children: [
// //               _buildSection(
// //                 title: "Approved Lessons",
// //                 status: "approved",
// //                 showActions: false,
// //               ),
// //             ],
// //           ),
// //           ExpansionTile(
// //             title: const Text(
// //               "Rejected Lessons",
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             children: [
// //               _buildSection(
// //                 title: "Rejected Lessons",
// //                 status: "rejected",
// //                 showActions: false,
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // class AdminApprovalScreen extends StatelessWidget {
// // //   const AdminApprovalScreen({super.key});

// // //   Widget _buildSection({
// // //     required String title,
// // //     required String status,
// // //     required bool showActions,
// // //   }) {
// // //     return ExpansionTile(
// // //       initiallyExpanded: false, // 🔹 collapsed by default
// // //       title: Text(title,
// // //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // //       children: [
// // //         StreamBuilder<QuerySnapshot>(
// // //           stream: FirebaseFirestore.instance
// // //               .collection('notes')
// // //               .where('status', isEqualTo: status)
// // //               .snapshots(),
// // //           builder: (context, snapshot) {
// // //             if (snapshot.connectionState == ConnectionState.waiting) {
// // //               return const Padding(
// // //                 padding: EdgeInsets.all(12.0),
// // //                 child: Center(child: CircularProgressIndicator()),
// // //               );
// // //             }
// // //             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// // //               return Padding(
// // //                 padding: const EdgeInsets.all(12.0),
// // //                 child: Text("No $title"),
// // //               );
// // //             }

// // //             final docs = snapshot.data!.docs;
// // //             return ListView.builder(
// // //               shrinkWrap: true,
// // //               physics: const NeverScrollableScrollPhysics(),
// // //               itemCount: docs.length,
// // //               itemBuilder: (context, index) {
// // //                 final doc = docs[index];
// // //                 final data = doc.data() as Map<String, dynamic>;
// // //                 return Card(
// // //                   margin:
// // //                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// // //                   child: ListTile(
// // //                     title: Text(data['title'] ?? ''),
// // //                     subtitle: Text(data['content'] ?? ''),
// // //                     trailing: showActions
// // //                         ? Row(
// // //                             mainAxisSize: MainAxisSize.min,
// // //                             children: [
// // //                               IconButton(
// // //                                 icon: const Icon(Icons.check,
// // //                                     color: Colors.green),
// // //                                 onPressed: () {
// // //                                   doc.reference.update({"status": "approved"});
// // //                                 },
// // //                               ),
// // //                               IconButton(
// // //                                 icon:
// // //                                     const Icon(Icons.close, color: Colors.red),
// // //                                 onPressed: () {
// // //                                   doc.reference.update({"status": "rejected"});
// // //                                 },
// // //                               ),
// // //                             ],
// // //                           )
// // //                         : (status == "rejected"
// // //                             ? IconButton(
// // //                                 icon: const Icon(Icons.restore,
// // //                                     color: Colors.orange),
// // //                                 tooltip: "Restore to waiting",
// // //                                 onPressed: () {
// // //                                   doc.reference
// // //                                       .update({"status": "waiting_approval"});
// // //                                 },
// // //                               )
// // //                             : null),
// // //                   ),
// // //                 );
// // //               },
// // //             );
// // //           },
// // //         ),
// // //         const SizedBox(height: 12),
// // //       ],
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Column(
// // //       children: [
// // //         _buildSection(
// // //           title: "Pending Materials",
// // //           status: "waiting_approval",
// // //           showActions: true,
// // //         ),
// // //         _buildSection(
// // //           title: "Approved Materials",
// // //           status: "approved",
// // //           showActions: false,
// // //         ),
// // //         _buildSection(
// // //           title: "Rejected Materials",
// // //           status: "rejected",
// // //           showActions: false,
// // //         ),
// // //       ],
// // //     );
// // //   }
// // // }

// // // // import 'package:flutter/material.dart';
// // // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // // class AdminApprovalScreen extends StatelessWidget {
// // // //   const AdminApprovalScreen({super.key});

// // // //   Future<void> _updateStatus(String docId, String status) async {
// // // //     await FirebaseFirestore.instance
// // // //         .collection('notes')
// // // //         .doc(docId)
// // // //         .update({"status": status});
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(title: const Text("Approve Materials")),
// // // //       body: StreamBuilder<QuerySnapshot>(
// // // //         stream: FirebaseFirestore.instance
// // // //             .collection('notes')
// // // //             .where("status", isEqualTo: "waiting_approval")
// // // //             .snapshots(),
// // // //         builder: (context, snapshot) {
// // // //           if (!snapshot.hasData) {
// // // //             return const Center(child: CircularProgressIndicator());
// // // //           }

// // // //           final docs = snapshot.data!.docs;

// // // //           if (docs.isEmpty) {
// // // //             return const Center(child: Text("No pending approvals"));
// // // //           }

// // // //           return ListView.builder(
// // // //             padding: const EdgeInsets.all(12),
// // // //             itemCount: docs.length,
// // // //             itemBuilder: (context, index) {
// // // //               final doc = docs[index];
// // // //               final data = doc.data() as Map<String, dynamic>;

// // // //               return Card(
// // // //                 margin: const EdgeInsets.only(bottom: 12),
// // // //                 child: ListTile(
// // // //                   title: Text(data["title"] ?? "Untitled"),
// // // //                   subtitle: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       Text(data["content"] ?? ""),
// // // //                       const SizedBox(height: 8),
// // // //                       Text(
// // // //                         data["exampleCode"] ?? "",
// // // //                         style: const TextStyle(
// // // //                           fontFamily: "monospace",
// // // //                           color: Colors.blueGrey,
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                   isThreeLine: true,
// // // //                   trailing: Row(
// // // //                     mainAxisSize: MainAxisSize.min,
// // // //                     children: [
// // // //                       IconButton(
// // // //                         icon: const Icon(Icons.check_circle, color: Colors.green),
// // // //                         onPressed: () => _updateStatus(doc.id, "approved"),
// // // //                       ),
// // // //                       IconButton(
// // // //                         icon: const Icon(Icons.cancel, color: Colors.red),
// // // //                         onPressed: () => _updateStatus(doc.id, "rejected"),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //               );
// // // //             },
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }
// // // // }
