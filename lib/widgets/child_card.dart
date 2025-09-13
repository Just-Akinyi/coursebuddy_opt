import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ChildCard is a stateless widget that displays a child's information and provides
// functionality to chat with assigned teachers and export a profile to a PDF.
class ChildCard extends StatelessWidget {
  // Required fields for displaying child details.
  final String childName;
  final int age;
  final String parentName;
  final String emergencyContact;
  // A list of teacher emails, allowing for multiple assigned teachers.
  final List<String> assignedTeachers;

  // Constructor for the ChildCard widget.
  const ChildCard({
    super.key,
    required this.childName,
    required this.age,
    required this.parentName,
    required this.emergencyContact,
    required this.assignedTeachers,
  });

  // Asynchronously opens a chat with a specific teacher.
  Future<void> _openChat(BuildContext context, String teacherEmail) async {
    // Get the currently logged-in user. If no user is logged in, exit the function.
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Get a reference to the 'chats' collection in Firestore.
    final chats = FirebaseFirestore.instance.collection('chats');
    // Create a unique chat ID using the current user's UID and the teacher's email.
    final chatId = "${currentUser.uid}_$teacherEmail";

    // Get a reference to the specific chat document.
    final chatDoc = chats.doc(chatId);

    // Check if the chat document already exists.
    final docSnapshot = await chatDoc.get();
    if (!docSnapshot.exists) {
      // If the chat doesn't exist, create it with initial data.
      await chatDoc.set({
        'participants': [currentUser.email, teacherEmail],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Ensure the widget is still in the widget tree before navigating.
    if (context.mounted) {
      // Navigate to the ChatScreen, passing the chat ID and teacher's email.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ChatScreen(chatId: chatId, teacherEmail: teacherEmail),
        ),
      );
    }
  }

  // Shows a dialog to the user to select a teacher for a chat.
  void _showTeacherSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select Teacher"),
        content: SingleChildScrollView(
          child: Column(
            // Maps each teacher's email to a ListTile in the dialog.
            children: assignedTeachers.map((teacherEmail) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(teacherEmail),
                onTap: () {
                  // Close the dialog and open the chat with the selected teacher.
                  Navigator.pop(ctx);
                  _openChat(context, teacherEmail);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Asynchronously exports the child's profile to a PDF file.
  Future<void> _exportToPDF(BuildContext context) async {
    // Create a new PDF document.
    final pdf = pw.Document();

    // Add a new page to the PDF.
    pdf.addPage(
      pw.Page(
        // The build method for the PDF page content.
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Adds the title and child's details to the PDF.
            pw.Text("Child Profile",
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("Name: $childName"),
            pw.Text("Age: $age"),
            pw.Text("Parent: $parentName"),
            pw.Text("Emergency Contact: $emergencyContact"),
            pw.SizedBox(height: 10),
            pw.Text("Assigned Teachers:"),
            // Uses a spread operator to add a list of bullet points for each teacher.
            ...assignedTeachers.map((t) => pw.Bullet(text: t)),
          ],
        ),
      ),
    );

    // Prints or shares the PDF. The onLayout callback handles the PDF generation process.
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // The main build method for the ChildCard widget.
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display child's name with a large title style.
            Text(childName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            // Display other child details.
            Text("Age: $age"),
            Text("Parent: $parentName"),
            Text("Emergency: $emergencyContact"),
            const SizedBox(height: 8),
            // Row containing the action buttons.
            Row(
              children: [
                // Button to open the teacher chat selector.
                ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text("Chat Teacher"),
                  onPressed: () => _showTeacherSelector(context),
                ),
                const SizedBox(width: 10),
                // Button to export the profile to PDF.
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Export PDF"),
                  onPressed: () => _exportToPDF(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy ChatScreen (replace with your real one)
// A placeholder widget for the chat screen to allow for navigation.
class ChatScreen extends StatelessWidget {
  final String chatId;
  final String teacherEmail;

  const ChatScreen(
      {super.key, required this.chatId, required this.teacherEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with $teacherEmail")),
      body: Center(child: Text("Chat screen for $chatId")),
    );
  }
}
//one child version
//
// class ChildCard extends StatelessWidget {
//   final Map<String, dynamic> childData;
//   final VoidCallback onChatPressed;

//   const ChildCard({
//     super.key,
//     required this.childData,
//     required this.onChatPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final name = childData['name'] ?? 'Unnamed';
//     final courseId = childData['courseId'] ?? 'N/A';
//     final teachers = List<String>.from(childData['assignedTeachers'] ?? []);
//     final progress = (childData['progress'] as double).clamp(0.0, 100.0);
//     final classesTaken = childData['classesTaken'] ?? 0;
//     final totalClasses = childData['totalClasses'] ?? 0;
//     final remainingClasses = totalClasses - classesTaken;
//     final topics = List<String>.from(childData['topics'] ?? []);
//     final quizResults =
//         List<Map<String, dynamic>>.from(childData['quizResults'] ?? []);

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   name,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppTheme.textColor,
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: onChatPressed,
//                   icon: const Icon(Icons.chat, color: Colors.white),
//                   label: const Text("Chat"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primaryColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Text('Course: $courseId', style: TextStyle(color: AppTheme.textColor)),
//             Text('Teachers: ${teachers.join(', ')}',
//                 style: const TextStyle(color: Color(0xB3000000))),
//             const SizedBox(height: 10),
//             LinearProgressIndicator(
//               value: progress / 100,
//               minHeight: 8,
//               backgroundColor: const Color(0x4D03A9F4),
//               color: AppTheme.primaryColor,
//             ),
//             Text('Progress: ${progress.toStringAsFixed(0)}%',
//                 style: TextStyle(color: AppTheme.textColor)),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Text('Classes Taken: $classesTaken',
//                     style: TextStyle(color: AppTheme.textColor)),
//                 const SizedBox(width: 16),
//                 Text('Remaining: $remainingClasses',
//                     style: TextStyle(color: AppTheme.textColor)),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Text('Topics Covered:', style: TextStyle(color: AppTheme.textColor)),
//             Wrap(
//               spacing: 6,
//               children: topics
//                   .map((t) => Chip(
//                         label: Text(t),
//                         backgroundColor: const Color(0x4D03A9F4),
//                       ))
//                   .toList(),
//             ),
//             const SizedBox(height: 10),
//             Text('Quiz Results:', style: TextStyle(color: AppTheme.textColor)),
//             ...quizResults.map((quiz) {
//               final topic = quiz['topic'] ?? 'N/A';
//               final result = quiz['result'] ?? 'N/A';
//               return Text(
//                 "$topic: $result",
//                 style: TextStyle(color: AppTheme.textColor),
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }
// }
