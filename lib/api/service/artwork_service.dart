import 'dart:convert';
import 'dart:io';

import 'package:asesmen_paud/api/dto/artwork_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/artwork_payload.dart';
import 'package:asesmen_paud/api/service/photo_service.dart';
import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';

class ArtworkService {
  Future<SuccessResponse<ArtworksPaginated>> getAllStudentArtworks(
      int studentId,
      int page,
      String? from,
      String? until,
      String? sortOrder) async {
    String stringUrl = '$baseUrl/students/$studentId/artworks?page=$page';

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
          jsonResponse, (json) => ArtworksPaginated.fromJson(json));
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }

  Future<SuccessResponse<Artwork>> createArtwork(
      int studentId, CreateArtworkDto dto) async {
    final Uri url = Uri.parse('$baseUrl/students/$studentId/artworks');
    final authToken = await AuthService.getToken();

    if (dto.photo == null) {
      throw Exception('Foto harus diisi');
    }

    final compressedImage =
        await PhotoService().compressImage(File(dto.photo!.path));

    var request = http.MultipartRequest('POST', url);
    request.fields['description'] = dto.description;
    request.fields['feedback'] = dto.feedback;
    for (int i = 0; i < dto.learningGoals.length; i++) {
      request.fields['learningGoals[$i]'] = dto.learningGoals[i].toString();
    }

    request.files
        .add(await http.MultipartFile.fromPath('photo', compressedImage.path));

    request.headers.addAll({
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'multipart/form-data'
    });

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    final jsonResponse = json.decode(responseBody.body);

    if (response.statusCode == 201) {
      return SuccessResponse.fromJson(
          jsonResponse, (data) => Artwork.fromJson(data));
    } else if (response.statusCode == 422) {
      final failResponse = FailResponse.fromJson(jsonResponse);
      throw ValidationException(failResponse.errors ?? {});
    } else {
      throw Exception('Tidak bisa menambahkan hasil karya.');
    }
  }

  Future<SuccessResponse<Artwork>> showArtwork(
      int studentId, int artworkId) async {
    final url = Uri.parse('$baseUrl/students/$studentId/artworks/$artworkId');
    final authToken = await AuthService.getToken();

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => Artwork.fromJson(json));
    } else if (response.statusCode == 404) {
      String message =
          jsonResponse['message'] ?? 'Hasil karya tidak dapat ditemukan';
      throw ErrorException(message);
    } else {
      String message =
          jsonResponse['message'] ?? 'Terjadi error saat mengambil hasil karya';
      throw ErrorException(message);
    }
  }

  Future<SuccessResponse<Artwork>> editArtwork(
      int studentId, int artworkId, EditArtworkDto dto) async {
    final url = Uri.parse('$baseUrl/students/$studentId/artworks/$artworkId');
    final authToken = await AuthService.getToken();

    var request = http.MultipartRequest('PUT', url);
    request.fields['description'] = dto.description!;
    request.fields['feedback'] = dto.feedback!;
    for (int i = 0; i < dto.learningGoals!.length; i++) {
      request.fields['learningGoals[$i]'] = dto.learningGoals![i].toString();
    }

    if (dto.photo != null) {
      final compressedImage =
          await PhotoService().compressImage(File(dto.photo!.path));
      request.files.add(
          await http.MultipartFile.fromPath('photo', compressedImage.path));
    }

    request.headers.addAll({
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'multipart/form-data'
    });

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    final jsonResponse = json.decode(responseBody.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => Artwork.fromJson(json));
    } else if (response.statusCode == 404) {
      String message =
          jsonResponse['message'] ?? 'Hasil karya tidak dapat ditemukan';
      throw ErrorException(message);
    } else if (response.statusCode == 422) {
      final failResponse = FailResponse.fromJson(jsonResponse);
      throw ValidationException(failResponse.errors ?? {});
    } else {
      String message =
          jsonResponse['message'] ?? 'Terjadi error saat mengambil hasil karya';
      throw ErrorException(message);
    }
  }

  Future<SuccessResponse<ApiResponse>> deleteArtwork(
      int studentId, int artworkId) async {
    final url = Uri.parse('$baseUrl/students/$studentId/artworks/$artworkId');
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
          jsonResponse['message'] ?? 'Hasil karya tidak dapat ditemukan';
      throw ErrorException(message);
    } else {
      String message =
          jsonResponse['message'] ?? 'Terjadi error saat menghapus hasil karya';
      throw ErrorException(message);
    }
  }
}
