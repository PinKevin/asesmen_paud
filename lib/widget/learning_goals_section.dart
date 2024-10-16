import 'package:asesmen_paud/widget/learning_goals_dialog.dart';
import 'package:flutter/material.dart';

class LearningGoalsSection extends StatefulWidget {
  final List<int> learningGoals;
  final Function(int) onAddLearningGoal;

  const LearningGoalsSection({
    super.key,
    required this.learningGoals,
    required this.onAddLearningGoal,
  });

  @override
  LearningGoalsSectionState createState() => LearningGoalsSectionState();
}

class LearningGoalsSectionState extends State<LearningGoalsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Memunculkan modal untuk memilih learning goal
            showDialog(
              context: context,
              builder: (context) => LearningGoalsDialog(
                onAddLearningGoal: (goalId) {
                  widget.onAddLearningGoal(goalId);
                  Navigator.of(context).pop(); // Menutup dialog
                },
              ),
            );
          },
          child: const Text('Tambah Capaian Pembelajaran'),
        ),
        ...widget.learningGoals
            .map((goalId) => Text('Learning Goal ID: $goalId')),
      ],
    );
  }
}
