class LearningGoal {
  final int id;
  final String learningGoalName;
  final String learningGoalCode;
  final int subLearningScopeId;
  final String? createdAt;
  final String? updatedAt;

  LearningGoal(
      {required this.id,
      required this.learningGoalName,
      required this.learningGoalCode,
      required this.subLearningScopeId,
      this.createdAt,
      this.updatedAt});

  factory LearningGoal.fromJson(Map<String, dynamic> json) {
    return LearningGoal(
      id: int.tryParse(json['id'].toString()) ?? 0,
      learningGoalName: json['learningGoalName'],
      learningGoalCode: json['learningGoalCode'],
      subLearningScopeId:
          int.tryParse(json['subLearningScopeId'].toString()) ?? 0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  String? get goalName => null;

  List<int> idToJson() {
    return [id];
  }
}
