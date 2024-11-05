import 'package:asesmen_paud/api/payload/paginate_meta_payload.dart';

class StudentReportsPaginated {
  final PaginationMeta meta;
  final List<StudentReport> data;

  StudentReportsPaginated({required this.meta, required this.data});

  factory StudentReportsPaginated.fromJson(Map<String, dynamic> json) {
    return StudentReportsPaginated(
        meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
        data: (json['data'] as List)
            .map((student) =>
                StudentReport.fromJson(student as Map<String, dynamic>))
            .toList());
  }
}

class StudentReport {
  final int id;
  final String startReportDate;
  final String endReportDate;
  final String printFileLink;
  final int studentId;
  final String? createdAt;
  final String? updatedAt;

  StudentReport(
      {required this.id,
      required this.startReportDate,
      required this.endReportDate,
      required this.printFileLink,
      required this.studentId,
      this.createdAt,
      this.updatedAt});

  factory StudentReport.fromJson(Map<String, dynamic> json) {
    return StudentReport(
      id: int.tryParse(json['id'].toString()) ?? 0,
      startReportDate: json['startReportDate'] as String,
      endReportDate: json['endReportDate'] as String,
      printFileLink: json['printFileLink'] as String,
      studentId: int.tryParse(json['studentId'].toString()) ?? 0,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
