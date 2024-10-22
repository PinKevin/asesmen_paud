import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/payload/student_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';

class StudentService {
  Future<SuccessResponse<List<Class>>> getAllTeacherClass() async {
    final url = Uri.parse('$baseUrl/classes');
    final authToken = await AuthService.getToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['payload'] is List) {
        final List<Class> classes = (jsonResponse['payload'] as List)
            .map((item) => Class.fromJson(item))
            .toList();

        return SuccessResponse<List<Class>>(
          status: jsonResponse['status'],
          message: jsonResponse['message'],
          payload: classes,
        );
      } else {
        throw Exception('Payload bukan list');
      }
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }

  Future<SuccessResponse<StudentsPaginated>> getAllStudents(
      int page, String? query, String? sortOrder) async {
    String stringUrl = '$baseUrl/students?page=$page';

    if (sortOrder != null) {
      stringUrl += '&sort-order=$sortOrder';
    }

    if (query != null) {
      stringUrl += '&q=$query';
    }

    print(stringUrl);

    final Uri url = Uri.parse(stringUrl);
    final authToken = await AuthService.getToken();

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => StudentsPaginated.fromJson(json));
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }
}
