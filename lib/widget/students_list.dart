import 'package:asesmen_paud/api/payload/student_payload.dart';
import 'package:flutter/material.dart';

class StudentsList extends StatelessWidget {
  final List<StudentPayload> students;
  final Function(StudentPayload) onStudentTap;

  const StudentsList(
      {super.key, required this.students, required this.onStudentTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            backgroundColor: Colors.deepPurple[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                        onPressed: () => onStudentTap(student),
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Colors.transparent,
                          elevation: 0,
                          child: ListTile(
                            title: Text(student.name),
                            subtitle: Text('NISN: ${student.nisn}'),
                            trailing: const Icon(Icons.arrow_right_outlined),
                          ),
                        ),
                      ));
                }))
      ],
    );
  }
}
