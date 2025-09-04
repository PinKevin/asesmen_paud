import 'package:flutter/material.dart';

class LearningGoalList extends StatelessWidget {
  final List<dynamic> learningGoals;
  final String? learningGoalsError;
  final VoidCallback? onAddLearningGoal;
  final Function(dynamic)? onDeleteLearningGoal;
  final bool editing;

  const LearningGoalList(
      {super.key,
      required this.learningGoals,
      this.learningGoalsError,
      this.onAddLearningGoal,
      this.onDeleteLearningGoal,
      this.editing = true})
      : assert(
          editing == false ||
              (onAddLearningGoal != null && onDeleteLearningGoal != null),
          'onAddLearningGoal and onDeleteLearningGoal are required when editing is true',
        );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (learningGoals.isNotEmpty)
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: learningGoals.length,
              itemBuilder: (context, index) {
                final learningGoal = learningGoals[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      backgroundColor: Colors.deepPurple[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: Card(
                      margin: EdgeInsets.zero,
                      color: Colors.transparent,
                      elevation: 0,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 13),
                        title: Text(
                          learningGoal.learningGoalName,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        subtitle: Text(
                          learningGoal.learningGoalCode,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: editing
                            ? IconButton(
                                onPressed: () =>
                                    onDeleteLearningGoal?.call(learningGoal),
                                icon: const Icon(Icons.delete),
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              }),
        if (editing) ...[
          const SizedBox(
            height: 5,
          ),
          if (learningGoalsError != null) ...[
            Text(
              learningGoalsError ?? 'Terjadi error pada capaian pembelajaran',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(
              height: 5,
            ),
          ],
          ElevatedButton(
              onPressed: onAddLearningGoal,
              child: const Text('Tambah Capaian Pembelajaran'))
        ]
      ],
    );
  }
}
