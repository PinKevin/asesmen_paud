import 'package:asesmen_paud/api/payload/paginate_meta_payload.dart';

class StudentsPaginated {
  final PaginationMeta meta;
  final List<Student> data;

  StudentsPaginated({required this.meta, required this.data});

  factory StudentsPaginated.fromJson(Map<String, dynamic> json) {
    return StudentsPaginated(
        meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
        data: (json['data'] as List)
            .map((student) => Student.fromJson(student as Map<String, dynamic>))
            .toList());
  }
}

class Class {
  final int id;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  Class(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt});

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
        id: json['id'],
        name: json['name'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt']);
  }
}

class Student {
  final int id;
  final String name;
  final String nisn;
  final String? placeOfBirth;
  final String? dateOfBirth;
  final String? gender;
  final String? religion;
  final String? acceptanceDate;
  final String? createdAt;
  final String? updatedAt;

  Student(
      {required this.id,
      required this.name,
      required this.nisn,
      this.placeOfBirth,
      this.dateOfBirth,
      this.gender,
      this.religion,
      this.acceptanceDate,
      this.createdAt,
      this.updatedAt});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int,
      name: json['name'] as String,
      nisn: json['nisn'] as String,
      placeOfBirth: json['place_of_birth'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      religion: json['religion'] as String?,
      acceptanceDate: json['acceptance_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
