import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MaterialUploadScreen extends StatefulWidget {
  const MaterialUploadScreen({super.key});

  @override
  State<MaterialUploadScreen> createState() => _MaterialUploadScreenState();
}

// 📚 Data structure for the Course (for dropdown items)
class CourseOption {
  final String id;
  final String title;

  CourseOption(this.id, this.title);
}

class _MaterialUploadScreenState extends State<MaterialUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _codeController = TextEditingController();
  
  // ✅ NEW STATE: Selected Course ID
  String? _selectedCourseId;
  
  // ✅ NEW STATE: for other required fields
  final _xpRewardController = TextEditingController();
  final _outputController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _xpRewardController.text = '10'; // Default XP reward
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _codeController.dispose();
    _xpRewardController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  Future<void> _uploadMaterial() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a course.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use the document structure provided in the prompt
      await FirebaseFirestore.instance.collection('lessons').add({
        "title": _titleController.text.trim(),
        "story": _contentController.text.trim(), // Assuming content maps to 'story'
        "code": _codeController.text.trim(), // Assuming exampleCode maps to 'code'
        "output": _outputController.text.trim(), // Output field added
        "xpReward": int.tryParse(_xpRewardController.text.trim()) ?? 10, // XP field added
        "courseId": _selectedCourseId, // ✅ CRITICAL: Link to the course
        "status": "waiting_approval",
        "createdAt": FieldValue.serverTimestamp(),
        "createdBy": FirebaseAuth.instance.currentUser?.uid ?? "unknown",
        "createdByEmail":
            FirebaseAuth.instance.currentUser?.email ?? "unknown",
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Material uploaded for approval")),
      );

      _titleController.clear();
      _contentController.clear();
      _codeController.clear();
      _outputController.clear();
      _xpRewardController.text = '10';
      setState(() {
        _selectedCourseId = null;
      });
    } catch (e) {
      if (!mounted) return;
      // Enhanced error logging for debugging
      print("Firestore Upload Error: $e"); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Upload failed: check your permissions or network.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Material")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 🔹 Course Dropdown (fetches data from Firestore)
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('courses').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error loading courses: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No courses available.');
                  }

                  final courses = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return CourseOption(doc.id, data['title'] ?? 'Untitled Course');
                  }).toList();

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Select Course",
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCourseId,
                    hint: const Text("Choose a Course"),
                    items: courses.map((course) {
                      return DropdownMenuItem(
                        value: course.id,
                        child: Text(course.title),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCourseId = newValue;
                      });
                    },
                    validator: (v) => v == null ? "Select a course" : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // 🔹 Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter a title" : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Content (Story)
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Content (story/explanation)", // Renamed label to match document field
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter lesson content" : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Example Code
              TextFormField(
                controller: _codeController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: "Example Code", // Maps to 'code'
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter example code" : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Output
              TextFormField(
                controller: _outputController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Expected Output", // Maps to 'output'
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter expected output" : null,
              ),
              const SizedBox(height: 16),
              
              // 🔹 XP Reward
              TextFormField(
                controller: _xpRewardController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "XP Reward", // Maps to 'xpReward'
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter XP reward";
                  if (int.tryParse(v) == null) return "Must be a number";
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 🔹 Upload Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _uploadMaterial,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload),
                label: const Text("Upload"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class MaterialUploadScreen extends StatefulWidget {
//   const MaterialUploadScreen({super.key});

//   @override
//   State<MaterialUploadScreen> createState() => _MaterialUploadScreenState();
// }

// class _MaterialUploadScreenState extends State<MaterialUploadScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _contentController = TextEditingController();
//   final _codeController = TextEditingController();

//   bool _isLoading = false;

//   Future<void> _uploadMaterial() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       await FirebaseFirestore.instance.collection('lessons').add({
//         "title": _titleController.text.trim(),
//         "content": _contentController.text.trim(),
//         "exampleCode": _codeController.text.trim(),
//         "status": "waiting_approval", // teachers always upload as waiting
//         "createdAt": FieldValue.serverTimestamp(),
//         "createdBy": FirebaseAuth.instance.currentUser?.uid ?? "unknown",
//         "createdByEmail":
//             FirebaseAuth.instance.currentUser?.email ?? "unknown",
//       });
//       if (!mounted) return; 
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ Material uploaded for approval")),
//       );

//       _titleController.clear();
//       _contentController.clear();
//       _codeController.clear();
//     } catch (e) {
//       if (!mounted) return; 
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("❌ Upload failed: check your permissions.")),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Upload Material")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               // 🔹 Title
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: "Title",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                     v == null || v.isEmpty ? "Enter a title" : null,
//               ),
//               const SizedBox(height: 16),

//               // 🔹 Content
//               TextFormField(
//                 controller: _contentController,
//                 maxLines: 5,
//                 decoration: const InputDecoration(
//                   labelText: "Content (explanation)",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                     v == null || v.isEmpty ? "Enter lesson content" : null,
//               ),
//               const SizedBox(height: 16),

//               // 🔹 Example Code
//               TextFormField(
//                 controller: _codeController,
//                 maxLines: 8,
//                 decoration: const InputDecoration(
//                   labelText: "Example Code",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                     v == null || v.isEmpty ? "Enter example code" : null,
//               ),
//               const SizedBox(height: 24),

//               // 🔹 Upload Button
//               ElevatedButton.icon(
//                 onPressed: _isLoading ? null : _uploadMaterial,
//                 icon: _isLoading
//                     ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                     : const Icon(Icons.upload),
//                 label: const Text("Upload"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';

// // class MaterialUploadScreen extends StatefulWidget {
// //   const MaterialUploadScreen({super.key});

// //   @override
// //   State<MaterialUploadScreen> createState() => _MaterialUploadScreenState();
// // }

// // class _MaterialUploadScreenState extends State<MaterialUploadScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _titleController = TextEditingController();
// //   final _contentController = TextEditingController();
// //   final _codeController = TextEditingController();

// //   bool _isLoading = false;

// //   Future<void> _uploadMaterial() async {
// //     if (!_formKey.currentState!.validate()) return;

// //     setState(() => _isLoading = true);

// //     try {
// //       await FirebaseFirestore.instance.collection('notes').add({
// //         "title": _titleController.text.trim(),
// //         "content": _contentController.text.trim(),
// //         "exampleCode": _codeController.text.trim(),
// //         "status": "waiting_approval", // admin will update later
// //         "createdAt": FieldValue.serverTimestamp(),
// //         "createdBy": FirebaseAuth.instance.currentUser?.email ?? "unknown",
// //       });

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("✅ Material uploaded for approval")),
// //       );

// //       _titleController.clear();
// //       _contentController.clear();
// //       _codeController.clear();
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("❌ Upload failed: $e")),
// //       );
// //     } finally {
// //       setState(() => _isLoading = false);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Upload Material")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Form(
// //           key: _formKey,
// //           child: ListView(
// //             children: [
// //               // 🔹 Title
// //               TextFormField(
// //                 controller: _titleController,
// //                 decoration: const InputDecoration(
// //                   labelText: "Title",
// //                   border: OutlineInputBorder(),
// //                 ),
// //                 validator: (v) =>
// //                     v == null || v.isEmpty ? "Enter a title" : null,
// //               ),
// //               const SizedBox(height: 16),

