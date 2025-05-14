import 'package:image_picker/image_picker.dart';

class CreateStudentDto {
  final String name;
  final String nisn;
  final String placeOfBirth;
  final String dateOfBirth;
  final String gender;
  final String religion;
  final String acceptanceDate;
  final int classId;
  final XFile? photo;

  CreateStudentDto({
    required this.name,
    required this.nisn,
    required this.placeOfBirth,
    required this.dateOfBirth,
    required this.gender,
    required this.religion,
    required this.acceptanceDate,
    required this.classId,
    required this.photo,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nisn': nisn,
      'placeOfBirth': placeOfBirth,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'religion': religion,
      'acceptanceDate': acceptanceDate,
      'classId': classId,
    };
  }
}

class EditStudentDto {
  final String? name;
  final String? nisn;
  final String? placeOfBirth;
  final String? dateOfBirth;
  final String? gender;
  final String? religion;
  final String? acceptanceDate;
  final String? classId;
  final XFile? photo;

  EditStudentDto({
    this.name,
    this.nisn,
    this.placeOfBirth,
    this.dateOfBirth,
    this.gender,
    this.religion,
    this.acceptanceDate,
    this.classId,
    this.photo,
  });

  // Map<String, dynamic> toJson() {
  //   return {
  //     'description': description,
  //     'feedback': feedback,
  //     'learningGoals': learningGoals.map((goal) => goal.toString()).toList()
  //   };
  // }
}
