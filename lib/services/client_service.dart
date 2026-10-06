import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/client.dart';
import 'auth_service.dart';

class ClientService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw Exception('Invalid server response.');
  }

  static Map<String, dynamic> _extractClientMap(dynamic data) {
    final root = _toMap(data);

    if (root['client'] is Map) {
      return _toMap(root['client']);
    }

    if (root['data'] is Map) {
      return _toMap(root['data']);
    }

    return root;
  }

  static List<dynamic> _extractList(dynamic data) {
    if (data is List) {
      return data;
    }

    final root = _toMap(data);

    if (root['clients'] is List) {
      return root['clients'] as List;
    }

    if (root['data'] is List) {
      return root['data'] as List;
    }

    return [];
  }

  static String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);

        if (map['message'] != null) {
          return map['message'].toString();
        }

        if (map['error'] != null) {
          return map['error'].toString();
        }
      }
    } catch (_) {}

    return 'Request failed with status ${response.statusCode}.';
  }

  static Future<List<Client>> getClients() async {
    final response = await http.get(
      Uri.parse('$baseUrl/clients'),
      headers: await _headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    final list = _extractList(decoded);

    return list.map((item) => Client.fromJson(_toMap(item))).toList();
  }

  static Future<Client> addClient({
    required String name,
    required String phone,
    String email = '',
    String company = '',
    String address = '',
    String productInterest = '',
    String productModel = '',
    String budget = '',
    String paymentType = 'Cash',
    String status = 'New',
    String leadSource = 'Facebook',
    String followUpDate = '',
    String followUpTime = '',
    String followUpReason = '',
    String estimatedDealValue = '',
    String lastContactDate = '',
    String lastContactResult = '',
    String notes = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
        'company': company,
        'address': address,
        'productInterest': productInterest,
        'productModel': productModel,
        'budget': budget,
        'paymentType': paymentType,
        'status': status,
        'leadSource': leadSource,
        'followUpDate': followUpDate,
        'followUpTime': followUpTime,
        'followUpReason': followUpReason,
        'lastContactDate': lastContactDate,
        'lastContactResult': lastContactResult,
        'notes': notes,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    final clientMap = _extractClientMap(decoded);

    return Client.fromJson(clientMap);
  }

  static Future<Client> updateClient({
    String? clientId,
    String? id,
    required String name,
    required String phone,
    String email = '',
    String company = '',
    String address = '',
    String productInterest = '',
    String productModel = '',
    String budget = '',
    String paymentType = 'Cash',
    String status = 'New',
    String leadSource = 'Facebook',
    String followUpDate = '',
    String followUpTime = '',
    String followUpReason = '',
    String estimatedDealValue = '',
    String notes = '',
  }) async {
    final resolvedId = clientId ?? id;

    if (resolvedId == null || resolvedId.isEmpty) {
      throw Exception('Client ID is required.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/clients/$resolvedId'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
        'company': company,
        'address': address,
        'productInterest': productInterest,
        'productModel': productModel,
        'budget': budget,
        'paymentType': paymentType,
        'status': status,
        'leadSource': leadSource,
        'followUpDate': followUpDate,
        'followUpTime': followUpTime,
        'followUpReason': followUpReason,
        'estimatedDealValue': estimatedDealValue,
        'notes': notes,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    final clientMap = _extractClientMap(decoded);

    return Client.fromJson(clientMap);
  }

  static Future<void> deleteClient(String clientId) async {
    if (clientId.isEmpty) {
      throw Exception('Client ID is required.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/clients/$clientId'),
      headers: await _headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
  }

  static Future<List<Map<String, dynamic>>> getContactHistory(
    String clientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/clients/$clientId/contact-history'),
      headers: await _headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    final list = _extractList(decoded);

    return list.map((item) => _toMap(item)).toList();
  }

  static Future<Client?> addContactHistory({
    required String clientId,
    required String contactMethod,
    required String result,
    required String notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients/$clientId/contact-history'),
      headers: await _headers(),
      body: jsonEncode({
        'contactMethod': contactMethod,
        'result': result,
        'notes': notes,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    if (response.body.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(response.body);

    try {
      final clientMap = _extractClientMap(decoded);

      return Client.fromJson(clientMap);
    } catch (_) {
      return null;
    }
  }
}
