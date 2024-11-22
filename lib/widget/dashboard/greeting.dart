import 'package:flutter/material.dart';

class Greeting extends StatelessWidget {
  final String teacherName;

  const Greeting({super.key, required this.teacherName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selamat datang,',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        Text(
          teacherName,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
