import 'package:flutter/material.dart';

class ShowField extends StatelessWidget {
  final String title;
  final String content;

  const ShowField({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            content,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
