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
      id: int.tryParse(json['id'].toString()) ?? 0,
      learningScopeName: json['learningScopeName'],
      competencyId: int.tryParse(json['competencyId'].toString()) ?? 0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
