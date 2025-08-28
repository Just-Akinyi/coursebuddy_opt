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
