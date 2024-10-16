import 'package:asesmen_paud/api/payload/paginate_meta_payload.dart';

class PaginateStudentsPayload {
  final PaginateMetaPayload meta;
  final List<StudentPayload> data;

  PaginateStudentsPayload({required this.meta, required this.data});

  factory PaginateStudentsPayload.fromJson(Map<String, dynamic> json) {
    return PaginateStudentsPayload(
        meta:
            PaginateMetaPayload.fromJson(json['meta'] as Map<String, dynamic>),
        data: (json['data'] as List)
            .map((student) =>
                StudentPayload.fromJson(student as Map<String, dynamic>))
            .toList());
  }
}

class StudentPayload {
  final int id;
  final String name;
  final String nisn;
  final String? placeOfBirth;
  final String? dateOfBirth;
  final String? gender;
  final String? religion;
  final String? acceptanceDate;
  final int classId;
  final String? createdAt;
  final String? updatedAt;

  StudentPayload(
      {required this.id,
      required this.name,
      required this.nisn,
      this.placeOfBirth,
      this.dateOfBirth,
      this.gender,
      this.religion,
      this.acceptanceDate,
      required this.classId,
      this.createdAt,
      this.updatedAt});

  factory StudentPayload.fromJson(Map<String, dynamic> json) {
    return StudentPayload(
      id: json['id'] as int,
      name: json['name'] as String,
      nisn: json['nisn'] as String,
      placeOfBirth: json['place_of_birth'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      religion: json['religion'] as String?,
      acceptanceDate: json['acceptance_date'] as String?,
      classId: json['class_id'] as int,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
