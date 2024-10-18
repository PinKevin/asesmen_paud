import 'dart:convert';

import 'package:asesmen_paud/api/dto/anecdotal_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/payload/anecdotal_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';

class AnecdotalService {
  Future<SuccessResponse<AnecdotalsPaginated>> getAllStudentAnecdotals(
      int studentId) async {
    final url = Uri.parse('$baseUrl/students/$studentId/anecdotals');
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
    final Uri url = Uri.parse('$baseUrl/students/$studentId/anecdotals');
    final authToken = await AuthService.getToken();

    if (dto.photo == null) {
      throw Exception('Foto harus diisi');
    }

    // List<String> comments = ["1st", "2nd", "3rd"];
    // Map<String, dynamic> args = {"comments": comments};
    // // String testUrl = "myurl.com";
    // var body = json.encode(args);
    // print(body);
    // print(args);
    // print(args.runtimeType);

    // final requestBody = {
    //   'description': dto.description,
    //   'feedback': dto.feedback,
    //   'learningGoals': dto.learningGoals,
    // };
    // List<int> testList = [55, 50];
    // final requestBody = {
    //   'description': dto.description,
    //   'feedback': dto.feedback,
    //   'learningGoals': testList,
    // };

    // var request = http.MultipartRequest('POST', url)
    //   ..fields['description'] = dto.description
    //   ..fields['feedback'] = dto.feedback
    //   ..fields['learningGoals'] =
    //       jsonEncode(dto.learningGoals.map((goal) => goal.toString()).toList());
    var request = http.MultipartRequest('POST', url);
    request.fields['description'] = 'ioenfd';
    request.fields['feedback'] = 'rnfkdn';
    request.fields['learningGoals[]'] = '1';
    // request.fields['learningGoals[1]'] = jsonEncode([2]);

    request.files
        .add(await http.MultipartFile.fromPath('photo', dto.photo!.path));

    request.headers.addAll({
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'multipart/form-data'
    });

    // print(json.encode(dto.learningGoals));
    // print(dto.learningGoals);
    // print(dto.learningGoals.runtimeType);
    // print(requestBody);

    // print(request);
    // print('${jsonEncode(requestBody['learningGoals'])}');
    // print('${requestBody}');
    // print('${requestBody['learningGoals'].runtimeType}');

    // var response = await http.post(
    //   url,
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'Authorization': 'Bearer $authToken'
    //   },
    //   body: json.encode({
    //     'description': 'Anfrn',
    //     'feedback': 'nfrd',
    //     'learningGoals': ['1', '2', '3']
    //   }),
    // );

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    // final jsonResponse = json.decode(responseBody.body);
    final jsonResponse = json.decode(responseBody.body);
    // print(request.fields);
    print(request.fields['learningGoals[]']);
    print(jsonResponse);

    if (response.statusCode == 201) {
      return SuccessResponse.fromJson(jsonResponse, (data) {
        print('Tipe data abis selesai respon ${data.runtimeType}');
        // return Anecdotal(
        //   id: data.id,
        //   photoLink: data.photoLink,
        //   description: data.description,
        //   feedback: data.feedback,
        //   studentId: data.studentId,
        // );
        return Anecdotal.fromJson(data);
      });
    } else if (response.statusCode == 422) {
      final failResponse = FailResponse.fromJson(jsonResponse);
      throw ValidationException(failResponse.errors ?? {});
    } else {
      throw Exception('Tidak bisa menambahkan anekdot.');
    }
  }
}
