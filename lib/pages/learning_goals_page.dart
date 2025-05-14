import 'package:asesmen_paud/api/payload/competency_payload.dart';
import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/payload/learning_scope_payload.dart';
import 'package:asesmen_paud/api/payload/sub_learning_scope_payload.dart';
import 'package:asesmen_paud/api/service/learning_service.dart';
import 'package:asesmen_paud/widget/assessment/expanded_dropdown.dart';
import 'package:flutter/material.dart';

class LearningGoalsPage extends StatefulWidget {
  const LearningGoalsPage({
    super.key,
  });

  @override
  LearningGoalsPageState createState() => LearningGoalsPageState();
}

class LearningGoalsPageState extends State<LearningGoalsPage> {
  Competency? _selectedCompetency;
  LearningScope? _selectedLearningScope;
  SubLearningScope? _selectedSubLearningScope;
  LearningGoal? selectedLearningGoal;

  List<Competency> _competencies = [];
  List<LearningScope> _learningScopes = [];
  List<SubLearningScope> _subLearningScopes = [];
  List<LearningGoal> _learningGoals = [];

  String? _competencyError;
  String? _learningScopeError;
  String? _subLearningScopeError;
  String? _learningGoalError;

  @override
  void initState() {
    super.initState();
    _fetchCompetencies();
  }

  Future<void> _fetchCompetencies() async {
    try {
      final response = await LearningService.getAllCompetencies();
      setState(() {
        _competencies = response.payload!;
      });
    } catch (e) {
      setState(() {
        _competencyError = 'Gagal mengambil kompetensi: $e';
      });
    }
  }

  Future<void> _fetchLearningScopes(int competencyId) async {
    try {
      final response = await LearningService.getAllLearningScopes(competencyId);
      setState(() {
        _learningScopes = response.payload!;
        _selectedLearningScope = null;
        _selectedSubLearningScope = null;
        selectedLearningGoal = null;
      });
    } catch (e) {
      setState(() {
        _learningScopeError = 'Gagal mengambil lingkup pembelajaran: $e';
      });
    }
  }

  Future<void> _fetchSubLearningScopes(int learningScopeId) async {
    try {
      final response =
          await LearningService.getAllSubLearningScopes(learningScopeId);
      setState(() {
        _subLearningScopes = response.payload!;
        _selectedSubLearningScope = null;
        selectedLearningGoal = null;
      });
    } catch (e) {
      setState(() {
        _subLearningScopeError = 'Gagal mengambil sub lingkup pembelajaran: $e';
      });
    }
  }

  Future<void> _fetchLearningGoals(int subLearningScopeId) async {
    try {
      final response =
          await LearningService.getAllLearningGoals(subLearningScopeId);
      setState(() {
        _learningGoals = response.payload ?? [];
        selectedLearningGoal = null;
      });
    } catch (e) {
      setState(() {
        _learningGoalError = 'Gagal mengambil capaian pembelajaran: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pilih capaian pembelajaran'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ExpandedDropdown<Competency>(
                label: 'Pilih kompetensi',
                items: _competencies,
                selectedItem: _selectedCompetency,
                itemLabel: (item) => item?.competencyName,
                errorText: _competencyError,
                onChanged: (value) {
                  setState(() {
                    _competencyError = null;
                    _selectedCompetency = value;
                    _selectedLearningScope = null;
                    _selectedSubLearningScope = null;
                    selectedLearningGoal = null;
                    if (value != null) _fetchLearningScopes(value.id);
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ExpandedDropdown<LearningScope>(
                label: 'Pilih lingkup pembelajaran',
                items: _learningScopes,
                selectedItem: _selectedLearningScope,
                itemLabel: (item) => item?.learningScopeName,
                errorText: _learningScopeError,
                onChanged: (value) {
                  setState(() {
                    _learningScopeError = null;
                    _selectedLearningScope = value;
                    _selectedSubLearningScope = null;
                    selectedLearningGoal = null;
                    if (value != null) _fetchSubLearningScopes(value.id);
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ExpandedDropdown<SubLearningScope>(
                label: 'Pilih sub lingkup pembelajaran',
                items: _subLearningScopes,
                selectedItem: _selectedSubLearningScope,
                itemLabel: (item) => item?.subLearningScopeName,
                errorText: _subLearningScopeError,
                onChanged: (value) {
                  setState(() {
                    _subLearningScopeError = null;
                    _selectedSubLearningScope = value;
                    selectedLearningGoal = null;
                    if (value != null) _fetchLearningGoals(value.id);
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ExpandedDropdown<LearningGoal>(
                label: 'Pilih capaian pembelajaran',
                items: _learningGoals,
                selectedItem: selectedLearningGoal,
                itemLabel: (item) => item?.learningGoalName,
                itemSubLabel: (item) => item?.learningGoalCode,
                errorText: _learningGoalError,
                onChanged: (value) {
                  setState(() {
                    _learningGoalError = null;
                    selectedLearningGoal = value;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedLearningGoal);
                },
                child: const Text('Pilih'),
              )
            ],
          ),
        ));
  }
}
