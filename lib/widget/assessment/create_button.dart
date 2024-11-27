import 'package:flutter/material.dart';

class CreateButton extends StatelessWidget {
  final String mode;
  final int studentId;

  const CreateButton({super.key, required this.mode, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/create-$mode', arguments: studentId);
      },
      child: const Icon(Icons.add),
    );
  }
}
