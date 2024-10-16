class CompetencyPayload {
  final int id;
  final String competencyName;
  final String element;
  final String? createdAt;
  final String? updatedAt;

  CompetencyPayload(
      {required this.id,
      required this.competencyName,
      required this.element,
      this.createdAt,
      this.updatedAt});

  factory CompetencyPayload.fromJson(Map<String, dynamic> json) {
    return CompetencyPayload(
      id: json['id'],
      competencyName: json['competencyName'],
      element: json['element'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