// //               // 🔹 Content
// //               TextFormField(
// //                 controller: _contentController,
// //                 maxLines: 5,
// //                 decoration: const InputDecoration(
// //                   labelText: "Content (explanation)",
// //                   border: OutlineInputBorder(),
// //                 ),
// //                 validator: (v) =>
// //                     v == null || v.isEmpty ? "Enter lesson content" : null,
// //               ),
// //               const SizedBox(height: 16),

// //               // 🔹 Example Code
// //               TextFormField(
// //                 controller: _codeController,
// //                 maxLines: 8,
// //                 decoration: const InputDecoration(
// //                   labelText: "Example Code",
// //                   border: OutlineInputBorder(),
// //                 ),
// //                 validator: (v) =>
// //                     v == null || v.isEmpty ? "Enter example code" : null,
// //               ),
// //               const SizedBox(height: 24),

// //               // 🔹 Upload Button
// //               ElevatedButton.icon(
// //                 onPressed: _isLoading ? null : _uploadMaterial,
// //                 icon: _isLoading
// //                     ? const SizedBox(
// //                         width: 18,
// //                         height: 18,
// //                         child: CircularProgressIndicator(
// //                           strokeWidth: 2,
// //                           color: Colors.white,
// //                         ),
// //                       )
// //                     : const Icon(Icons.upload),
// //                 label: const Text("Upload"),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }


// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';

// // // class MaterialUploadScreen extends StatefulWidget {
// // //   const MaterialUploadScreen({super.key});

// // //   @override
// // //   State<MaterialUploadScreen> createState() => _MaterialUploadScreenState();
// // // }

// // // class _MaterialUploadScreenState extends State<MaterialUploadScreen> {
// // //   final _formKey = GlobalKey<FormState>();
// // //   final _titleController = TextEditingController();
// // //   final _contentController = TextEditingController();
// // //   final _codeController = TextEditingController();

// // //   bool _isLoading = false;

// // //   Future<void> _uploadMaterial() async {
// // //     if (!_formKey.currentState!.validate()) return;

// // //     setState(() => _isLoading = true);

// // //     await FirebaseFirestore.instance.collection('notes').add({
// // //       "title": _titleController.text.trim(),
// // //       "content": _contentController.text.trim(),
// // //       "exampleCode": _codeController.text.trim(),
// // //       "status": "waiting_approval", // admin will update to "approved" or "rejected"
// // //       "createdAt": FieldValue.serverTimestamp(),
// // //       "createdBy": FirebaseAuth.instance.currentUser?.email, // 🔹 who uploaded
// // //     });

// // //     setState(() => _isLoading = false);

// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       const SnackBar(content: Text("Material uploaded for approval")),
// // //     );

// // //     _titleController.clear();
// // //     _contentController.clear();
// // //     _codeController.clear();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text("Upload Material")),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Form(
// // //           key: _formKey,
// // //           child: ListView(
// // //             children: [
// // //               // 🔹 Title
// // //               TextFormField(
// // //                 controller: _titleController,
// // //                 decoration: const InputDecoration(
// // //                   labelText: "Title",
// // //                   border: OutlineInputBorder(),
// // //                 ),
// // //                 validator: (v) => v == null || v.isEmpty ? "Enter a title" : null,
// // //               ),
// // //               const SizedBox(height: 16),

// // //               // 🔹 Content
// // //               TextFormField(
// // //                 controller: _contentController,
// // //                 maxLines: 5,
// // //                 decoration: const InputDecoration(
// // //                   labelText: "Content (explanation)",
// // //                   border: OutlineInputBorder(),
// // //                 ),
// // //                 validator: (v) =>
// // //                     v == null || v.isEmpty ? "Enter lesson content" : null,
// // //               ),
// // //               const SizedBox(height: 16),

// // //               // 🔹 Example Code
// // //               TextFormField(
// // //                 controller: _codeController,
// // //                 maxLines: 8,
// // //                 decoration: const InputDecoration(
// // //                   labelText: "Example Code",
// // //                   border: OutlineInputBorder(),
// // //                 ),
// // //                 validator: (v) =>
// // //                     v == null || v.isEmpty ? "Enter example code" : null,
// // //               ),
// // //               const SizedBox(height: 24),

// // //               // 🔹 Upload Button
// // //               ElevatedButton.icon(
// // //                 onPressed: _isLoading ? null : _uploadMaterial,
// // //                 icon: _isLoading
// // //                     ? const SizedBox(
// // //                         width: 18,
// // //                         height: 18,
// // //                         child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
// // //                       )
// // //                     : const Icon(Icons.upload),
// // //                 label: const Text("Upload"),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }


// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // class MaterialUploadScreen extends StatefulWidget {
// // //   const MaterialUploadScreen({super.key});

// // //   @override
// // //   State<MaterialUploadScreen> createState() => _MaterialUploadScreenState();
// // // }

// // // class _MaterialUploadScreenState extends State<MaterialUploadScreen> {
// // //   final _formKey = GlobalKey<FormState>();
// // //   final _titleController = TextEditingController();
// // //   final _contentController = TextEditingController();
// // //   final _codeController = TextEditingController();

// // //   bool _isLoading = false;

// // //   Future<void> _uploadMaterial() async {
// // //     if (!_formKey.currentState!.validate()) return;

// // //     setState(() => _isLoading = true);

// // //     await FirebaseFirestore.instance.collection('notes').add({
// // //       "title": _titleController.text.trim(),
// // //       "content": _contentController.text.trim(),
// // //       "exampleCode": _codeController.text.trim(),
// // //       "status": "waiting_approval", // admin will update to "approved"
// // //       "createdAt": FieldValue.serverTimestamp(),
// // //     });

