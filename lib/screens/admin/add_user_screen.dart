import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:coursebuddy/utils/error_util.dart';
import 'package:coursebuddy/assets/theme/app_theme.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'teacher';
  bool _loading = false;

  Future<void> _addUser() async {
    setState(() => _loading = true);
    try {
      // ✅ Call Cloud Function instead of creating user locally
      final callable = FirebaseFunctions.instance.httpsCallable('createUser');
      await callable.call({
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'displayName': _emailController.text.trim().split(
          '@',
        )[0], // simple default
        'role': _role,
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e, st) {
      if (mounted) await showError(context, e, st);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add User"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: "teacher", child: Text("Teacher")),
                DropdownMenuItem(value: "parent", child: Text("Parent")),
                DropdownMenuItem(value: "admin", child: Text("Admin")),
              ],
              onChanged: (val) => setState(() => _role = val ?? "teacher"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _addUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Add User"),
            ),
          ],
        ),
      ),
    );
  }
}
