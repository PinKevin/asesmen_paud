import 'dart:convert';

import 'package:asesmen_paud/api/dto/series_photo_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/file_payload.dart';
import 'package:asesmen_paud/api/payload/series_photo_payload.dart';
import 'package:asesmen_paud/api/service/file_service.dart';
import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';

class SeriesPhotoService {
  Future<SuccessResponse<SeriesPhotoPaginated>> getAllStudentSeriesPhotos(
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
        jsonResponse,
        (json) => SeriesPhotoPaginated.fromJson(json),
      );
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }

  Future<SuccessResponse<SeriesPhoto>> createSeriesPhoto(
    int studentId,
    CreateSeriesPhotoDto dto,
  ) async {
    if (dto.photos.length < 3 || dto.photos.length > 5) {
      throw ErrorException('Foto harus berjumlah 3-5');
    }

    // List<String> photoLinks = [];
    // for (int i = 0; i < dto.photos.length; i++) {
    //   final uploadedPhotoResponse =
    //       await FileService().uploadPhoto(dto.photos[i]);
    //   photoLinks.add(uploadedPhotoResponse.payload!.filePath);
    // }
    List<Future<SuccessResponse<FilePayload>>> fileUploadFutures = dto.photos
        .map(
          (photo) => FileService().uploadPhoto(photo),
        )
        .toList();

    List<SuccessResponse<FilePayload>> fileUploadResponses =
        await Future.wait(fileUploadFutures);

    List<String> photoLinks = fileUploadResponses
        .map((response) => response.payload!.filePath)
        .toList();

    final Map<String, dynamic> requestBody = {
      'description': dto.description,
      'feedback': dto.feedback,
      'photoLinks': photoLinks,
      'learningGoals': dto.learningGoals,
    };

    final Uri url = Uri.parse('$baseUrl/students/$studentId/series-photos');
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
          jsonResponse, (data) => SeriesPhoto.fromJson(data));
    } else if (response.statusCode == 422) {
      final failResponse = FailResponse.fromJson(jsonResponse);
      throw ValidationException(failResponse.errors ?? {});
    } else {
      throw Exception('Tidak bisa menambahkan foto berseri.');
    }
  }

  Future<SuccessResponse<SeriesPhoto>> showSeriesPhoto(
      int studentId, int seriesPhotoId) async {
    final url =
        Uri.parse('$baseUrl/students/$studentId/series-photos/$seriesPhotoId');
    final authToken = await AuthService.getToken();

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => SeriesPhoto.fromJson(json));
    } else if (response.statusCode == 404) {
      String message =
          jsonResponse['message'] ?? 'Foto berseri tidak dapat ditemukan';
      throw ErrorException(message);
    } else {
      String message = jsonResponse['message'] ??
          'Terjadi error saat mengambil foto berseri';
      throw ErrorException(message);
    }
  }

  // Future<SuccessResponse<SeriesPhoto>> editSeriesPhoto(
  //     int studentId, int seriesPhotoId, EditSeriesPhotoDto dto) async {
  //   final url = Uri.parse('$baseUrl/students/$studentId/series-photos/$seriesPhotoId');
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
  //         jsonResponse, (json) => SeriesPhoto.fromJson(json));
  //   } else if (response.statusCode == 404) {
  //     String message =
  //         jsonResponse['message'] ?? 'Foto berseri tidak dapat ditemukan';
  //     throw ErrorException(message);
  //   } else if (response.statusCode == 422) {
  //     final failResponse = FailResponse.fromJson(jsonResponse);
  //     throw ValidationException(failResponse.errors ?? {});
  //   } else {
  //     String message =
  //         jsonResponse['message'] ?? 'Terjadi error saat mengambil foto berseri';
  //     throw ErrorException(message);
  //   }
  // }

  Future<SuccessResponse<ApiResponse>> deleteSeriesPhoto(
      int studentId, int seriesPhotoId) async {
    final url =
        Uri.parse('$baseUrl/students/$studentId/series-photos/$seriesPhotoId');
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
          jsonResponse['message'] ?? 'Foto berseri tidak dapat ditemukan';
      throw ErrorException(message);
    } else {
      String message = jsonResponse['message'] ??
          'Terjadi error saat menghapus foto berseri';
      throw ErrorException(message);
    }
  }
}
