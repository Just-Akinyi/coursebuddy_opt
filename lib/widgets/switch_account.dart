import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../auth/login_screen.dart'; // adjust path if needed

class SwitchAccountScreen extends StatelessWidget {
  const SwitchAccountScreen({super.key});

  Future<void> _switchAccount(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

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

// TextButton.icon(
//   onPressed: () async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       await GoogleSignIn().signOut();

//       // Force reload of login screen
//       if (context.mounted) {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (_) => const LoginScreen()),
//           (route) => false,
//         );
//       }
//     } catch (e) {
//       debugPrint("Error during sign out: $e");
//     }
//   },
//   icon: const Icon(Icons.switch_account),
//   label: const Text("Switch Account"),
// )
// Drawer(
//   child: ListView(
//     padding: EdgeInsets.zero,
//     children: [
//       const DrawerHeader(child: Text('Menu')),
//       ListTile(
//         leading: const Icon(Icons.switch_account),
//         title: const Text('Switch Account'),
//         onTap: () async {
//           await FirebaseAuth.instance.signOut();
//           await GoogleSignIn().signOut();

//           if (context.mounted) {
//             Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(builder: (_) => const LoginScreen()),
//               (route) => false,
//             );
//           }
//         },
//       ),
//     ],
//   ),
// );

// TextButton.icon(
//   onPressed: () async {
//     try {
//       // ✅ Sign out from Firebase
//       await FirebaseAuth.instance.signOut();

//       // ✅ Sign out from Google (to force account picker next time)
//       await GoogleSignIn().signOut();

//       // ✅ Navigate back to login or clear navigation stack
//       // Replace with your navigation logic if needed
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//         (route) => false,
//       );
//     } catch (e) {
//       print("Error during sign out: $e");
//       // Optional: show a snackbar or dialog
//     }
//   },
//   icon: const Icon(Icons.switch_account),
//   label: const Text("Switch Account"),
// )

// PART 2
// Drawer(
//   child: ListView(
//     padding: EdgeInsets.zero,
//     children: [
//       const DrawerHeader(child: Text('Menu')),
//       ListTile(
//         leading: const Icon(Icons.switch_account),
//         title: const Text('Switch Account'),
//         onTap: () async {
//           await FirebaseAuth.instance.signOut();
//           await GoogleSignIn().signOut();
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (_) => const LoginScreen()),
//             (route) => false,
//           );
//         },
//       ),
//     ],
//   ),
// );
