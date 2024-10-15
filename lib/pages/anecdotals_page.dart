import 'package:flutter/material.dart';

class AnecdotalsPage extends StatelessWidget {
  const AnecdotalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anekdot'),
      ),
      body: const Text('Welcome to anekdot'),
    );
  }
}
