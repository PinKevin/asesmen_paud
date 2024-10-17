class SubLearningScope {
  final int id;
  final String subLearningScopeName;
  final int learningScopeId;
  final String? createdAt;
  final String? updatedAt;

  SubLearningScope(
      {required this.id,
      required this.subLearningScopeName,
      required this.learningScopeId,
      this.createdAt,
      this.updatedAt});

  factory SubLearningScope.fromJson(Map<String, dynamic> json) {
    return SubLearningScope(
      id: json['id'],
      subLearningScopeName: json['subLearningScopeName'],
      learningScopeId: json['learningScopeId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
