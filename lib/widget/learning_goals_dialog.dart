import 'package:asesmen_paud/api/payload/competency_payload.dart';
import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/payload/learning_scope_payload.dart';
import 'package:asesmen_paud/api/payload/sub_learning_scope_payload.dart';
import 'package:asesmen_paud/api/service/learning_service.dart';
import 'package:flutter/material.dart';

class LearningGoalsDialog extends StatefulWidget {
  final Function(int) onAddLearningGoal;

  const LearningGoalsDialog({
    super.key,
    required this.onAddLearningGoal,
  });

  @override
  LearningGoalDialogState createState() => LearningGoalDialogState();
}

class LearningGoalDialogState extends State<LearningGoalsDialog> {
  int? selectedCompetencyId;
  int? selectedLearningScopeId;
  int? selectedSubLearningScopeId;
  int? selectedLearningGoalId;

  List<CompetencyPayload> competencies = [];
  List<LearningScopePayload> learningScopes = [];
  List<SubLearningScopePayload> subLearningScopes = [];
  List<LearningGoalPayload> learningGoals = [];

  @override
  void initState() {
    super.initState();
    _fetchCompetencies();
  }

  Future<void> _fetchCompetencies() async {
    try {
      final response = await LearningService.getAllCompetencies();
      setState(() {
        competencies = response.payload!;
      });
    } catch (e) {
      print('Error fetching competencies: $e');
    }
  }

  Future<void> _fetchLearningScopes(int competencyId) async {
    try {
      final response = await LearningService.getAllLearningScopes(competencyId);
      setState(() {
        learningScopes = response.payload!;
        selectedLearningScopeId = null; // Reset pilihan
        selectedSubLearningScopeId = null;
        selectedLearningGoalId = null;
      });
    } catch (e) {
      print('Error fetching learning scopes: $e');
    }
  }

  Future<void> _fetchSubLearningScopes(int learningScopeId) async {
    try {
      final response =
          await LearningService.getAllSubLearningScopes(learningScopeId);
      setState(() {
        subLearningScopes = response.payload!;
        selectedSubLearningScopeId = null; // Reset pilihan
        selectedLearningGoalId = null;
      });
    } catch (e) {
      print('Error fetching sub-learning scopes: $e');
    }
  }

  Future<void> _fetchLearningGoals(int subLearningScopeId) async {
    try {
      final response =
          await LearningService.getAllLearningGoals(subLearningScopeId);
      setState(() {
        learningGoals = response.payload!;
        selectedLearningGoalId = null; // Reset pilihan
      });
    } catch (e) {
      print('Error fetching learning goals: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Learning Goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            hint: const Text('Pilih Kompetensi'),
            value: selectedCompetencyId,
            onChanged: (value) {
              setState(() {
                selectedCompetencyId = value;
              });
              _fetchLearningScopes(value!);
            },
            items: competencies
                .map((c) => DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(c.competencyName),
                    ))
                .toList(),
          ),
          if (selectedCompetencyId != null)
            DropdownButton<int>(
              hint: const Text('Pilih Lingkup Pembelajaran'),
              value: selectedLearningScopeId,
              onChanged: (value) {
                setState(() {
                  selectedLearningScopeId = value;
                });
                _fetchSubLearningScopes(value!);
              },
              items: learningScopes
                  .map((ls) => DropdownMenuItem<int>(
                        value: ls.id,
                        child: Text(ls.learningScopeName),
                      ))
                  .toList(),
            ),
          if (selectedLearningScopeId != null)
            DropdownButton<int>(
              hint: const Text('Pilih Sub Lingkup Pembelajaran'),
              value: selectedSubLearningScopeId,
              onChanged: (value) {
                setState(() {
                  selectedSubLearningScopeId = value;
                });
                _fetchLearningGoals(value!);
              },
              items: subLearningScopes
                  .map((sls) => DropdownMenuItem<int>(
                        value: sls.id,
                        child: Text(sls.subLearningScopeName),
                      ))
                  .toList(),
            ),
          if (selectedSubLearningScopeId != null)
            DropdownButton<int>(
              hint: const Text('Pilih Capaian Pembelajaran'),
              value: selectedLearningGoalId,
              onChanged: (value) {
                setState(() {
                  selectedLearningGoalId = value;
                });
              },
              items: learningGoals
                  .map((lg) => DropdownMenuItem<int>(
                        value: lg.id,
                        child: Text(lg.learningGoalName ?? 'Goal'),
                      ))
                  .toList(),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (selectedLearningGoalId != null) {
              widget.onAddLearningGoal(selectedLearningGoalId!);
            }
          },
          child: const Text('Pilih'),
        ),
      ],
    );
  }
}