// // //     setState(() => _isLoading = false);

// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       const SnackBar(content: Text("Material uploaded for approval")),
// // //     );

// // //     _titleController.clear();
// // //     _contentController.clear();
// // //     _codeController.clear();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text("Upload Material")),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Form(
// // //           key: _formKey,
// // //           child: ListView(
// // //             children: [
// // //               // 🔹 Title
// // //               TextFormField(
// // //                 controller: _titleController,
// // //                 decoration: const InputDecoration(
// // //                   labelText: "Title",
// // //                   border: OutlineInputBorder(),
// // //                 ),
// // //                 validator: (v) => v == null || v.isEmpty ? "Enter a title" : null,
// // //               ),
// // //               const SizedBox(height: 16),

// // //               // 🔹 Content
// // //               TextFormField(
// // //                 controller: _contentController,
// // //                 maxLines: 5,
// // //                 decoration: const InputDecoration(
// // //                   labelText: "Content (explanation)",
// // //                   border: OutlineInputBorder(),
// // //                 ),
// // //                 validator: (v) =>
// // //                     v == null || v.isEmpty ? "Enter lesson content" : null,
// // //               ),
// // //               const SizedBox(height: 16),

// // //               // 🔹 Example Code
// // //               TextFormField(
// // //                 controller: _codeController,
// // //                 maxLines: 8,
// // //                 decoration: const InputDecoration(
// // //                   labelText: "Example Code",
// // //                   border: OutlineInputBorder(),
// // //                 ),
// // //                 validator: (v) =>
// // //                     v == null || v.isEmpty ? "Enter example code" : null,
// // //               ),
// // //               const SizedBox(height: 24),

// // //               // 🔹 Upload Button
// // //               ElevatedButton.icon(
// // //                 onPressed: _isLoading ? null : _uploadMaterial,
// // //                 icon: _isLoading
// // //                     ? const CircularProgressIndicator(color: Colors.white)
// // //                     : const Icon(Icons.upload),
// // //                 label: const Text("Upload"),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }


// // // import 'dart:async';

// // // import 'package:flutter/material.dart';
// // // import 'package:html_editor_enhanced/html_editor.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:coursebuddy/constants/app_theme.dart';

// // // class MaterialUploadScreen extends StatefulWidget {
// // //   const MaterialUploadScreen({super.key});

// // //   @override
// // //   State<MaterialUploadScreen> createState() => _MaterialUploadScreenState();
// // // }

// // // class _MaterialUploadScreenState extends State<MaterialUploadScreen> {
// // //   final TextEditingController _titleController = TextEditingController();
// // //   late final HtmlEditorController _htmlController;
// // //   Timer? _autoSaveTimer;
// // //   String _lastSavedHtml = '';

// // //   final _formKey = GlobalKey<FormState>();
// // //   bool _loading = false;

// // //   final CollectionReference notesRef =
// // //       FirebaseFirestore.instance.collection('notes');
// // //   final CollectionReference coursesRef =
// // //       FirebaseFirestore.instance.collection('courses');

// // //   String? draftId;
// // //   List<Map<String, dynamic>> courseList = [];
// // //   String? selectedCourseId;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _htmlController = HtmlEditorController();
// // //     _loadCourses();
// // //     _loadDraft();

// // //     // Auto-save every 5 seconds (polling). Adjust interval to taste.
// // //     _autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
// // //       _autoSaveDraft();
// // //     });
// // //   }

// // //   Future<void> _loadCourses() async {
// // //     try {
// // //       final snapshot = await coursesRef.get();
// // //       courseList = snapshot.docs
// // //           .map((doc) => {'id': doc.id, 'title': doc['title']})
// // //           .toList();
// // //       setState(() {});
// // //     } catch (e) {
// // //       debugPrint('Error loading courses: $e');
// // //     }
// // //   }

// // //   Future<void> _loadDraft() async {
// // //     final user = FirebaseAuth.instance.currentUser;
// // //     if (user == null) return;

// // //     try {
// // //       final querySnapshot = await notesRef
// // //           .where('createdBy', isEqualTo: user.email)
// // //           .where('status', isEqualTo: 'draft')
// // //           .limit(1)
// // //           .get();

// // //       if (querySnapshot.docs.isEmpty) return;

// // //       final doc = querySnapshot.docs.first;
// // //       final data = doc.data() as Map<String, dynamic>;
// // //       final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

