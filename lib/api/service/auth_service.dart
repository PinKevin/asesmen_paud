import 'dart:convert';

import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/login_payload.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String tokenKey = 'auth_token';

  Future<SuccessResponse<LoginPayload>> login(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/sign-in');

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}));

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => LoginPayload.fromJson(json));
    } else if (response.statusCode == 422) {
      final failResponse = FailResponse.fromJson(jsonResponse);
      throw ValidationException(failResponse.errors ?? {});
      // throw Exception('422 bang');
    } else if (response.statusCode == 400) {
      String message =
          jsonResponse['message'] ?? 'Email atau password salah, tapi literal';
      throw BadRequestException(message);
    } else {
      throw Exception(
          'Failed to login. Status code: ${response.statusCode}. Error: ${response.body}');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  static Future<bool> checkToken(String token) async {
    final url = Uri.parse('$baseUrl/check-token');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    return response.statusCode == 200;
  }
}
