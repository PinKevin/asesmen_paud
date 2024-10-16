import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/payload/paginate_meta_payload.dart';

class PaginateAnecdotalPayload {
  final PaginateMetaPayload meta;
  final List<AnecdotalPayload> data;

  PaginateAnecdotalPayload({required this.meta, required this.data});

  factory PaginateAnecdotalPayload.fromJson(Map<String, dynamic> json) {
    return PaginateAnecdotalPayload(
        meta:
            PaginateMetaPayload.fromJson(json['meta'] as Map<String, dynamic>),
        data: (json['data'] as List)
            .map((student) =>
                AnecdotalPayload.fromJson(student as Map<String, dynamic>))
            .toList());
  }
}

class AnecdotalPayload {
  final int id;
  final String photoLink;
  final String description;
  final String feedback;
  final int studentId;
  final String? createdAt;
  final String? updatedAt;
  final List<LearningGoalPayload> learningGoals;

  AnecdotalPayload({
    required this.id,
    required this.photoLink,
    required this.description,
    required this.feedback,
    required this.studentId,
    this.createdAt,
    this.updatedAt,
    required this.learningGoals,
  });

  factory AnecdotalPayload.fromJson(Map<String, dynamic> json) {
    return AnecdotalPayload(
        id: json['id'],
        photoLink: json['photoLink'],
        description: json['description'],
        feedback: json['feedback'],
        studentId: json['studentId'],
        learningGoals: (json['learningGoals'] as List)
            .map((learningGoal) => LearningGoalPayload.fromJson(
                learningGoal as Map<String, dynamic>))
            .toList());
  }
}
