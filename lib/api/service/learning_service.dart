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
  static Future<SuccessResponse<List<Competency>>> getAllCompetencies() async {
    final url = Uri.parse('$baseUrl/competencies');
    final authToken = await AuthService.getToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['payload'] is List) {
        final List<Competency> competencies = (jsonResponse['payload'] as List)
            .map((item) => Competency.fromJson(item))
            .toList();

        return SuccessResponse<List<Competency>>(
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

  static Future<SuccessResponse<List<LearningScope>>> getAllLearningScopes(
      int competencyId) async {
    final url = Uri.parse('$baseUrl/learning-scopes/$competencyId');
    final authToken = await AuthService.getToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['payload'] is List) {
        final List<LearningScope> competencies =
            (jsonResponse['payload'] as List)
                .map((item) => LearningScope.fromJson(item))
                .toList();

        return SuccessResponse<List<LearningScope>>(
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

  static Future<SuccessResponse<List<SubLearningScope>>>
      getAllSubLearningScopes(int learningScopeId) async {
    final url = Uri.parse('$baseUrl/sub-learning-scopes/$learningScopeId');
    final authToken = await AuthService.getToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['payload'] is List) {
        final List<SubLearningScope> competencies =
            (jsonResponse['payload'] as List)
                .map((item) => SubLearningScope.fromJson(item))
                .toList();

        return SuccessResponse<List<SubLearningScope>>(
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

  static Future<SuccessResponse<List<LearningGoal>>> getAllLearningGoals(
      int subLearningScopeId) async {
    final url = Uri.parse('$baseUrl/learning-goals/$subLearningScopeId');
    final authToken = await AuthService.getToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['payload'] is List) {
        final List<LearningGoal> competencies =
            (jsonResponse['payload'] as List)
                .map((item) => LearningGoal.fromJson(item))
                .toList();

        return SuccessResponse<List<LearningGoal>>(
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

  static Future<SuccessResponse<LearningGoal>> getLearningGoalById(
      int learningGoalId) async {
    final url = Uri.parse('$baseUrl/learning-goal-by-id/$learningGoalId');
    final authToken = await AuthService.getToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      return SuccessResponse.fromJson(
          jsonResponse, (json) => LearningGoal.fromJson(json));
    } else {
      throw Exception('Terjadi error. ${response.body}');
    }
  }
}
