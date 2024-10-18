import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/payload/paginate_meta_payload.dart';

class AnecdotalsPaginated {
  final PaginationMeta meta;
  final List<Anecdotal> data;

  AnecdotalsPaginated({required this.meta, required this.data});

  factory AnecdotalsPaginated.fromJson(Map<String, dynamic> json) {
    return AnecdotalsPaginated(
        meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
        data: (json['data'] as List)
            .map((student) =>
                Anecdotal.fromJson(student as Map<String, dynamic>))
            .toList());
  }
}

class Anecdotal {
  final int id;
  final String photoLink;
  final String description;
  final String feedback;
  final int studentId;
  final String? createdAt;
  final String? updatedAt;
  final List<LearningGoal>? learningGoals;

  Anecdotal({
    required this.id,
    required this.photoLink,
    required this.description,
    required this.feedback,
    required this.studentId,
    this.createdAt,
    this.updatedAt,
    this.learningGoals,
  });

  factory Anecdotal.fromJson(Map<String, dynamic> json) {
    return Anecdotal(
        id: json['id'] as int,
        photoLink: json['photoLink'] as String,
        description: json['description'] as String,
        feedback: json['feedback'] as String,
        studentId: json['studentId'] as int,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
        learningGoals: json.containsKey('learningGoals')
            ? (json['learningGoals'] as List)
                .map((learningGoal) =>
                    LearningGoal.fromJson(learningGoal as Map<String, dynamic>))
                .toList()
            : null);
  }
}
