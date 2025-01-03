import 'dart:convert';

import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/file_payload.dart';
import 'package:http/http.dart' as http;

import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FileService {
  Future<SuccessResponse<FilePayload>> uploadPhoto(XFile photo) async {
    final Uri url = Uri.parse('$baseUrl/upload-photo');
    final authToken = await AuthService.getToken();

    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

    request.headers.addAll({
      'Authorization': 'Bearer $authToken',
    });

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    final jsonResponse = json.decode(responseBody.body);

    if (response.statusCode == 201) {
      return SuccessResponse.fromJson(
        jsonResponse,
        (payload) => FilePayload.fromJson(payload),
      );
    } else if (response.statusCode == 422) {
      final failResponse = FailResponse.fromJson(jsonResponse);
      throw ValidationException(failResponse.errors ?? {});
    } else {
      throw Exception('Tidak bisa mengunggah file. Coba lagi.');
    }
  }
}
