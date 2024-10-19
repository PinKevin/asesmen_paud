import 'package:image_picker/image_picker.dart';

class CreateAnecdotalDto {
  final String description;
  final String feedback;
  final List<int> learningGoals;
  final XFile? photo;

  CreateAnecdotalDto(
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

class EditAnecdotalDto {
  final String? description;
  final String? feedback;
  final List<int>? learningGoals;
  final XFile? photo;

  EditAnecdotalDto(
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
