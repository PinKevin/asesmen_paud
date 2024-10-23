import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/payload/paginate_meta_payload.dart';

class ChecklistPoint {
  final int id;
  final String context;
  final String observedEvent;
  final int hasAppeared;
  final int checklistAssessmentId;
  final int learningGoalId;
  final String? createdAt;
  final String? updatedAt;
  final LearningGoal? learningGoal;

  ChecklistPoint(
      {required this.id,
      required this.context,
      required this.observedEvent,
      required this.hasAppeared,
      required this.checklistAssessmentId,
      required this.learningGoalId,
      this.createdAt,
      this.updatedAt,
      this.learningGoal});

  factory ChecklistPoint.fromJson(Map<String, dynamic> json) {
    return ChecklistPoint(
        id: int.tryParse(json['id'].toString()) ?? 0,
        context: json['context'] as String,
        observedEvent: json['observedEvent'] as String,
        hasAppeared: int.tryParse(json['hasAppeared'].toString()) ?? 0,
        checklistAssessmentId:
            int.tryParse(json['checklistAssessmentId'].toString()) ?? 0,
        learningGoalId: int.tryParse(json['learningGoalId'].toString()) ?? 0,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
        learningGoal: json.containsKey('learningGoal')
            ? LearningGoal.fromJson(json['learningGoal'])
            : null);
  }
}

class Checklist {
  final int id;
  final int studentId;
  final String? createdAt;
  final String? updatedAt;
  final List<ChecklistPoint>? checklistPoints;

  Checklist({
    required this.id,
    required this.studentId,
    this.createdAt,
    this.updatedAt,
    this.checklistPoints,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
        id: int.tryParse(json['id'].toString()) ?? 0,
        studentId: int.tryParse(json['studentId'].toString()) ?? 0,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
        checklistPoints: json.containsKey('checklistPoints')
            ? (json['checklistPoints'] as List)
                .map((checklistPoint) => ChecklistPoint.fromJson(
                    checklistPoint as Map<String, dynamic>))
                .toList()
            : []);
  }
}

class ChecklistsPaginated {
  final PaginationMeta meta;
  final List<Checklist> data;

  ChecklistsPaginated({required this.meta, required this.data});

  factory ChecklistsPaginated.fromJson(Map<String, dynamic> json) {
    return ChecklistsPaginated(
        meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
        data: (json['data'] as List)
            .map((checklist) =>
                Checklist.fromJson(checklist as Map<String, dynamic>))
            .toList());
  }
}
