class LearningScope {
  final int id;
  final String learningScopeName;
  final int competencyId;
  final String? createdAt;
  final String? updatedAt;

  LearningScope(
      {required this.id,
      required this.learningScopeName,
      required this.competencyId,
      this.createdAt,
      this.updatedAt});

  factory LearningScope.fromJson(Map<String, dynamic> json) {
    return LearningScope(
      id: json['id'],
      learningScopeName: json['learningScopeName'],
      competencyId: json['competencyId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
