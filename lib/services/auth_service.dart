import 'package:coursebuddy/screens/student/student_dashboard.dart';
import 'package:coursebuddy/screens/teacher/teacher_dashboard.dart';
import 'package:coursebuddy/utils/error_util.dart';
// import 'package:coursebuddy/utils/user_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(
    BuildContext context, {
    bool mounted = true,
  }) async {
    try {
      // ✅ Force account selection
      await _auth.signOut();
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      final uid = user?.uid;
      final email = user?.email;

      if (email == null || uid == null) {
        if (!context.mounted || !mounted) return;
        showError(context, "Google account did not return a valid email/uid.");
        return;
      }

      final firestore = FirebaseFirestore.instance;

      // ✅ Check if user already exists in users/{uid}
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
        // 'role': role,
        'role': 'student',
        // 'role': 'teacher',
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      // Navigate directly to TeacherDashboard
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => TeacherDashboard()));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              StudentDashboard(courseId: 'default_course', status: 'active'),
          // TeacherDashboard(),
        ),
      );
      // ✅ Route user to their dashboard
      //   final target = await getDashboardForUser(email);
      //   if (!context.mounted || !mounted) return;
      //   Navigator.of(
      //     context,
      //   ).pushReplacement(MaterialPageRoute(builder: (_) => target));
    } catch (e, stack) {
      if (!context.mounted || !mounted) return;
      showError(context, e, stack);
    }
  }
}
