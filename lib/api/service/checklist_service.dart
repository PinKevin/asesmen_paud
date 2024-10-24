import 'dart:convert';

import 'package:asesmen_paud/api/dto/checklist_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/checklist_payload.dart';
import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';

class ChecklistService {
  Future<SuccessResponse<ChecklistsPaginated>> getAllStudentChecklists(
      int studentId,
      int page,
      String? from,
      String? until,
      String? sortOrder) async {
    String stringUrl = '$baseUrl/students/$studentId/checklists?page=$page';

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
          jsonResponse, (json) => ChecklistsPaginated.fromJson(json));
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }

  Future<SuccessResponse<Checklist>> createChecklist(
      int studentId, CreateChecklistDto dto) async {
    final Uri url = Uri.parse('$baseUrl/students/$studentId/checklists');
    final authToken = await AuthService.getToken();

    final response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(dto.toJson()));

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 201) {
      return SuccessResponse.fromJson(
          jsonResponse, (data) => Checklist.fromJson(data));
    } else if (response.statusCode == 422) {
      final failResponse = FailResponse.fromJson(jsonResponse);
      throw ValidationException(failResponse.errors ?? {});
    } else {
      throw Exception('Tidak bisa menambahkan ceklis. ${response.body}');
    }
  }

  Future<SuccessResponse<Checklist>> showChecklist(
      int studentId, int checklistId) async {
    final url =
        Uri.parse('$baseUrl/students/$studentId/checklists/$checklistId');
    final authToken = await AuthService.getToken();

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => Checklist.fromJson(json));
    } else if (response.statusCode == 404) {
      String message =
          jsonResponse['message'] ?? 'Ceklis tidak dapat ditemukan';
      throw ErrorException(message);
    } else {
      String message =
          jsonResponse['message'] ?? 'Terjadi error saat mengambil ceklis';
      throw ErrorException(message);
    }
  }

  Future<SuccessResponse<Checklist>> editChecklist(
      int studentId, int checklistId, EditChecklistDto dto) async {
    final url =
        Uri.parse('$baseUrl/students/$studentId/checklists/$checklistId');
    final authToken = await AuthService.getToken();

    final response = await http.put(url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(dto.toJson()));
    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => Checklist.fromJson(json));
    } else if (response.statusCode == 404) {
      String message =
          jsonResponse['message'] ?? 'Ceklis tidak dapat ditemukan';
      throw ErrorException(message);
    } else if (response.statusCode == 422) {
      final failResponse = FailResponse.fromJson(jsonResponse);
      throw ValidationException(failResponse.errors ?? {});
    } else {
      String message =
          jsonResponse['message'] ?? 'Terjadi error saat mengambil ceklis';
      throw ErrorException(message);
    }
  }

  Future<SuccessResponse<ApiResponse>> deleteChecklist(
      int studentId, int checklistId) async {
    final url =
        Uri.parse('$baseUrl/students/$studentId/checklists/$checklistId');
    final authToken = await AuthService.getToken();

    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => ApiResponse.fromJson(json, null));
    } else if (response.statusCode == 404) {
      String message =
          jsonResponse['message'] ?? 'Ceklis tidak dapat ditemukan';
      throw ErrorException(message);
    } else {
      String message =
          jsonResponse['message'] ?? 'Terjadi error saat menghapus ceklis';
      throw ErrorException(message);
    }
  }
}
