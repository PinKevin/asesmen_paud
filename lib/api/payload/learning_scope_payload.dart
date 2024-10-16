class LearningScopePayload {
  final int id;
  final String learningScopeName;
  final int competencyId;
  final String? createdAt;
  final String? updatedAt;

  LearningScopePayload(
      {required this.id,
      required this.learningScopeName,
      required this.competencyId,
      this.createdAt,
      this.updatedAt});

  factory LearningScopePayload.fromJson(Map<String, dynamic> json) {
    return LearningScopePayload(
      id: json['id'],
      learningScopeName: json['learningScopeName'],
      competencyId: json['competencyId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
