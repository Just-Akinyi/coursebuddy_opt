DIAGRAM IN SETUP.PNG
✅ Full Flow Summary

User opens app → AuthGate:

Checks authStateChanges().

Validates maxDaysLoggedIn — signs out only if expired.

Get user roles:

Checks Firebase ID token claims → Firestore → RoleManager → default guest.

Multiple roles? → Show ChooseRoleDialog and save selection in RoleManager & SessionManager.

Route based on role:

guest → NotRegisteredScreen.

student → StudentDashboard.

teacher → TeacherDashboard.

admin/parent → future dashboards.

Dashboard rendering:

getDashboardForUser returns the correct widget.

Guests are logged once per day in Firestore.