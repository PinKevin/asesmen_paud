import 'package:flutter/material.dart';

class Greeting extends StatelessWidget {
  final String? teacherName;

  const Greeting({super.key, this.teacherName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [const Text('Selamat datang,'), Text(teacherName ?? 'Guru')],
    );
  }
}
