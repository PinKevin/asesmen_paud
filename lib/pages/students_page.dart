import 'package:asesmen_paud/api/payload/student_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/student_service.dart';
import 'package:asesmen_paud/widget/search_field.dart';
import 'package:asesmen_paud/widget/students_list.dart';
import 'package:flutter/material.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  StudentsPageState createState() => StudentsPageState();
}

class StudentsPageState extends State<StudentsPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<SuccessResponse<PaginateStudentsPayload>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = StudentService().getAllStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Murid'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SearchField(controller: _searchController),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: FutureBuilder<SuccessResponse<PaginateStudentsPayload>>(
                  future: _studentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      final students = snapshot.data!.payload!.data;
                      return StudentsList(
                        students: students,
                        onStudentTap: (student) {
                          Navigator.pushNamed(context, '/anecdotals',
                              arguments: student.id);
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('No student'),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
