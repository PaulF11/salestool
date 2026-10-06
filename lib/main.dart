import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('BACKGROUND NOTIFICATION: ${message.notification?.title}');

  debugPrint('BACKGROUND DATA: ${message.data}');
}

Future<void> initializeFirebaseMessaging() async {
  /*
   * Web is not using FCM yet.
   *
   * This prevents Flutter Web from trying to register
   * firebase-messaging-sw.js.
   */
  if (kIsWeb) {
    debugPrint('FCM: Web notification setup skipped.');
    return;
  }

  final messaging = FirebaseMessaging.instance;

  /*
   * Request notification permission.
   *
   * iOS requires this permission.
   * Android 13+ also requires notification permission.
   */
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
  );

  debugPrint(
    'NOTIFICATION PERMISSION: '
    '${settings.authorizationStatus}',
  );

  /*
   * On Apple platforms, check the APNs token.
   */
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      final apnsToken = await messaging.getAPNSToken();

      debugPrint('APNS TOKEN AVAILABLE: ${apnsToken != null}');
    } catch (error) {
      debugPrint('APNS TOKEN ERROR: $error');
    }
  }

  /*
   * Get the FCM registration token.
   */
  try {
    final fcmToken = await messaging.getToken();

    debugPrint('FCM TOKEN: $fcmToken');

    if (fcmToken != null && fcmToken.isNotEmpty) {
      await AuthService.syncFcmToken();
    }
  } catch (error) {
    debugPrint('FCM TOKEN ERROR: $error');
  }

  /*
   * FCM tokens can change.
   *
   * Automatically register the new token with
   * the currently logged-in sales agent.
   */
  messaging.onTokenRefresh.listen(
    (newToken) async {
      debugPrint('FCM TOKEN REFRESHED: $newToken');

      try {
        await AuthService.registerFcmToken(
          newToken,
          AuthService.getCurrentPlatformName(),
        );

        debugPrint('REFRESHED FCM TOKEN REGISTERED SUCCESSFULLY.');
      } catch (error) {
        debugPrint('REFRESHED FCM TOKEN REGISTRATION ERROR: $error');
      }
    },
    onError: (error) {
      debugPrint('FCM TOKEN REFRESH ERROR: $error');
    },
  );

  /*
   * Foreground notifications.
   */
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint(
      'FOREGROUND NOTIFICATION: '
      '${message.notification?.title}',
    );

    debugPrint('FOREGROUND DATA: ${message.data}');
  });

  /*
   * Notification opened while the app was in the background.
   */
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint(
      'NOTIFICATION OPENED: '
      '${message.notification?.title}',
    );

    debugPrint('NOTIFICATION DATA: ${message.data}');

    /*
       * Later we can use:
       *
       * message.data['clientId']
       *
       * to automatically open the correct client.
       */
  });

  /*
   * Notification opened the application from a
   * completely terminated state.
   */
  final initialMessage = await messaging.getInitialMessage();

  if (initialMessage != null) {
    debugPrint(
      'APP OPENED FROM NOTIFICATION: '
      '${initialMessage.notification?.title}',
    );

    debugPrint(
      'INITIAL NOTIFICATION DATA: '
      '${initialMessage.data}',
    );

    /*
     * Later we can use:
     *
     * initialMessage.data['clientId']
     *
     * to automatically open the correct client.
     */
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /*
   * Register the background FCM handler only for
   * platforms where FCM is being used.
   */
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  await initializeFirebaseMessaging();

  runApp(const SalesToolApp());
}

class SalesToolApp extends StatelessWidget {
  const SalesToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0B1120);
    const cardColor = Color(0xFF151F35);
    const primaryColor = Color(0xFF3B82F6);
    const textColor = Color(0xFFF8FAFC);
    const secondaryTextColor = Color(0xFF94A3B8);
    const borderColor = Color(0xFF263653);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SalesTool',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: primaryColor,
          surface: cardColor,
          error: Color(0xFFEF4444),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textColor,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: cardColor,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: borderColor, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardColor,
          labelStyle: const TextStyle(color: secondaryTextColor),
          hintStyle: const TextStyle(color: secondaryTextColor),
          prefixIconColor: secondaryTextColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
          bodySmall: TextStyle(color: secondaryTextColor),
          titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: const BorderSide(color: primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        iconTheme: const IconThemeData(color: primaryColor),
        dividerTheme: const DividerThemeData(color: borderColor),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: cardColor,
          contentTextStyle: const TextStyle(color: textColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: const TextStyle(color: textColor),
          menuStyle: const MenuStyle(
            backgroundColor: WidgetStatePropertyAll(cardColor),
          ),
        ),
      ),
      home: const StartupScreen(),
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();

    checkLogin();
  }

  Future<void> checkLogin() async {
    final token = await AuthService.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      /*
       * The user is already logged in.
       *
       * Make sure the current device's FCM token
       * is registered to this agent.
       */
      if (!kIsWeb) {
        try {
          await AuthService.syncFcmToken();
        } catch (error) {
          debugPrint('STARTUP FCM TOKEN SYNC ERROR: $error');
        }
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
