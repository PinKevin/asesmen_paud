import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/payload/paginate_meta_payload.dart';

class PhotoForSeriesPhoto {
  final int id;
  final String photoLink;
  final int seriesPhotoAssessmentId;
  final String? createdAt;
  final String? updatedAt;

  PhotoForSeriesPhoto(
      {required this.id,
      required this.photoLink,
      required this.seriesPhotoAssessmentId,
      this.createdAt,
      this.updatedAt});

  factory PhotoForSeriesPhoto.fromJson(Map<String, dynamic> json) {
    return PhotoForSeriesPhoto(
      id: int.tryParse(json['id'].toString()) ?? 0,
      photoLink: json['photoLink'] as String,
      seriesPhotoAssessmentId:
          int.tryParse(json['seriesPhotoAssessmentId'].toString()) ?? 0,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class SeriesPhoto {
  final int id;
  final String description;
  final String feedback;
  final int studentId;
  final String? createdAt;
  final String? updatedAt;
  final List<LearningGoal>? learningGoals;
  final List<PhotoForSeriesPhoto>? seriesPhotos;
  // final List<String>? photosLink;

  SeriesPhoto({
    required this.id,
    required this.description,
    required this.feedback,
    required this.studentId,
    this.createdAt,
    this.updatedAt,
    this.learningGoals,
    this.seriesPhotos,
    // this.photosLink,
  });

  factory SeriesPhoto.fromJson(Map<String, dynamic> json) {
    return SeriesPhoto(
        id: int.tryParse(json['id'].toString()) ?? 0,
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
            : null,
        seriesPhotos: json.containsKey('seriesPhotos')
            ? (json['seriesPhotos'] as List)
                .map((photo) =>
                    PhotoForSeriesPhoto.fromJson(photo as Map<String, dynamic>))
                .toList()
            : null);
  }
}

class SeriesPhotoPaginated {
  final PaginationMeta meta;
  final List<SeriesPhoto> data;

  SeriesPhotoPaginated({required this.meta, required this.data});

  factory SeriesPhotoPaginated.fromJson(Map<String, dynamic> json) {
    return SeriesPhotoPaginated(
        meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
        data: (json['data'] as List)
            .map((student) =>
                SeriesPhoto.fromJson(student as Map<String, dynamic>))
            .toList());
  }
}
