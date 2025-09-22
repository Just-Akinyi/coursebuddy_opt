// Screen shown for users with role 'guest' awaiting admin approval.
// Saves the user's FCM token on init for push notifications.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursebuddy/services/user_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:coursebuddy/services/auth_service.dart';

class NotRegisteredScreen extends StatefulWidget {
  const NotRegisteredScreen({super.key});

  @override
  State<NotRegisteredScreen> createState() => _NotRegisteredScreenState();
}

class _NotRegisteredScreenState extends State<NotRegisteredScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _saveUserToken(user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not signed in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Awaiting Approval"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // await FirebaseAuth.instance.signOut();
              await AuthService().logout(context);

            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final userDoc = snapshot.data;

          if (!snapshot.hasData || !userDoc!.exists) {
            return const Center(
              child: Text(
                "User document not found. Please try signing in again.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = userDoc.data() as Map<String, dynamic>;
          final role = data['role']?.toString() ?? 'guest';

          if (role == 'guest') {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Hello ${user!.displayName ?? "Guest"},\n\n"
                "Your account has been saved. An admin will review and assign your role soon.\n"
                "You’ll be notified once approved.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "✅ You’ve been approved as a $role!",
                    style: const TextStyle(fontSize: 16),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );

              await Future.delayed(const Duration(milliseconds: 500));
              if (!context.mounted) return;

              final dashboard = await getDashboardForUser(user!.email!);
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => dashboard),
              );
            });

            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Checking your approval status...",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _saveUserToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          "fcmToken": token,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      // Optionally log the error or show something to user
      debugPrint('Error saving FCM token: $e');
    }
  }
}
