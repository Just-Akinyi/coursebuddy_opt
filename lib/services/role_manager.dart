// RoleManager.dart
//
// Handles storing and retrieving the currently selected user role locally
// using SharedPreferences. This ensures that:
// - User’s single role persists across app restarts until the user logs out.
// - Integrates seamlessly with AuthGate and getDashboardForUser.

import 'package:shared_preferences/shared_preferences.dart';

class RoleManager {
  static const _key = 'currentRole';

  /// Save the current role locally
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, role);
  }

  /// Retrieve the saved role, returns null if none stored
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// Clear the saved role (e.g., on logout)
  static Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}


// // RoleManager.dart
// //
// // Handles storing and retrieving the currently selected user role locally
// // using SharedPreferences. This ensures that:
// // - Users with multiple roles don’t need to re-choose their role on every app restart.
// // - SessionManager.currentRole persists across app restarts until the user logs out.
// // - Integrates seamlessly with AuthGate and getDashboardForUser.

// import 'package:shared_preferences/shared_preferences.dart';

// class RoleManager {
//   static const _key = 'currentRole';

//   /// Save the current role locally
//   static Future<void> saveRole(String role) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_key, role);
//   }

//   /// Retrieve the saved role, returns null if none stored
//   static Future<String?> getRole() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_key);
//   }

//   /// Clear the saved role (e.g., on logout)
//   static Future<void> clearRole() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_key);
//   }
// }
