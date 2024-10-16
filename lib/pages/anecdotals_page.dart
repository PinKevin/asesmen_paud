import 'package:asesmen_paud/widget/search_field.dart';
import 'package:flutter/material.dart';

class AnecdotalsPage extends StatefulWidget {
  const AnecdotalsPage({super.key});

  @override
  AnecdotalsPageState createState() => AnecdotalsPageState();
}

class AnecdotalsPageState extends State<AnecdotalsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final int studentId = ModalRoute.of(context)!.settings.arguments as int;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anekdot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchField(controller: _searchController),
            Text('Student ID: $studentId')
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
