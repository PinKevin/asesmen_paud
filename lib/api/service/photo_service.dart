import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';

class PhotoService {
  Future<Uint8List?> getPhoto(String photoLink) async {
    final url = Uri.parse('$baseUrl/storage/uploads/$photoLink');
    final authToken = await AuthService.getToken();

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return null;
    }
  }
}
