class SubLearningScopePayload {
  final int id;
  final String subLearningScopeName;
  final int learningScopeId;
  final String? createdAt;
  final String? updatedAt;

  SubLearningScopePayload(
      {required this.id,
      required this.subLearningScopeName,
      required this.learningScopeId,
      this.createdAt,
      this.updatedAt});

  factory SubLearningScopePayload.fromJson(Map<String, dynamic> json) {
    return SubLearningScopePayload(
      id: json['id'],
      subLearningScopeName: json['subLearningScopeName'],
      learningScopeId: json['learningScopeId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
