import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/payload/paginate_meta_payload.dart';

class ArtworksPaginated {
  final PaginationMeta meta;
  final List<Artwork> data;

  ArtworksPaginated({required this.meta, required this.data});

  factory ArtworksPaginated.fromJson(Map<String, dynamic> json) {
    return ArtworksPaginated(
        meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
        data: (json['data'] as List)
            .map((student) => Artwork.fromJson(student as Map<String, dynamic>))
            .toList());
  }
}

class Artwork {
  final int id;
  final String photoLink;
  final String description;
  final String feedback;
  final int studentId;
  final String? createdAt;
  final String? updatedAt;
  final List<LearningGoal>? learningGoals;

  Artwork({
    required this.id,
    required this.photoLink,
    required this.description,
    required this.feedback,
    required this.studentId,
    this.createdAt,
    this.updatedAt,
    this.learningGoals,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
        id: int.tryParse(json['id'].toString()) ?? 0,
        photoLink: json['photoLink'] as String,
        description: json['description'] as String,
        feedback: json['feedback'] as String,
        studentId: int.tryParse(json['studentId'].toString()) ?? 0,
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
