import 'dart:convert';

import 'package:asesmen_paud/api/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/payload/student_report_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';

class ReportService {
  Future<SuccessResponse<StudentReportsPaginated>> getAllStudentReports(
      int studentId,
      int page,
      String? from,
      String? until,
      String? sortOrder) async {
    String stringUrl = '$baseUrl/students/$studentId/reports?page=$page';

    if (from != null && until != null) {
      stringUrl += '&from=$from&until=$until';
    }

    if (sortOrder != null) {
      stringUrl += '&sort-order=$sortOrder';
    }

    final Uri url = Uri.parse(stringUrl);

    final authToken = await AuthService.getToken();

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });
    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => StudentReportsPaginated.fromJson(json));
    } else {
      throw Exception('Terjadi error.');
    }
  }
}
