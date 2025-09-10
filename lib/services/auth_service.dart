// Removed GoogleSignIn() entirely (no longer valid in v7.x).

// On Web → use signInWithPopup(GoogleAuthProvider()).

// On Mobile → use signInWithProvider(GoogleAuthProvider()).
import 'package:coursebuddy/screens/student/student_dashboard.dart';
import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
import 'package:coursebuddy/utils/error_util.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // ✅ Web uses popup
        userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        // ✅ Mobile uses Google provider
        final googleProvider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');

        userCredential = await _auth.signInWithProvider(googleProvider);
      }

      final user = userCredential.user;
      final uid = user?.uid;
      final email = user?.email;

      if (email == null || uid == null) {
        if (!context.mounted) return;
        showError(context, "Google account did not return a valid email/uid.");
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('users').doc(uid);
      final userDoc = await userDocRef.get();

      String role = 'guest'; // default
      String status = 'waiting_approval';

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        role = data['role']?.toString() ?? 'guest';
        status = data['status']?.toString() ?? 'waiting_approval';
      }

      // ✅ Save/update user doc
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await userDocRef.set({
        'uid': uid,
        'email': email,
        'name': user?.displayName ?? '',
        'fcmToken': fcmToken,
        'role': role,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!context.mounted) return;

      // ✅ Route by role
      if (role == 'teacher') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TeacherDashboard()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const StudentDashboard(
              courseId: 'default_course',
              status: 'active',
            ),
          ),
        );
      }
    } catch (e, stack) {
      if (!context.mounted) return;
      showError(context, e, stack);
    }
  }
}
