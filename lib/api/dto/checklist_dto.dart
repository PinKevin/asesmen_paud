import 'package:image_picker/image_picker.dart';

class ChecklistPointDto {
  final int learningGoalId;
  final String context;
  final String observedEvent;
  final bool hasAppeared;

  ChecklistPointDto(
      {required this.learningGoalId,
      required this.context,
      required this.observedEvent,
      required this.hasAppeared});

  Map<String, dynamic> toJson() {
    return {
      'learningGoalId': learningGoalId,
      'context': context,
      'observedEvent': observedEvent,
      'hasAppeared': hasAppeared,
    };
  }
}

class CreateChecklistDto {
  final List<dynamic> checklistPoints;

  CreateChecklistDto(this.checklistPoints);

  Map<String, dynamic> toJson() {
    return {
      'checklistPoints': checklistPoints.map((point) => point.toJson()).toList()
    };
  }
}

class EditChecklistDto {
  final String? description;
  final String? feedback;
  final List<int>? learningGoals;
  final XFile? photo;

  EditChecklistDto(
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
