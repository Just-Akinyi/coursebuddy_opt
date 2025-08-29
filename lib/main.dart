import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:coursebuddy/assets/theme/app_theme.dart';
import 'package:coursebuddy/widgets/auth_gate.dart';
import 'package:coursebuddy/widgets/global_fcm_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Setup Firebase Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Request FCM permissions & token
  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.instance.getToken().then((token) {
    if (kDebugMode) print("FCM Token: $token");
  });

  // Foreground notifications listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode && message.notification != null) {
      print('Notification: ${message.notification!.title}');
    }
  });

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
