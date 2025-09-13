// /// ParentDashboard:
// /// - Displays children linked to the parent's account
// /// - Shows progress, topics, quiz results
// /// - Allows chatting with assigned teachers
// /// - Handles FCM push notifications
// /// - Separates child card into a widget for cleanliness
// import '../widgets/child_card.dart';
// // Imports all necessary Flutter material, Firebase services (Firestore, Auth, Messaging),
// // and external packages for sharing files (share_plus), handling local files (path_provider),
// // and generating PDF reports (pdf, printing).
// import 'package:coursebuddy/constants/app_theme.dart';
// import 'package:coursebuddy/models/chat.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:share_plus/share_plus.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart';

// class ParentDashboard extends StatefulWidget {
//   const ParentDashboard({super.key});

//   @override
//   State<ParentDashboard> createState() => _ParentDashboardState();
// }

// class _ParentDashboardState extends State<ParentDashboard> {
//   late final FirebaseMessaging _messaging;
//   List<Map<String, dynamic>> children = [];
//   String sortOption = "Name";
//   bool hasUnreadNotifications = false;
//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();
//     _setupFCM();
//     _loadChildren();
//     _listenNotifications();
//   }

//   Future<void> _setupFCM() async {
//     _messaging = FirebaseMessaging.instance;
//     try {
//       await _messaging.requestPermission();
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         if (!mounted) return;
//         final notification = message.notification;
//         if (notification != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(notification.body ?? "New update"),
//               backgroundColor: AppTheme.primaryColor,
//             ),
//           );
//         }
//       });
//     } catch (e) {
//       debugPrint("FCM setup error: $e");
//     }
//   }

//   Future<void> _loadChildren() async {
//     final parentEmail = FirebaseAuth.instance.currentUser?.email;
//     if (parentEmail == null) return;
//     setState(() => _loading = true);
//     try {
//       final query = await FirebaseFirestore.instance
//           .collection('students')
//           .where('parentEmail', isEqualTo: parentEmail)
//           .get();

//       if (!mounted) return;

//       final loaded = query.docs.map((doc) {
//         final data = doc.data();
//         return {
//           'name': data['name'] ?? 'Unnamed',
//           'courseId': data['courseId'] ?? 'N/A',
//           'assignedTeachers': List<String>.from(data['assignedTeachers'] ??
//               [data['assignedTeacher'] ?? 'Not assigned']),
//           'progress':
//               (data['progress'] as num?)?.toDouble().clamp(0.0, 100.0) ?? 0.0,
//           'classesTaken': data['classesTaken'] ?? 0,
//           'totalClasses': data['totalClasses'] ?? 0,
//           'topics': List<String>.from(data['topics'] ?? []),
//           'quizResults':
//               List<Map<String, dynamic>>.from(data['quizResults'] ?? []),
//         };
//       }).toList();

//       setState(() {
//         children = loaded;
//       });
//       _applySorting();
//     } catch (e) {
//       debugPrint("Error loading children: $e");
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _listenNotifications() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;

//     FirebaseFirestore.instance
//         .collection('notifications')
//         .where('uid', isEqualTo: uid)
//         .where('read', isEqualTo: false)
//         .snapshots()
//         .listen((snapshot) {
//       if (!mounted) return;
//       setState(() {
//         hasUnreadNotifications = snapshot.docs.isNotEmpty;
//       });
//     });
//   }

//   void _openTeacherChat(String teacherEmail) {
//     if (teacherEmail.isEmpty || teacherEmail == 'Not assigned') {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("A teacher has not been assigned yet.")),
//       );
//       return;
//     }
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ChatScreen(otherUserEmail: teacherEmail),
//       ),
//     );
//   }

//   void _applySorting() {
//     if (children.length <= 1) return;
//     setState(() {
//       if (sortOption == "Name") {
//         children.sort((a, b) => a['name'].compareTo(b['name']));
//       } else if (sortOption == "Progress") {
//         children.sort((a, b) => b['progress'].compareTo(a['progress']));
//       } else if (sortOption == "Remaining Classes") {
//         children.sort((a, b) {
//           final remA = (a['totalClasses'] - a['classesTaken']);
//           final remB = (b['totalClasses'] - b['classesTaken']);
//           return remA.compareTo(remB);
//         });
//       }
//     });
//   }

