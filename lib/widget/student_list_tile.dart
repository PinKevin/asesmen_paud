import 'package:asesmen_paud/api/payload/student_payload.dart';
import 'package:flutter/material.dart';

class StudentListTile extends StatelessWidget {
  final Student student;
  final Function(Student) onStudentTap;

  const StudentListTile(
      {super.key, required this.student, required this.onStudentTap});

  @override
  Widget build(BuildContext context) {
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
              subtitle: Text(
                student.nisn,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_right_outlined),
            ),
          ),
        ));
  }
}
