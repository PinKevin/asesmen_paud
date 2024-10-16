import 'package:asesmen_paud/api/payload/paginate_meta_payload.dart';

class PaginateStudentsPayload {
  final PaginateMetaPayload meta;
  final List<StudentPayload> data;

  PaginateStudentsPayload({required this.meta, required this.data});

  factory PaginateStudentsPayload.fromJson(Map<String, dynamic> json) {
    return PaginateStudentsPayload(
        meta: PaginateMetaPayload.fromJson(json['meta']),
        data: List<StudentPayload>.from(
            json['data'].map((item) => StudentPayload.fromJson(item))));
  }
}

class StudentPayload {
  final int id;
  final String name;
  final String nisn;
  final String placeOfBirth;
  final String dateOfBirth;
  final String gender;
  final String religion;
  final String acceptanceDate;
  final String classId;
  final String? createdAt;
  final String? updatedAt;

  StudentPayload(
      {required this.id,
      required this.name,
      required this.nisn,
      required this.placeOfBirth,
      required this.dateOfBirth,
      required this.gender,
      required this.religion,
      required this.acceptanceDate,
      required this.classId,
      this.createdAt,
      this.updatedAt});

  factory StudentPayload.fromJson(Map<String, dynamic> json) {
    return StudentPayload(
      id: json['id'],
      name: json['name'],
      nisn: json['nisn'],
      placeOfBirth: json['placeOfBirth'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      religion: json['religion'],
      acceptanceDate: json['acceptanceDate'],
      classId: json['classId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
