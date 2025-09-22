// choose_role_dialog.dart
// - Dialog to show when a user has multiple roles. Returns the selected role string.
// - Call this after sign-in when you fetch the user's Firestore doc:
//   final role = await showDialog(context: ctx, builder: (_) => ChooseRoleDialog(roles: rolesList));

import 'package:flutter/material.dart';

class ChooseRoleDialog extends StatelessWidget {
  final List<String> roles;
  const ChooseRoleDialog({super.key, required this.roles});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose a role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: roles.map((r) {
          return ListTile(
            title: Text(r[0].toUpperCase() + r.substring(1)),
            onTap: () => Navigator.of(context).pop(r),
          );
        }).toList(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(roles.first), child: const Text('Default')),
      ],
    );
  }
}
