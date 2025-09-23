//AUTH SERVICE HAS onboardingCompleteUSE IT IN ADMIN DASH
//DO SOMETHING IF RETURNING USER IN AUTSERVICE
//💡 Real-world use cases:

// Show onboarding or tutorial only to new users

// Set up default roles or preferences

// Mark users for a welcome email
// Entry point of the CourseBuddy Flutter app.
//
// Responsibilities:
// - Initialize Firebase with platform-specific options.
// - Initialize Firebase Cloud Messaging (FCM):
//   - Request permissions on mobile platforms.
//   - Log FCM token and listen for foreground messages.
// - Setup Firebase Crashlytics for error reporting.
// - Wrap app with a global FCM listener for notification handling.
// - Launch MaterialApp with theming and authentication gate.
//
// Notes:
// - Web-specific FCM background handling requires a `firebase-messaging-sw.js` service worker file.
// - For better PWA support, add web-specific meta tags in `web/index.html`.
// - To fully support deep linking, configure URL strategies and routing accordingly.

// import 'package:coursebuddy/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:coursebuddy/constants/app_theme.dart';
// import 'package:coursebuddy/screens/admin/admin_dashboard.dart';
import 'package:coursebuddy/services/auth_gate.dart';
// import 'package:coursebuddy/splash_loader.dart';
import 'package:coursebuddy/services/global_fcm_listener.dart';
import 'package:logger/logger.dart';
import 'firebase_options.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase app with platform-specific options.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  logger.i(
    'Firebase initialized for platform: ${DefaultFirebaseOptions.currentPlatform}',
  );

  if (!kIsWeb) {
    // Request notification permission only on mobile platforms.
    final settings = await FirebaseMessaging.instance.requestPermission();
    logger.i('FCM permission status: ${settings.authorizationStatus}');

    // Retrieve and log the FCM token for device-targeted messaging.
    final fcmToken = await FirebaseMessaging.instance.getToken();
    logger.i('FCM Token: $fcmToken');

    // Listen to foreground messages (app open).
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode && message.notification != null) {
        logger.i(
          'Foreground notification received: ${message.notification!.title}',
        );
      }
    });
  }

  // Setup Firebase Crashlytics error handling.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalFcmListener(
      child: MaterialApp(
        title: 'CourseBuddy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
        // home: const SplashLoader(),
        //home: getDashboardForUser();
        // home: AdminDashboard(),
      ),
    );
  }
}
