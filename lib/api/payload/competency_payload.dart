class Competency {
  final int id;
  final String competencyName;
  final String element;
  final String? createdAt;
  final String? updatedAt;

  Competency(
      {required this.id,
      required this.competencyName,
      required this.element,
      this.createdAt,
      this.updatedAt});

  factory Competency.fromJson(Map<String, dynamic> json) {
    return Competency(
      id: int.tryParse(json['id'].toString()) ?? 0,
      competencyName: json['competencyName'],
      element: json['element'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
