import 'package:image_picker/image_picker.dart';

class CreateSeriesPhotoDto {
  final String description;
  final String feedback;
  final List<int> learningGoals;
  final List<XFile> photos;

  CreateSeriesPhotoDto(
      {required this.description,
      required this.feedback,
      required this.learningGoals,
      required this.photos});

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'feedback': feedback,
      'learningGoals': learningGoals.map((goal) => goal.toString()).toList(),
      'photos': photos.map((photo) => photo.toString()).toList()
    };
  }
}

class EditSeriesPhotoDto {
  final String? description;
  final String? feedback;
  final List<int>? learningGoals;
  final List<XFile>? photos;

  EditSeriesPhotoDto(
      {required this.description,
      required this.feedback,
      required this.learningGoals,
      required this.photos});

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'feedback': feedback,
      'learningGoals': learningGoals?.map((goal) => goal.toString()).toList(),
      'photos': photos?.map((photo) => photo.toString()).toList()
    };
  }
}
