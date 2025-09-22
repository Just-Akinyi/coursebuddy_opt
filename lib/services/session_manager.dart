// session_manager.dart
// Tiny session helper used to persist the user's chosen role in-memory for this app session.
// - Set SessionManager.currentRole after sign-in/role choose.
// - Read SessionManager.currentRole in your UserRouter to decide which dashboard to show.

class SessionManager {
  SessionManager._();
  static String? currentRole;

  /// helper: clear session role on signout
  static void clear() {
    currentRole = null;
  }
}

// // session_manager.dart
// // Tiny session helper used to persist the user's chosen role in-memory for this app session.
// // - Set SessionManager.currentRole after sign-in/role choose.
// // - Read SessionManager.currentRole in your UserRouter to decide which dashboard to show.

// class SessionManager {
//   SessionManager._();
//   static String? currentRole;

//   /// helper: clear session role on signout
//   static void clear() {
//     currentRole = null;
//   }
// }
