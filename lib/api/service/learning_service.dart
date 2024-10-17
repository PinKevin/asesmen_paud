import 'dart:convert';

import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/payload/learning_scope_payload.dart';
import 'package:asesmen_paud/api/payload/sub_learning_scope_payload.dart';
import 'package:http/http.dart' as http;
import 'package:asesmen_paud/api/base_url.dart';
import 'package:asesmen_paud/api/payload/competency_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';

class LearningService {
  static Future<SuccessResponse<List<CompetencyPayload>>>
      getAllCompetencies() async {
    final url = Uri.parse('$baseUrl/competencies');
    final authToken = await AuthService.getToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['payload'] is List) {
        final List<CompetencyPayload> competencies =
            (jsonResponse['payload'] as List)
                .map((item) => CompetencyPayload.fromJson(item))
                .toList();

        return SuccessResponse<List<CompetencyPayload>>(
          status: jsonResponse['status'],
          message: jsonResponse['message'],
          payload: competencies,
        );
      } else {
        throw Exception('Payload bukan list');
      }
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }

  static Future<SuccessResponse<List<LearningScopePayload>>>
      getAllLearningScopes(int competencyId) async {
    final url = Uri.parse('$baseUrl/learning-scopes/$competencyId');
    final authToken = await AuthService.getToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['payload'] is List) {
        final List<LearningScopePayload> competencies =
            (jsonResponse['payload'] as List)
                .map((item) => LearningScopePayload.fromJson(item))
                .toList();

        return SuccessResponse<List<LearningScopePayload>>(
          status: jsonResponse['status'],
          message: jsonResponse['message'],
          payload: competencies,
        );
      } else {
        throw Exception('Payload bukan list');
      }
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }

  static Future<SuccessResponse<List<SubLearningScopePayload>>>
      getAllSubLearningScopes(int learningScopeId) async {
    final url = Uri.parse('$baseUrl/sub-learning-scopes/$learningScopeId');
    final authToken = await AuthService.getToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['payload'] is List) {
        final List<SubLearningScopePayload> competencies =
            (jsonResponse['payload'] as List)
                .map((item) => SubLearningScopePayload.fromJson(item))
                .toList();

        return SuccessResponse<List<SubLearningScopePayload>>(
          status: jsonResponse['status'],
          message: jsonResponse['message'],
          payload: competencies,
        );
      } else {
        throw Exception('Payload bukan list');
      }
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }

  static Future<SuccessResponse<List<LearningGoalPayload>>> getAllLearningGoals(
      int subLearningScopeId) async {
    final url = Uri.parse('$baseUrl/learning-goals/$subLearningScopeId');
    final authToken = await AuthService.getToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['payload'] is List) {
        final List<LearningGoalPayload> competencies =
            (jsonResponse['payload'] as List)
                .map((item) => LearningGoalPayload.fromJson(item))
                .toList();

        return SuccessResponse<List<LearningGoalPayload>>(
          status: jsonResponse['status'],
          message: jsonResponse['message'],
          payload: competencies,
        );
      } else {
        throw Exception('Payload bukan list');
      }
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }
}
