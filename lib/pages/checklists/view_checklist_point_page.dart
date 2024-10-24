import 'package:asesmen_paud/api/payload/checklist_payload.dart';
import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/service/learning_service.dart';
import 'package:flutter/material.dart';

class ViewChecklistPointPage extends StatefulWidget {
  final ChecklistPoint checklistPoint;

  const ViewChecklistPointPage({super.key, required this.checklistPoint});

  @override
  State<ViewChecklistPointPage> createState() => _ViewChecklistPointPageState();
}

class _ViewChecklistPointPageState extends State<ViewChecklistPointPage> {
  LearningGoal? _learningGoal;

  @override
  void initState() {
    super.initState();
    _getLearningGoal();
  }

  void _getLearningGoal() async {
    try {
      final checklistPoint = widget.checklistPoint;
      final response = await LearningService.getLearningGoalById(
          checklistPoint.learningGoalId);
      setState(() {
        _learningGoal = response.payload;
      });
    } catch (e) {
      setState(() {
        _learningGoal = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching learning goal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final checklistPoint = widget.checklistPoint;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail poin ceklis'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Konteks',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  checklistPoint.context,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Kejadian yang Teramati',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  checklistPoint.observedEvent,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Apakah sudah muncul',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  checklistPoint.hasAppeared == 1 ? 'Sudah' : 'Belum',
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Capaian Pembelajaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_learningGoal == null)
                  const SizedBox(
                    height: 5,
                  ),
                if (_learningGoal == null)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  Text(
                    '${_learningGoal?.learningGoalCode} - ${_learningGoal?.learningGoalName}',
                    textAlign: TextAlign.justify,
                  ),
              ],
            ),
          ),
        ));
  }
}
