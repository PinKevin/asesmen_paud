import 'dart:convert';

import 'package:asesmen_paud/api/dto/artwork_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/artwork_payload.dart';
import 'package:asesmen_paud/api/service/file_service.dart';
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
    String? sortOrder,
  ) async {
    String stringUrl = '$baseUrl/students/$studentId/artworks?page=$page';

    if (from != null && until != null) {
      stringUrl += '&from=$from&until=$until';
    }

    if (sortOrder != null) {
      stringUrl += '&sort-order=$sortOrder';
    }

    final Uri url = Uri.parse(stringUrl);

    final authToken = await AuthService.getToken();

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
        jsonResponse,
        (json) => ArtworksPaginated.fromJson(json),
      );
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }

  Future<SuccessResponse<Artwork>> createArtwork(
    int studentId,
    CreateArtworkDto dto,
  ) async {
    if (dto.photo == null) {
      throw Exception('Foto harus diisi');
    }

    final uploadedPhotoResponse = await FileService().uploadPhoto(dto.photo!);
    final photoLink = uploadedPhotoResponse.payload!.filePath;

    final Map<String, dynamic> requestBody = {
      'description': dto.description,
      'feedback': dto.feedback,
      'photoLink': photoLink,
      'learningGoals': dto.learningGoals,
    };

    final Uri url = Uri.parse('$baseUrl/students/$studentId/artworks');
    final authToken = await AuthService.getToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 201) {
      return SuccessResponse.fromJson(
        jsonResponse,
        (data) => Artwork.fromJson(data),
      );
    } else if (response.statusCode == 422) {
      final failResponse = FailResponse.fromJson(jsonResponse);
      throw ValidationException(failResponse.errors ?? {});
    } else {
      throw Exception('Tidak bisa menambahkan hasil karya.');
    }
  }

  Future<SuccessResponse<Artwork>> showArtwork(
    int studentId,
    int artworkId,
  ) async {
    final url = Uri.parse('$baseUrl/students/$studentId/artworks/$artworkId');
    final authToken = await AuthService.getToken();

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
        jsonResponse,
        (json) => Artwork.fromJson(json),
      );
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
    int studentId,
    int artworkId,
    EditArtworkDto dto,
  ) async {
    String? photoLink;
    if (dto.photo != null) {
      final uploadedPhotoResponse = await FileService().uploadPhoto(dto.photo!);
      photoLink = uploadedPhotoResponse.payload!.filePath;
    }

    final Map<String, dynamic> requestBody = {
      'description': dto.description,
      'feedback': dto.feedback,
      'photoLink': photoLink,
      'learningGoals': dto.learningGoals,
    };

    final url = Uri.parse('$baseUrl/students/$studentId/artworks/$artworkId');
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
        jsonResponse,
        (json) => Artwork.fromJson(json),
      );
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
    int studentId,
    int artworkId,
  ) async {
    final url = Uri.parse('$baseUrl/students/$studentId/artworks/$artworkId');
    final authToken = await AuthService.getToken();

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
        jsonResponse,
        (json) => ApiResponse.fromJson(json, null),
      );
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
