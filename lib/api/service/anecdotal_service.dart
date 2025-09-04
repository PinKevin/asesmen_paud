import 'dart:convert';

import 'package:asesmen_paud/api/dto/anecdotal_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/service/file_service.dart';
import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/payload/anecdotal_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';

class AnecdotalService {
  Future<SuccessResponse<AnecdotalsPaginated>> getAllStudentAnecdotals(
      int studentId,
      int page,
      String? from,
      String? until,
      String? sortOrder) async {
    String stringUrl = '$baseUrl/students/$studentId/anecdotals?page=$page';

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
          jsonResponse, (json) => AnecdotalsPaginated.fromJson(json));
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }

  Future<SuccessResponse<Anecdotal>> createAnecdotal(
      int studentId, CreateAnecdotalDto dto) async {
    if (dto.photo == null) {
      throw Exception('Foto harus diisi');
    }

    final uploadPhotoResponse = await FileService().uploadPhoto(dto.photo!);
    final photoLink = uploadPhotoResponse.payload!.filePath;

    final Map<String, dynamic> requestBody = {
      'description': dto.description,
      'feedback': dto.feedback,
      'photoLink': photoLink,
      'learningGoals': dto.learningGoals,
    };

    final Uri url = Uri.parse('$baseUrl/students/$studentId/anecdotals');
    final authToken = await AuthService.getToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json'
      },
      body: json.encode(requestBody),
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 201) {
      return SuccessResponse.fromJson(
          jsonResponse, (data) => Anecdotal.fromJson(data));
    } else if (response.statusCode == 422) {
      final failResponse = FailResponse.fromJson(jsonResponse);
      throw ValidationException(failResponse.errors ?? {});
    } else {
      throw Exception('Tidak bisa menambahkan anekdot.');
    }
  }

  Future<SuccessResponse<Anecdotal>> showAnecdotal(
      int studentId, int anecdotalId) async {
    final url =
        Uri.parse('$baseUrl/students/$studentId/anecdotals/$anecdotalId');
    final authToken = await AuthService.getToken();

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => Anecdotal.fromJson(json));
    } else if (response.statusCode == 404) {
      String message =
          jsonResponse['message'] ?? 'Anekdot tidak dapat ditemukan';
      throw ErrorException(message);
    } else {
      String message =
          jsonResponse['message'] ?? 'Terjadi error saat mengambil anekdot';
      throw ErrorException(message);
    }
  }

  Future<SuccessResponse<Anecdotal>> editAnecdotal(
      int studentId, int anecdotalId, EditAnecdotalDto dto) async {
    String? photoLink;
    if (dto.photo != null) {
      final uploadPhotoResponse = await FileService().uploadPhoto(dto.photo!);
      photoLink = uploadPhotoResponse.payload!.filePath;
    }

    final Map<String, dynamic> requestBody = {
      'description': dto.description,
      'feedback': dto.feedback,
      'photoLink': photoLink,
      'learningGoals': dto.learningGoals,
    };

    final url =
        Uri.parse('$baseUrl/students/$studentId/anecdotals/$anecdotalId');
    final authToken = await AuthService.getToken();

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );
    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => Anecdotal.fromJson(json));
    } else if (response.statusCode == 404) {
      String message =
          jsonResponse['message'] ?? 'Anekdot tidak dapat ditemukan';
      throw ErrorException(message);
    } else if (response.statusCode == 422) {
      final failResponse = FailResponse.fromJson(jsonResponse);
      throw ValidationException(failResponse.errors ?? {});
    } else {
      String message =
          jsonResponse['message'] ?? 'Terjadi error saat mengambil anekdot';
      throw ErrorException(message);
    }
  }

  Future<SuccessResponse<ApiResponse>> deleteAnecdotal(
      int studentId, int anecdotalId) async {
    final url =
        Uri.parse('$baseUrl/students/$studentId/anecdotals/$anecdotalId');
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
          jsonResponse['message'] ?? 'Anekdot tidak dapat ditemukan';
      throw ErrorException(message);
    } else {
      String message =
          jsonResponse['message'] ?? 'Terjadi error saat menghapus anekdot';
      throw ErrorException(message);
    }
  }
}
