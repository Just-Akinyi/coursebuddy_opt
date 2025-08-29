import 'package:coursebuddy/screens/admin/admin_dashboard.dart';
import 'package:coursebuddy/screens/guest/not_registered_screen.dart';
import 'package:coursebuddy/screens/parent/parent_dashboard.dart';
import 'package:coursebuddy/screens/student/student_dashboard.dart';
import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Widget> getDashboardForUser(String email) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return const NotRegisteredScreen();

    final uid = firebaseUser.uid;
    final userDoc = await firestore.collection('users').doc(uid).get();
    // ✅ If missing, create fallback guest doc
    if (!userDoc.exists) {
      await firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': firebaseUser.displayName ?? 'Guest',
        'role': 'guest',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'waiting_approval',
      });
      return const NotRegisteredScreen();
    }

    // ✅ Cast to Map<String, dynamic>
    final data = userDoc.data() as Map<String, dynamic>;
    final role = data['role']?.toString() ?? 'guest';

    switch (role) {
      case 'student':
        final courseId = data['courseId']?.toString() ?? 'default_course';
        return StudentDashboard(courseId: courseId);

      case 'parent':
        return ParentDashboard();

      case 'teacher':
        return TeacherDashboard();

      case 'admin':
        return AdminDashboard();

      default:
        return const NotRegisteredScreen();
    }
  } catch (e, stack) {
    print("getDashboardForUser error: $e");
    print("Stack trace: $stack");
    return const NotRegisteredScreen();
  }
}
