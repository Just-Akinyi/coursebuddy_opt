import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:coursebuddy/constants/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  Future<void> _markAsRead(String docId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({
      'read': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("Not logged in"));
    }

    final notificationsRef = FirebaseFirestore.instance
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .orderBy('receivedAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: StreamBuilder(
        stream: notificationsRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            // separatorBuilder: (_, __) => const SizedBox(height: 8),
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isRead = data['read'] == true;

              return ListTile(
                tileColor:
                    isRead ? Colors.grey[100] : AppTheme.receivedMessageColor,
                title: Text(
                  data['title'] ?? 'No Title',
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                subtitle: Text(
                  data['body'] ?? 'No Body',
                  style: TextStyle(color: AppTheme.textColor),
                ),
                trailing: isRead
                    ? null
                    : IconButton(
                        icon:
                            const Icon(Icons.check, color: Colors.orangeAccent),
                        onPressed: () => _markAsRead(doc.id),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