//   Future<void> _exportCSV() async {
//     if (children.isEmpty) return;
//     final buffer = StringBuffer();
//     buffer.writeln("Name,Course,Teachers,Progress,ClassesTaken,TotalClasses");
//     for (var child in children) {
//       buffer.writeln(
//         "${child['name']},${child['courseId']},${child['assignedTeachers'].join('|')},${child['progress']}%,${child['classesTaken']},${child['totalClasses']}",
//       );
//     }
//     final dir = await getTemporaryDirectory();
//     final file = File("${dir.path}/children_export.csv");
//     await file.writeAsString(buffer.toString());
//     Share.shareXFiles([XFile(file.path)], text: "Children report");
//   }

//   Future<void> _exportPDF() async {
//     if (children.isEmpty) return;
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context ctx) {
//           return [
//             pw.Text("Children Report",
//                 style:
//                     pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
//             pw.SizedBox(height: 16),
//             pw.Table.fromTextArray(
//               headers: [
//                 "Name",
//                 "Course",
//                 "Teachers",
//                 "Progress",
//                 "Classes Taken",
//                 "Total Classes"
//               ],
//               data: children.map((child) {
//                 return [
//                   child['name'],
//                   child['courseId'],
//                   child['assignedTeachers'].join(', '),
//                   "${child['progress']}%",
//                   child['classesTaken'].toString(),
//                   child['totalClasses'].toString(),
//                 ];
//               }).toList(),
//             ),
//           ];
//         },
//       ),
//     );

//     final dir = await getTemporaryDirectory();
//     final file = File("${dir.path}/children_report.pdf");
//     await file.writeAsBytes(await pdf.save());
//     Share.shareXFiles([XFile(file.path)], text: "Children PDF report");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Parent Dashboard'),
//         backgroundColor: AppTheme.primaryColor,
//         actions: [
//           IconButton(
//             onPressed: _exportCSV,
//             icon: const Icon(Icons.download),
//             tooltip: "Export CSV",
//           ),
//           IconButton(
//             onPressed: _exportPDF,
//             icon: const Icon(Icons.picture_as_pdf),
//             tooltip: "Export PDF",
//           ),
//           Stack(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.notifications),
//                 onPressed: () {
//                   Navigator.pushNamed(context, "/notifications");
//                 },
//               ),
//               if (hasUnreadNotifications)
//                 Positioned(
//                   right: 10,
//                   bottom: 10,
//                   child: Container(
//                     width: 10,
//                     height: 10,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _loadChildren,
//               child: children.isEmpty
//                   ? Center(
//                       child: Text(
//                         'No children found.',
//                         style: TextStyle(color: AppTheme.textColor),
//                       ),
//                     )
//                   : Column(
//                       children: [
//                         if (children.length > 1)
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: DropdownButton<String>(
//                               value: sortOption,
//                               items: const [
//                                 DropdownMenuItem(
//                                     value: "Name", child: Text("Sort by Name")),
//                                 DropdownMenuItem(
//                                     value: "Progress",
//                                     child: Text("Sort by Progress")),
//                                 DropdownMenuItem(
//                                     value: "Remaining Classes",
//                                     child: Text("Sort by Remaining Classes")),
//                               ],
//                               onChanged: (val) {
//                                 if (val != null) {
//                                   setState(() {
//                                     sortOption = val;
//                                     _applySorting();
//                                   });
//                                 }
//                               },
//                             ),
//                           ),
//                         Expanded(
//                           child: ListView.builder(
//                             padding: const EdgeInsets.all(16),
//                             itemCount: children.length,
//                             itemBuilder: (context, index) {
//                               final child = children[index];
//                               return ChildCard(
//                                 childData: child,
//                                 onChatPressed: () {
//                                   final teachers = List<String>.from(
//                                       child['assignedTeachers'] ?? []);
//                                   if (teachers.isEmpty ||
//                                       (teachers.length == 1 &&
//                                           teachers[0] == 'Not assigned')) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                           content:
//                                               Text("No teacher assigned yet.")),
//                                     );
//                                     return;
//                                   }
//                                   if (teachers.length == 1) {
//                                     _openTeacherChat(teachers.first);
//                                   } else {
//                                     showDialog(
//                                       context: context,
//                                       builder: (ctx) {
//                                         return AlertDialog(
//                                           title: const Text("Select a Teacher"),
//                                           content: Column(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: teachers.map((t) {
//                                               return ListTile(
//                                                 title: Text(t),
//                                                 onTap: () {
//                                                   Navigator.pop(ctx);
//                                                   _openTeacherChat(t);
//                                                 },
//                                               );
//                                             }).toList(),
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   }
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//             ),
//     );
//   }
// }
