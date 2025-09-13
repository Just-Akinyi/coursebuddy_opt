/// Determines and returns the appropriate dashboard widget for the current user
/// based on their role stored in Firestore.
/// If the user document doesn't exist, creates a guest user record,
/// logs guest visits once daily,
/// and returns a default "Not Registered" screen.
/// Supports roles: student, parent, teacher, admin, and guest.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/guest_user.dart';
// import 'package:coursebuddy/screens/parent_dashboard.dart';
import 'package:coursebuddy/screens/student/student_dashboard.dart';
import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
import 'package:coursebuddy/constants/user_roles.dart'; // your enum class

Future<Widget> getDashboardForUser(String email) async {
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;
  final uid = user.uid;
  final docRef = firestore.collection('users').doc(uid);

  final doc = await docRef.get();

  // If user exists, route to dashboard based on role
  if (doc.exists) {
    final data = doc.data()!;
    final role = data['role']?.toString() ?? UserRoles.guest;

    final dashboardMap = <String, Widget Function(Map<String, dynamic>)>{
      UserRoles.student: (data) =>
          // StudentDashboard(courseId: data['courseId'] ?? 'default_course'),
          StudentDashboard(
              courseId: data['courseId'] ?? 'default_course',
              status: 'Active'), //status),
      // UserRoles.parent: (_) => ParentDashboard(),
      UserRoles.teacher: (_) => const TeacherDashboard(),
      // UserRoles.admin: (_) => AdminDashboard(),
    };

    return dashboardMap[role]?.call(data) ?? const NotRegisteredScreen();
  }

  // User does not exist → create guest user doc
  await docRef.set({
    'uid': uid,
    'email': email,
    'name': user.displayName ?? 'Guest',
    'role': UserRoles.guest,
    'createdAt': FieldValue.serverTimestamp(),
  });

  // Log guest visit once per day
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);

  final existingVisit = await firestore
      .collection('guest_visits')
      .where('uid', isEqualTo: uid)
      .where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .get();

  if (existingVisit.docs.isEmpty) {
    await firestore.collection('guest_visits').add({
      'uid': uid,
      'email': email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  return const NotRegisteredScreen();
}
