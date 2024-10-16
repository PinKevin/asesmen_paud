class LearningGoalPayload {
  final int id;
  final String learningGoalName;
  final String learningGoalCode;
  final String? createdAt;
  final String? updatedAt;

  LearningGoalPayload(
      {required this.id,
      required this.learningGoalName,
      required this.learningGoalCode,
      this.createdAt,
      this.updatedAt});

  factory LearningGoalPayload.fromJson(Map<String, dynamic> json) {
    return LearningGoalPayload(
      id: json['id'],
      learningGoalName: json['learningGoalName'],
      learningGoalCode: json['learningGoalCode'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
