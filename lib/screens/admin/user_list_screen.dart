import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coursebuddy/assets/theme/app_theme.dart';
import 'package:coursebuddy/widgets/status.dart'; // ✅ reuse badge

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  // helper to update role/status
  Future<void> _updateUserRole(
    String uid,
    String newRole,
    String newStatus,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'role': newRole,
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User List"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs;

          // ✅ group users by role
          final grouped = <String, List<QueryDocumentSnapshot>>{};
          for (var user in users) {
            final role = user['role']?.toString() ?? 'guest';
            grouped.putIfAbsent(role, () => []);
            grouped[role]!.add(user);
          }

          return ListView(
            children: grouped.entries.map((entry) {
              final role = entry.key;
              final roleUsers = entry.value;

              return ExpansionTile(
                title: Text(
                  role.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: roleUsers.map((user) {
                  final status =
                      user['status']?.toString() ?? 'waiting_approval';
                  final email = user['email'] ?? 'unknown';
                  final uid = user.id;

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(email),
                    subtitle: Text("Status: $status"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ badge
                        StatusBadge(status: status, small: true),

                        // ✅ approve / change role button
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            _updateUserRole(uid, value, 'active');
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'student',
                              child: Text("Make Student"),
                            ),
                            const PopupMenuItem(
                              value: 'teacher',
                              child: Text("Make Teacher"),
                            ),
                            const PopupMenuItem(
                              value: 'parent',
                              child: Text("Make Parent"),
                            ),
                            const PopupMenuItem(
                              value: 'admin',
                              child: Text("Make Admin"),
                            ),
                            const PopupMenuItem(
                              value: 'guest',
                              child: Text("Revert to Guest"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
