import 'package:asesmen_paud/widget/anecdotal/anecdotal_field.dart';
import 'package:asesmen_paud/pages/learning_goals_page.dart';
import 'package:flutter/material.dart';

class CreateAnecdotalPage extends StatefulWidget {
  const CreateAnecdotalPage({super.key});

  @override
  State<CreateAnecdotalPage> createState() => CreateAnecdotalPageState();
}

class CreateAnecdotalPageState extends State<CreateAnecdotalPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  List<dynamic> learningGoals = [];

  String? _descriptionError;
  String? _feedbackError;

  Future<void> _goToLearningGoalSelection() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const LearningGoalsPage()));
    setState(() {
      learningGoals.add(result);
    });
    // learningGoals.add(result);
  }

  @override
  Widget build(BuildContext context) {
    final int studentId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Buat penilaian anekdot'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AnecdotalField(
                  controller: _descriptionController,
                  labelText: 'Deskripsi',
                  errorText: _descriptionError),
              const SizedBox(
                height: 20,
              ),
              AnecdotalField(
                  controller: _feedbackController,
                  labelText: 'Umpan Balik',
                  errorText: _feedbackError),
              const SizedBox(
                height: 20,
              ),
              // LearningGoalsSection(
              //     learningGoals: learningGoals,
              //     onAddLearningGoal: (selectedGoal) {
              //       learningGoals.add(selectedGoal);
              //     }),
              ElevatedButton(
                  onPressed: _goToLearningGoalSelection,
                  child: const Text('Tes')),
              Text('$studentId'),
              Text('$learningGoals')
            ],
          ),
        ));
  }
}
