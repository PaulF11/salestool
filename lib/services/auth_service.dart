import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.body.isEmpty) {
        throw Exception(
          'Server returned an empty response. '
          'Make sure the backend is running.',
        );
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', data['token']);

        await prefs.setString('userName', data['user']['name']);

        await prefs.setString('userEmail', data['user']['email']);

        await prefs.setString('userRole', data['user']['role']);

        try {
          await syncFcmToken();
        } catch (error) {
          debugPrint('FCM token registration after login failed: $error');
        }

        return data;
      }

      throw Exception(
        data['message'] ??
            'Login failed. Server status: '
                '${response.statusCode}',
      );
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to connect to the server. '
        'Make sure the backend is running.',
      );
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.body.isEmpty) {
        throw Exception(
          'Server returned an empty response. '
          'Make sure the backend is running.',
        );
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      }

      throw Exception(
        data['message'] ??
            'Registration failed. '
                'Server status: ${response.statusCode}',
      );
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to connect to the server. '
        'Make sure the backend is running.',
      );
    }
  }

  static Future<void> syncFcmToken() async {
    final jwtToken = await getToken();

    if (jwtToken == null || jwtToken.isEmpty) {
      debugPrint('FCM TOKEN SYNC SKIPPED: User is not logged in.');
      return;
    }

    if (kIsWeb) {
      debugPrint('FCM TOKEN SYNC SKIPPED: Web notifications are disabled.');
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;

      final fcmToken = await messaging.getToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('FCM TOKEN SYNC SKIPPED: No FCM token available.');
        return;
      }

      final platform = getCurrentPlatformName();

      await registerFcmToken(fcmToken, platform);
    } catch (error) {
      debugPrint('FCM TOKEN SYNC ERROR: $error');
    }
  }

  static Future<void> registerFcmToken(String fcmToken, String platform) async {
    final jwtToken = await getToken();

    if (jwtToken == null || jwtToken.isEmpty) {
      debugPrint('FCM TOKEN REGISTRATION SKIPPED: No login token.');
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/fcm-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({'token': fcmToken, 'platform': platform}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message =
          'Failed to register FCM token. '
          'Server status: ${response.statusCode}';

      try {
        final data = jsonDecode(response.body);

        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    debugPrint(
      'FCM TOKEN REGISTERED SUCCESSFULLY '
      'FOR PLATFORM: $platform',
    );
  }

  static Future<void> removeCurrentFcmToken() async {
    final jwtToken = await getToken();

    if (jwtToken == null || jwtToken.isEmpty) {
      return;
    }

    if (kIsWeb) {
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;

      final fcmToken = await messaging.getToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        return;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/auth/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'token': fcmToken}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('FCM TOKEN REMOVED SUCCESSFULLY.');
      } else {
        debugPrint(
          'FCM TOKEN REMOVAL FAILED: '
          '${response.statusCode}',
        );
      }
    } catch (error) {
      debugPrint('FCM TOKEN REMOVAL ERROR: $error');
    }
  }

  static Future<void> logout() async {
    await removeCurrentFcmToken();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userRole');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('userName');
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('userEmail');
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('userRole');
  }

  static String getCurrentPlatformName() {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';

      case TargetPlatform.iOS:
        return 'ios';

      default:
        return 'unknown';
    }
  }
}
