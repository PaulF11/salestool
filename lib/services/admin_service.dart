import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>> getSummary() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Login session expired.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/admin/summary'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      getErrorMessage(response, 'Failed to load admin dashboard.'),
    );
  }

  static Future<List<dynamic>> getAgents() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Login session expired.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/admin/agents'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(getErrorMessage(response, 'Failed to load agents.'));
  }

  static Future<List<dynamic>> getAllClients() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Login session expired.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/admin/clients'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(getErrorMessage(response, 'Failed to load clients.'));
  }

  static String getErrorMessage(http.Response response, String defaultMessage) {
    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);

        return data['message'] ?? defaultMessage;
      } catch (_) {}
    }

    return defaultMessage;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userRole');
  }
}
