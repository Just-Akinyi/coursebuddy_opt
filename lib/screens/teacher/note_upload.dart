//**ADD teacher notes collection
/// Allows teachers to write course notes (text).
/// - Stored in `notes/` collection.
/// - Teachers can only add text notes.
/// - New notes default to `waiting_approval` (admin must approve).
/// Fields: {title, content, authorId, authorEmail, status, timestamp}

// Screen where teachers can create/upload their notes.
// Saves note with authorId and sets status=waiting_approval for admin review.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coursebuddy/constants/app_theme.dart';

class NoteUploadScreen extends StatefulWidget {
  const NoteUploadScreen({super.key});

  @override
  State<NoteUploadScreen> createState() => _NoteUploadScreenState();
}

class _NoteUploadScreenState extends State<NoteUploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _uploadNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance.collection('teacher_notes').add({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'authorId': user.uid, // 🔑 Who wrote the note
        'authorEmail': user.email, // optional, for reference
        'status': 'waiting_approval', // admin workflow
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note submitted for approval!")),
      );
      _titleController.clear();
      _contentController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Note"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Note Title"),
                validator: (v) => v!.isEmpty ? "Enter a title" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(labelText: "Note Content"),
                validator: (v) => v!.isEmpty ? "Enter content" : null,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _uploadNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Submit for Approval"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
