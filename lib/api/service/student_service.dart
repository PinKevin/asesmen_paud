import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/payload/student_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';

class StudentService {
  Future<SuccessResponse<PaginateStudentsPayload>> getAllStudents() async {
    final url = Uri.parse('$baseUrl/students');
    final authToken = await AuthService.getToken();

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => PaginateStudentsPayload.fromJson(json));
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }
}
