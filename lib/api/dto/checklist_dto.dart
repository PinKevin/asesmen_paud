import 'package:asesmen_paud/api/payload/checklist_payload.dart';

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

  factory ChecklistPointDto.fromChecklistPoint(ChecklistPoint checklistPoint) {
    return ChecklistPointDto(
        learningGoalId: checklistPoint.learningGoalId,
        context: checklistPoint.context,
        observedEvent: checklistPoint.observedEvent,
        hasAppeared: checklistPoint.hasAppeared == 1 ? true : false);
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
  final List<dynamic> checklistPoints;

  EditChecklistDto(this.checklistPoints);

  Map<String, dynamic> toJson() {
    return {
      'checklistPoints': checklistPoints.map((point) => point.toJson()).toList()
    };
  }
}
