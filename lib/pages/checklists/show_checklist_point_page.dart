import 'package:asesmen_paud/api/dto/checklist_dto.dart';
import 'package:asesmen_paud/api/payload/checklist_payload.dart';
import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/service/learning_service.dart';
import 'package:flutter/material.dart';

class ShowChecklistPointPage extends StatefulWidget {
  final ChecklistPoint? checklistPoint;
  final ChecklistPointDto? checklistPointDto;

  const ShowChecklistPointPage(
      {super.key, this.checklistPoint, this.checklistPointDto})
      : assert(checklistPoint != null || checklistPointDto != null,
            'Salah satu harus diisi');

  @override
  State<ShowChecklistPointPage> createState() => _ShowChecklistPointPageState();
}

class _ShowChecklistPointPageState extends State<ShowChecklistPointPage> {
  LearningGoal? _learningGoal;

  @override
  void initState() {
    super.initState();
    _getLearningGoal();
  }

  void _getLearningGoal() async {
    try {
      final learningGoalId = widget.checklistPoint?.learningGoalId ??
          widget.checklistPointDto?.learningGoalId;
      if (learningGoalId != null) {
        final response =
            await LearningService.getLearningGoalById(learningGoalId);
        if (mounted) {
          setState(() {
            _learningGoal = response.payload;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _learningGoal = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil learning goal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final checklistPoint = widget.checklistPoint;
    final checklistPointDto = widget.checklistPointDto;

    final contextText =
        checklistPoint?.context ?? checklistPointDto?.context ?? '';
    final observedEventText =
        checklistPoint?.observedEvent ?? checklistPointDto?.observedEvent ?? '';
    final hasAppeared =
        checklistPoint?.hasAppeared ?? checklistPointDto?.hasAppeared ?? '';

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
                  contextText,
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
                  observedEventText,
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
                  hasAppeared == 1 ? 'Sudah' : 'Belum',
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
                    '${_learningGoal?.learningGoalCode}-${_learningGoal?.learningGoalName}',
                    textAlign: TextAlign.justify,
                  ),
              ],
            ),
          ),
        ));
  }
}
