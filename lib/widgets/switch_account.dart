import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart'; // adjust path if needed

class SwitchAccountScreen extends StatelessWidget {
  const SwitchAccountScreen({super.key});

  Future<void> _switchAccount(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error during sign out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              leading: const Icon(Icons.switch_account),
              title: const Text('Switch Account'),
              onTap: () => _switchAccount(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: TextButton.icon(
          onPressed: () => _switchAccount(context),
          icon: const Icon(Icons.switch_account),
          label: const Text("Switch Account"),
        ),
      ),
    );
  }
}
