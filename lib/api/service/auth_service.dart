import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/base_response.dart';
import 'package:asesmen_paud/api/login_payload.dart';

class AuthService {
  Future<BaseResponse<LoginPayload>> login(
      String email, String password) async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/sign-in');

    final response = await http.post(url,
        headers: {
          'Content-Type': 'applicaton/json',
        },
        body: json.encode({'email': email, 'password': password}));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return BaseResponse.fromJson(data, (json) => LoginPayload.fromJson(json));
    } else {
      throw Exception('Failed to login. Status code: ${response.statusCode}');
    }
  }
}
