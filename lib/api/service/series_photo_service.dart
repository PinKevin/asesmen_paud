import 'dart:convert';
import 'dart:io';

import 'package:asesmen_paud/api/dto/artwork_dto.dart';
import 'package:asesmen_paud/api/dto/series_photo_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/artwork_payload.dart';
import 'package:asesmen_paud/api/payload/series_photo_payload.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';
import 'package:path_provider/path_provider.dart';

class SeriesPhotoService {
  Future<SuccessResponse<SeriesPhotoPaginated>> getAllStudentSeriesPhoto(
      int studentId,
      int page,
      String? from,
      String? until,
      String? sortOrder) async {
    String stringUrl = '$baseUrl/students/$studentId/series-photos?page=$page';

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
          jsonResponse, (json) => SeriesPhotoPaginated.fromJson(json));
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }

  Future<SuccessResponse<SeriesPhoto>> createSeriesPhoto(
      int studentId, CreateSeriesPhotoDto dto) async {
    final Uri url = Uri.parse('$baseUrl/students/$studentId/series-photos');
    final authToken = await AuthService.getToken();

    var request = http.MultipartRequest('POST', url);
    request.fields['description'] = dto.description;
    request.fields['feedback'] = dto.feedback;
    for (int i = 0; i < dto.learningGoals.length; i++) {
      request.fields['learningGoals[$i]'] = dto.learningGoals[i].toString();
    }

    for (var photo in dto.photos) {
      File compressedImage = await _compressImage(File(photo.path));
      request.files.add(
          await http.MultipartFile.fromPath('photo[]', compressedImage.path));
    }

    request.headers.addAll({
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'multipart/form-data'
    });

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    final jsonResponse = json.decode(responseBody.body);

    if (response.statusCode == 201) {
      return SuccessResponse.fromJson(
          jsonResponse, (data) => SeriesPhoto.fromJson(data));
    } else if (response.statusCode == 422) {
      final failResponse = FailResponse.fromJson(jsonResponse);
      throw ValidationException(failResponse.errors ?? {});
    } else {
      throw Exception(
          'Tidak bisa menambahkan foto berseri. ${responseBody.body}');
    }
  }

  // Future<SuccessResponse<Artwork>> showArtwork(
  //     int studentId, int artworkId) async {
  //   final url = Uri.parse('$baseUrl/students/$studentId/artworks/$artworkId');
  //   final authToken = await AuthService.getToken();

  //   final response = await http.get(url, headers: {
  //     'Authorization': 'Bearer $authToken',
  //   });

  //   final jsonResponse = json.decode(response.body);

  //   if (response.statusCode == 200) {
  //     return SuccessResponse.fromJson(
  //         jsonResponse, (json) => Artwork.fromJson(json));
  //   } else if (response.statusCode == 404) {
  //     String message =
  //         jsonResponse['message'] ?? 'Hasil karya tidak dapat ditemukan';
  //     throw ErrorException(message);
  //   } else {
  //     String message =
  //         jsonResponse['message'] ?? 'Terjadi error saat mengambil hasil karya';
  //     throw ErrorException(message);
  //   }
  // }

  // Future<SuccessResponse<Artwork>> editArtwork(
  //     int studentId, int artworkId, EditArtworkDto dto) async {
  //   final url = Uri.parse('$baseUrl/students/$studentId/artworks/$artworkId');
  //   final authToken = await AuthService.getToken();

  //   var request = http.MultipartRequest('PUT', url);
  //   request.fields['description'] = dto.description!;
  //   request.fields['feedback'] = dto.feedback!;
  //   for (int i = 0; i < dto.learningGoals!.length; i++) {
  //     request.fields['learningGoals[$i]'] = dto.learningGoals![i].toString();
  //   }

  //   if (dto.photo != null) {
  //     final compressedImage = await _compressImage(File(dto.photo!.path));
  //     request.files.add(
  //         await http.MultipartFile.fromPath('photo', compressedImage.path));
  //   }

  //   request.headers.addAll({
  //     'Authorization': 'Bearer $authToken',
  //     'Content-Type': 'multipart/form-data'
  //   });

  //   final response = await request.send();
  //   final responseBody = await http.Response.fromStream(response);
  //   final jsonResponse = json.decode(responseBody.body);

  //   if (response.statusCode == 200) {
  //     return SuccessResponse.fromJson(
  //         jsonResponse, (json) => Artwork.fromJson(json));
  //   } else if (response.statusCode == 404) {
  //     String message =
  //         jsonResponse['message'] ?? 'Hasil karya tidak dapat ditemukan';
  //     throw ErrorException(message);
  //   } else if (response.statusCode == 422) {
  //     final failResponse = FailResponse.fromJson(jsonResponse);
  //     throw ValidationException(failResponse.errors ?? {});
  //   } else {
  //     String message =
  //         jsonResponse['message'] ?? 'Terjadi error saat mengambil hasil karya';
  //     throw ErrorException(message);
  //   }
  // }

  // Future<SuccessResponse<ApiResponse>> deleteArtwork(
  //     int studentId, int artworkId) async {
  //   final url = Uri.parse('$baseUrl/students/$studentId/artworks/$artworkId');
  //   final authToken = await AuthService.getToken();

  //   final response = await http.delete(url, headers: {
  //     'Authorization': 'Bearer $authToken',
  //   });

  //   final jsonResponse = json.decode(response.body);

  //   if (response.statusCode == 200) {
  //     return SuccessResponse.fromJson(
  //         jsonResponse, (json) => ApiResponse.fromJson(json, null));
  //   } else if (response.statusCode == 404) {
  //     String message =
  //         jsonResponse['message'] ?? 'Hasil karya tidak dapat ditemukan';
  //     throw ErrorException(message);
  //   } else {
  //     String message =
  //         jsonResponse['message'] ?? 'Terjadi error saat menghapus hasil karya';
  //     throw ErrorException(message);
  //   }
  // }

  Future<File> _compressImage(File file) async {
    final compressedBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 85);

    final tempDir = await getTemporaryDirectory();
    final tempPath =
        path.join(tempDir.path, 'compressed_${path.basename(file.path)}');
    final compressedFile = File(tempPath);

    await compressedFile.writeAsBytes(compressedBytes!);
    return compressedFile;
  }
}
