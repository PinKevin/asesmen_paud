import 'package:asesmen_paud/api/payload/student_payload.dart';
import 'package:asesmen_paud/widget/student/student_list_tile.dart';
import 'package:flutter/material.dart';

class StudentListView extends StatelessWidget {
  final List<Student> students;
  final String errorMessage;
  final bool isLoading;
  final bool hasMoreData;
  final String mode;
  final Future<void> Function() onRefresh;
  final ScrollController scrollController;

  const StudentListView(
      {super.key,
      required this.students,
      required this.errorMessage,
      required this.isLoading,
      required this.hasMoreData,
      required this.mode,
      required this.onRefresh,
      required this.scrollController});

  void _navigateToIndexPage(BuildContext context, String mode, int studentId) {
    final routes = {
      'anecdotal': '/anecdotals',
      'artwork': '/artworks',
      'checklist': '/checklists',
      'series-photo': '/series-photos',
      'report': '/reports',
    };

    final routeName = routes[mode];
    if (routeName != null) {
      Navigator.pushNamed(context, routeName, arguments: studentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (students.isEmpty && isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
            controller: scrollController,
            itemCount: students.length + 1,
            itemBuilder: (context, index) {
              if (index < students.length) {
                final student = students[index];
                return StudentListTile(
                    student: student,
                    onStudentTap: () {
                      _navigateToIndexPage(context, mode, student.id);
                    });
              } else if (hasMoreData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(students.isEmpty
                        ? 'Belum ada murid. Silakan hubungi admin!'
                        : 'Anda sudah mencapai akhir halaman.'),
                  ),
                );
              }
            }));
  }
}