// // //       // delete stale drafts (older than 3 days)
// // //       if (timestamp != null &&
// // //           DateTime.now().difference(timestamp).inDays >= 3) {
// // //         await notesRef.doc(doc.id).delete();
// // //         return;
// // //       }

// // //       draftId = doc.id;
// // //       _titleController.text = data['title'] ?? '';
// // //       selectedCourseId = data['courseId'];

// // //       // content could be stored as HTML string (recommended). If you have older
// // //       // Quill/notus JSON you will need to convert; this assumes HTML.
// // //       final content = data['content'] as String? ?? '';
// // //       _lastSavedHtml = content;

// // //       // set editor content (safe even if empty)
// // //       if (content.isNotEmpty) {
// // //         _htmlController.setText(content);
// // //       } else {
// // // _htmlController.setText('');

// // //       }

// // //       if (mounted) setState(() {});
// // //     } catch (e) {
// // //       debugPrint('Error loading draft: $e');
// // //     }
// // //   }

// // //   Future<void> _autoSaveDraft() async {
// // //     try {
// // //       final user = FirebaseAuth.instance.currentUser;
// // //       if (user == null) return;
// // //       if (selectedCourseId == null) return;

// // //       final html = (await _htmlController.getText())?.trim() ?? '';
// // //       final title = _titleController.text.trim();

// // //       // nothing to save
// // //       if (title.isEmpty && html.isEmpty) return;

// // //       // avoid repeated writes when nothing changed
// // //       if (html == _lastSavedHtml && title == (_lastSavedHtml.isEmpty ? '' : _titleController.text.trim())) {
// // //         return;
// // //       }

// // //       final data = {
// // //         'title': title,
// // //         'content': html,
// // //         'type': 'html',
// // //         'courseId': selectedCourseId,
// // //         'createdBy': user.email,
// // //         'status': 'draft',
// // //         'timestamp': FieldValue.serverTimestamp(),
// // //       };

// // //       if (draftId == null) {
// // //         final doc = await notesRef.add(data);
// // //         draftId = doc.id;
// // //       } else {
// // //         await notesRef.doc(draftId).set(data, SetOptions(merge: true));
// // //       }

// // //       _lastSavedHtml = html;
// // //     } catch (e) {
// // //       debugPrint('Auto-save failed: $e');
// // //     }
// // //   }

// // //   Future<void> _uploadMaterial() async {
// // //     if (!_formKey.currentState!.validate()) return;
// // //     if (selectedCourseId == null) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text("Please select a course")),
// // //       );
// // //       return;
// // //     }

// // //     setState(() => _loading = true);
// // //     try {
// // //       final user = FirebaseAuth.instance.currentUser;
// // //       if (user == null) throw Exception("User not logged in");

// // //       final html = (await _htmlController.getText()) ?? '';

// // //       final data = {
// // //         'title': _titleController.text.trim(),
// // //         'content': html,
// // //         'type': 'html',
// // //         'courseId': selectedCourseId,
// // //         'createdBy': user.email,
// // //         'status': 'waiting_approval',
// // //         'timestamp': FieldValue.serverTimestamp(),
// // //       };

// // //       if (draftId != null) {
// // //         await notesRef.doc(draftId).set(data, SetOptions(merge: true));
// // //       } else {
// // //         await notesRef.add(data);
// // //       }

// // //       if (!mounted) return;
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text("Note submitted for approval.")),
// // //       );

// // //       // clear editor & form
// // //    // Option 1: just clear text (sync)
// // // _htmlController.setText('');

// // //       _titleController.clear();
// // //       draftId = null;
// // //       selectedCourseId = null;
// // //       _lastSavedHtml = '';
// // //       setState(() {});
// // //     } catch (e) {
// // //       if (!mounted) return;
// // //       ScaffoldMessenger.of(context)
// // //           .showSnackBar(SnackBar(content: Text("Error: $e")));
// // //     } finally {
// // //       if (mounted) setState(() => _loading = false);
// // //     }
// // //   }

// // //   Future<void> _discardDraft() async {
// // //     if (draftId != null) {
// // //       await notesRef.doc(draftId).delete();
// // //       draftId = null;
// // //     }

  
// // // _htmlController.setText('');

// // //     _titleController.clear();
// // //     selectedCourseId = null;
// // //     _lastSavedHtml = '';

