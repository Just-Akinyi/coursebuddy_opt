// flutter build web
// firebase deploy --only hosting
// firebase deploy --only hosting --debug
// locl pevie
// firebase serve --only hosting

import 'package:coursebuddy/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:coursebuddy/assets/theme/app_theme.dart';
import 'package:coursebuddy/widgets/auth_gate.dart';
import 'package:coursebuddy/widgets/global_fcm_listener.dart';
import 'package:logger/logger.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    // Request FCM permissions & token only on mobile
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getToken().then((t) {
      logger.i("FCM: $t");
    });

    // Foreground notifications listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode && message.notification != null) {
        logger.e('Notification: ${message.notification!.title}');
      }
    });
  }

  // ✅ No more GoogleSignInPlatform / GoogleSignInPlugin

  // Setup Firebase Crashlytics
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
      ),
    );
  }
}
