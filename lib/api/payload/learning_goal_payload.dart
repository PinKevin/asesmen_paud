class LearningGoal {
  final int id;
  final String learningGoalName;
  final String learningGoalCode;
  final String? createdAt;
  final String? updatedAt;

  LearningGoal(
      {required this.id,
      required this.learningGoalName,
      required this.learningGoalCode,
      this.createdAt,
      this.updatedAt});

  factory LearningGoal.fromJson(Map<String, dynamic> json) {
    return LearningGoal(
      id: json['id'],
      learningGoalName: json['learningGoalName'],
      learningGoalCode: json['learningGoalCode'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  String? get goalName => null;

  List<int> idToJson() {
    return [id];
  }
}
