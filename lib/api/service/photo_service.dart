import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';
import 'package:path_provider/path_provider.dart';

class PhotoService {
  Future<Uint8List?> getPhoto(String photoLink) async {
    final url = Uri.parse('$baseUrl/get-photo/$photoLink');
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

  Future<File> compressImage(File file) async {
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