// // //     if (mounted) {
// // //       setState(() {});
// // //       ScaffoldMessenger.of(context)
// // //           .showSnackBar(const SnackBar(content: Text("Draft discarded.")));
// // //     }
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _autoSaveTimer?.cancel();
// // //     _titleController.dispose();
// // //     // HtmlEditorController doesn't require explicit dispose in most versions,
// // //     // but cancel timers and listeners you created.
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final screenWidth = MediaQuery.of(context).size.width;

// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text("Upload Material"),
// // //         backgroundColor: AppTheme.primaryColor,
// // //         actions: [
// // //           if (draftId != null)
// // //             IconButton(
// // //               icon: const Icon(Icons.delete_outline),
// // //               tooltip: "Discard Draft",
// // //               onPressed: _discardDraft,
// // //             ),
// // //         ],
// // //       ),
// // //       body: SafeArea(
// // //         child: SingleChildScrollView(
// // //           padding: const EdgeInsets.only(bottom: 16),
// // //           child: Column(
// // //             children: [
// // //               Padding(
// // //                 padding: const EdgeInsets.all(16),
// // //                 child: Form(
// // //                   key: _formKey,
// // //                   child: Column(
// // //                     children: [
// // //                       TextFormField(
// // //                         controller: _titleController,
// // //                         decoration:
// // //                             const InputDecoration(labelText: "Note Title"),
// // //                         validator: (v) => v!.isEmpty ? "Enter a title" : null,
// // //                       ),
// // //                       const SizedBox(height: 12),
// // //                       DropdownButtonFormField<String>(
// // //                         value: selectedCourseId,
// // //                         decoration:
// // //                             const InputDecoration(labelText: "Select Course"),
// // //                         items: courseList
// // //                             .map(
// // //                               (course) => DropdownMenuItem<String>(
// // //                                 value: course['id'],
// // //                                 child: Text(course['title']),
// // //                               ),
// // //                             )
// // //                             .toList(),
// // //                         onChanged: (val) => setState(() => selectedCourseId = val),
// // //                         validator: (v) =>
// // //                             v == null ? "Please select a course" : null,
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),

// // //               // HTML editor toolbar + editor
// // //               Container(
// // //                 margin: const EdgeInsets.symmetric(horizontal: 16),
// // //                 decoration: BoxDecoration(
// // //                   border: Border.all(color: Colors.grey.shade400),
// // //                   borderRadius: BorderRadius.circular(8),
// // //                 ),
// // //                 child: Column(
// // //                   children: [
// // //                     HtmlEditor(
// // //                       controller: _htmlController,
// // //                       htmlEditorOptions: HtmlEditorOptions(
// // //                         hint: "Type your content here...",
// // //                         initialText: '', // we'll set loaded draft later in _loadDraft
// // //                       ),
// // //                       htmlToolbarOptions: HtmlToolbarOptions(
// // //                         toolbarPosition: ToolbarPosition.aboveEditor,
// // //                         defaultToolbarButtons: [
// // //                           StyleButtons(),
// // //                           FontSettingButtons(),
// // //                           FontButtons(),
// // //                           ListButtons(),
// // //                           ParagraphButtons(),
// // //                           InsertButtons(),
// // //                           OtherButtons(),
// // //                         ],
// // //                       ),
// // //                       otherOptions: OtherOptions(
// // //                         height: 300,
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),

// // //               const SizedBox(height: 16),
// // //               Padding(
// // //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// // //                 child: _loading
// // //                     ? const CircularProgressIndicator()
// // //                     : ElevatedButton(
// // //                         onPressed: _uploadMaterial,
// // //                         style: ElevatedButton.styleFrom(
// // //                           backgroundColor: AppTheme.primaryColor,
// // //                           foregroundColor: Colors.white,
// // //                           minimumSize: Size(screenWidth, 50),
// // //                         ),
// // //                         child: const Text("Submit for Approval"),
// // //                       ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_quill/flutter_quill.dart' hide Text;
// // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // import 'package:firebase_auth/firebase_auth.dart';
// // // // import 'package:coursebuddy/constants/app_theme.dart';

// // // // class MaterialUploadScreen extends StatefulWidget {
// // // //   const MaterialUploadScreen({super.key});

// // // //   @override
// // // //   State<MaterialUploadScreen> createState() => _MaterialUploadScreenState();
// // // // }

