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
      id: int.tryParse(json['id'].toString()) ?? 0,
      subLearningScopeName: json['subLearningScopeName'],
      learningScopeId: int.tryParse(json['learningScopeId'].toString()) ?? 0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
