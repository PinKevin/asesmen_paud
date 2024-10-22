import 'package:image_picker/image_picker.dart';

class CreateArtworkDto {
  final String description;
  final String feedback;
  final List<int> learningGoals;
  final XFile? photo;

  CreateArtworkDto(
      {required this.description,
      required this.feedback,
      required this.learningGoals,
      required this.photo});

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'feedback': feedback,
      'learningGoals': learningGoals.map((goal) => goal.toString()).toList()
    };
  }
}

class EditArtworkDto {
  final String? description;
  final String? feedback;
  final List<int>? learningGoals;
  final XFile? photo;

  EditArtworkDto(
      {required this.description,
      required this.feedback,
      required this.learningGoals,
      required this.photo});

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'feedback': feedback,
      'learningGoals': learningGoals?.map((goal) => goal.toString()).toList()
    };
  }
}
