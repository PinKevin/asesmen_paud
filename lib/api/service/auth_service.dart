import 'dart:convert';

import 'package:asesmen_paud/api/exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/login_payload.dart';

class AuthService {
  Future<SuccessResponse<LoginPayload>> login(
      String email, String password) async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/sign-in');

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
}
