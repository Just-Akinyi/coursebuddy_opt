/// Listens for incoming Firebase Cloud Messaging (FCM) notifications while the app is in the foreground,
/// saves each notification to Firestore with a read/unread status,
/// and displays a custom SnackBar alert to the user.
/// Wraps child widget to enable global notification handling.

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:coursebuddy/widgets/notification_snackbar.dart';

class GlobalFcmListener extends StatefulWidget {
  final Widget child;

  const GlobalFcmListener({required this.child, super.key});

  @override
  State<GlobalFcmListener> createState() => _GlobalFcmListenerState();
}

class _GlobalFcmListenerState extends State<GlobalFcmListener> {
  bool _dialogVisible = false;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      if (!mounted || _dialogVisible) return;

      final notification = msg.notification;
      if (notification == null) return;

      _dialogVisible = true;

      final user = FirebaseAuth.instance.currentUser;

      // ✅ Save notification to Firestore with unread status
      if (user != null) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'uid': user.uid,
          'email': user.email,
          'title': notification.title ?? 'No Title',
          'body': notification.body ?? 'No Body',
          'receivedAt': FieldValue.serverTimestamp(),
          'read': false, // ⬅️ Track read/unread
        });
      }

      // ✅ Show notification SnackBar
      NotificationSnackBar.show(
        context,
        title: notification.title ?? 'New Notification',
        body: notification.body ?? 'You have a new message',
      );

      await Future.delayed(const Duration(milliseconds: 300));
      _dialogVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