// // // // class _MaterialUploadScreenState extends State<MaterialUploadScreen> {
// // // //   final TextEditingController _titleController = TextEditingController();
// // // //   final QuillController _quillController = QuillController.basic();
// // // //   final _formKey = GlobalKey<FormState>();
// // // //   bool _loading = false;

// // // //   final CollectionReference notesRef =
// // // //       FirebaseFirestore.instance.collection('notes');
// // // //   final CollectionReference coursesRef =
// // // //       FirebaseFirestore.instance.collection('courses');

// // // //   String? draftId;
// // // //   List<Map<String, dynamic>> courseList = [];
// // // //   String? selectedCourseId;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _loadCourses();
// // // //     _loadDraft();
// // // //     _quillController.addListener(_autoSaveDraft);
// // // //   }

// // // //   Future<void> _loadCourses() async {
// // // //     try {
// // // //       final snapshot = await coursesRef.get();
// // // //       courseList = snapshot.docs
// // // //           .map((doc) => {'id': doc.id, 'title': doc['title']})
// // // //           .toList();
// // // //       setState(() {});
// // // //     } catch (e) {
// // // //       debugPrint('Error loading courses: $e');
// // // //     }
// // // //   }

// // // //   Future<void> _loadDraft() async {
// // // //     final user = FirebaseAuth.instance.currentUser;
// // // //     if (user == null) return;

// // // //     try {
// // // //       final querySnapshot = await notesRef
// // // //           .where('createdBy', isEqualTo: user.email)
// // // //           .where('status', isEqualTo: 'draft')
// // // //           .limit(1)
// // // //           .get();

// // // //       if (querySnapshot.docs.isNotEmpty) {
// // // //         final doc = querySnapshot.docs.first;
// // // //         final data = doc.data() as Map<String, dynamic>;
// // // //         final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

// // // //         if (timestamp != null &&
// // // //             DateTime.now().difference(timestamp).inDays >= 3) {
// // // //           await notesRef.doc(doc.id).delete();
// // // //           return;
// // // //         }

// // // //         draftId = doc.id;
// // // //         _titleController.text = data['title'] ?? '';
// // // //         final content = data['content'] as List<dynamic>? ?? [];
// // // //         _quillController.document = Document.fromJson(content);
// // // //         selectedCourseId = data['courseId'];
// // // //       }
// // // //     } catch (e) {
// // // //       debugPrint('Error loading draft: $e');
// // // //     }
// // // //   }

// // // //   Future<void> _autoSaveDraft() async {
// // // //     if ((_titleController.text.isEmpty && _quillController.document.isEmpty()) ||
// // // //         selectedCourseId == null) return;

// // // //     final user = FirebaseAuth.instance.currentUser;
// // // //     if (user == null) return;

// // // //     final data = {
// // // //       'title': _titleController.text.trim(),
// // // //       'content': _quillController.document.toDelta().toJson(),
// // // //       'type': 'text',
// // // //       'courseId': selectedCourseId,
// // // //       'createdBy': user.email,
// // // //       'status': 'draft',
// // // //       'timestamp': FieldValue.serverTimestamp(),
// // // //     };

// // // //     if (draftId == null) {
// // // //       final doc = await notesRef.add(data);
// // // //       draftId = doc.id;
// // // //     } else {
// // // //       await notesRef.doc(draftId).set(data, SetOptions(merge: true));
// // // //     }
// // // //   }

// // // //   Future<void> _uploadMaterial() async {
// // // //     if (!_formKey.currentState!.validate()) return;
// // // //     if (selectedCourseId == null) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //           const SnackBar(content: Text("Please select a course")));
// // // //       return;
// // // //     }

// // // //     setState(() => _loading = true);
// // // //     try {
// // // //       final user = FirebaseAuth.instance.currentUser;
// // // //       if (user == null) throw Exception("User not logged in");

// // // //       final content = _quillController.document.toDelta().toJson();

// // // //       final data = {
// // // //         'title': _titleController.text.trim(),
// // // //         'content': content,
// // // //         'type': 'text',
// // // //         'courseId': selectedCourseId,
// // // //         'createdBy': user.email,
// // // //         'status': 'waiting_approval',
// // // //         'timestamp': FieldValue.serverTimestamp(),
// // // //       };

