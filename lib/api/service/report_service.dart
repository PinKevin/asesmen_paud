import 'dart:convert';
import 'dart:io';

import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/payload/student_report_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';

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

    final String? authToken = await AuthService.getToken();

    final http.Response response = await http.get(url, headers: {
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

  Future<String> createAndDownloadReport(
      int studentId, int month, int year) async {
    DateTime startDate = DateTime(year, month, 1);
    DateTime endDate =
        DateTime(year, month + 1, 1).subtract(const Duration(days: 1));

    String formattedStartDate =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    String formattedEndDate =
        '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    if (await _requestStoragePermission()) {
      final String? authToken = await AuthService.getToken();
      final Uri url = Uri.parse(
          '$baseUrl/students/$studentId/reports/create-report?start-date=$formattedStartDate&end-date=$formattedEndDate');
      final headers = {
        'Authorization': 'Bearer $authToken',
        'Accept':
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      };

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        final contentDisposition = response.headers['content-disposition'];
        String fileName = 'Laporan.docx';

        if (contentDisposition != null &&
            contentDisposition.contains('filename=')) {
          final regex = RegExp(r'filename="?([^"]+)"?');
          final match = regex.firstMatch(contentDisposition);
          if (match != null) {
            fileName = match.group(1) ?? fileName;
          }
        }

        final filePath = await _saveFile(response.bodyBytes, fileName);
        return filePath;
      } else if (response.statusCode == 400) {
        final failResponse = FailResponse.fromJson(json.decode(response.body));
        throw ErrorException(failResponse.message);
      } else {
        throw Exception(response.reasonPhrase);
      }
    } else {
      throw Exception('Error saat meminta izin penyimpanan');
    }
  }

  Future<String> downloadExistingReport(int studentId, int reportId) async {
    if (await _requestStoragePermission()) {
      try {
        final String? authToken = await AuthService.getToken();
        final Uri url = Uri.parse(
            '$baseUrl/students/$studentId/reports/$reportId/download-report');
        final headers = {
          'Authorization': 'Bearer $authToken',
          'Accept':
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        };

        final response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          final contentDisposition = response.headers['content-disposition'];
          String fileName = 'Laporan.docx';

          if (contentDisposition != null &&
              contentDisposition.contains('filename=')) {
            final regex = RegExp(r'filename="?([^"]+)"?');
            final match = regex.firstMatch(contentDisposition);
            if (match != null) {
              fileName = match.group(1) ?? fileName;
            }
          }

          final filePath = await _saveFile(response.bodyBytes, fileName);
          return filePath;
        } else {
          throw Exception(response.reasonPhrase);
        }
      } catch (e) {
        throw Exception('Error saat mengambil laporan');
      }
    } else {
      throw Exception('Error saat meminta izin penyimpanan');
    }
  }

  static Future<bool> _requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied || status.isLimited) {
      status = await Permission.storage.request();
      return status.isGranted;
    }

    return false;
  }

  Future<String> _saveFile(List<int> bytes, String fileName) async {
    try {
      final Directory downloadDirectory =
          Directory('/storage/emulated/0/Download');
      final Directory reportDirectory =
          Directory('${downloadDirectory.path}/Laporan');

      if (!await downloadDirectory.exists()) {
        throw Exception('Folder Download tidak ditemukan');
      }

      if (!await reportDirectory.exists()) {
        await reportDirectory.create(recursive: true);
      }

      final String filePath = '${reportDirectory.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      throw Exception('Error saat download');
    }
  }
}