// // // //       if (draftId != null) {
// // // //         await notesRef.doc(draftId).set(data, SetOptions(merge: true));
// // // //       } else {
// // // //         await notesRef.add(data);
// // // //       }

// // // //       if (!mounted) return;
// // // //       ScaffoldMessenger.of(context)
// // // //           .showSnackBar(const SnackBar(content: Text("Note submitted for approval.")));
// // // //       _titleController.clear();
// // // //       _quillController.clear();
// // // //       draftId = null;
// // // //       selectedCourseId = null;
// // // //     } catch (e) {
// // // //       if (!mounted) return;
// // // //       ScaffoldMessenger.of(context)
// // // //           .showSnackBar(SnackBar(content: Text("Error: $e")));
// // // //     } finally {
// // // //       if (mounted) setState(() => _loading = false);
// // // //     }
// // // //   }

// // // //   Future<void> _discardDraft() async {
// // // //     if (draftId != null) {
// // // //       await notesRef.doc(draftId).delete();
// // // //       draftId = null;
// // // //     }
// // // //     _titleController.clear();
// // // //     _quillController.clear();
// // // //     selectedCourseId = null;
// // // //     ScaffoldMessenger.of(context)
// // // //         .showSnackBar(const SnackBar(content: Text("Draft discarded.")));
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _quillController.removeListener(_autoSaveDraft);
// // // //     _quillController.dispose();
// // // //     _titleController.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final screenWidth = MediaQuery.of(context).size.width;

// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text("Upload Material"),
// // // //         backgroundColor: AppTheme.primaryColor,
// // // //         actions: [
// // // //           if (draftId != null)
// // // //             IconButton(
// // // //               icon: const Icon(Icons.delete_outline),
// // // //               tooltip: "Discard Draft",
// // // //               onPressed: _discardDraft,
// // // //             ),
// // // //         ],
// // // //       ),
// // // //       body: SafeArea(
// // // //         child: SingleChildScrollView(
// // // //           padding: const EdgeInsets.only(bottom: 16),
// // // //           child: Column(
// // // //             children: [
// // // //               Padding(
// // // //                 padding: const EdgeInsets.all(16),
// // // //                 child: Form(
// // // //                   key: _formKey,
// // // //                   child: Column(
// // // //                     children: [
// // // //                       TextFormField(
// // // //                         controller: _titleController,
// // // //                         decoration:
// // // //                             const InputDecoration(labelText: "Note Title"),
// // // //                         validator: (v) => v!.isEmpty ? "Enter a title" : null,
// // // //                       ),
// // // //                       const SizedBox(height: 12),
// // // //                       DropdownButtonFormField<String>(
// // // //                         value: selectedCourseId,
// // // //                         decoration:
// // // //                             const InputDecoration(labelText: "Select Course"),
// // // //                         items: courseList
// // // //                             .map(
// // // //                               (course) => DropdownMenuItem<String>(
// // // //                                 value: course['id'],
// // // //                                 child: Text(course['title']),
// // // //                               ),
// // // //                             )
// // // //                             .toList(),
// // // //                         onChanged: (val) => setState(() => selectedCourseId = val),
// // // //                         validator: (v) =>
// // // //                             v == null ? "Please select a course" : null,
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //               // Toolbar
// // // //               QuillToolbar.basic(controller: _quillController),
// // // //               const SizedBox(height: 8),
// // // //               // Editor with fixed height using QuillEditor.basic
// // // //               Container(
// // // //                 height: 300,
// // // //                 margin: const EdgeInsets.symmetric(horizontal: 16),
// // // //                 decoration: BoxDecoration(
// // // //                   border: Border.all(color: Colors.grey.shade400),
// // // //                   borderRadius: BorderRadius.circular(8),
// // // //                 ),
// // // //                 child: QuillEditor.basic(
// // // //                   controller: _quillController,
// // // //                   readOnly: false, // valid in basic editor
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 16),
// // // //               Padding(
// // // //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// // // //                 child: _loading
// // // //                     ? const CircularProgressIndicator()
// // // //                     : ElevatedButton(
// // // //                         onPressed: _uploadMaterial,
// // // //                         style: ElevatedButton.styleFrom(
// // // //                           backgroundColor: AppTheme.primaryColor,
// // // //                           foregroundColor: Colors.white,
// // // //                           minimumSize: Size(screenWidth, 50),
// // // //                         ),
// // // //                         child: const Text("Submit for Approval"),
// // // //                       ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
