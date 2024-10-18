import 'package:asesmen_paud/api/payload/competency_payload.dart';
import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/payload/learning_scope_payload.dart';
import 'package:asesmen_paud/api/payload/sub_learning_scope_payload.dart';
import 'package:asesmen_paud/api/service/learning_service.dart';
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
              if (_competencyError != null) Text(_competencyError!),
              DropdownButtonFormField(
                  isExpanded: true,
                  isDense: false,
                  decoration: const InputDecoration(
                    labelText: 'Pilih kompetensi',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCompetency,
                  items: _competencies.map((competency) {
                    return DropdownMenuItem(
                      value: competency,
                      child: Text(
                        competency.competencyName,
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCompetency = value;
                      _selectedLearningScope = null;
                      _selectedSubLearningScope = null;
                      selectedLearningGoal = null;
                      if (value != null) _fetchLearningScopes(value.id);
                    });
                  }),
              const SizedBox(
                height: 20,
              ),
              if (_learningScopeError != null) Text(_learningScopeError!),
              DropdownButtonFormField(
                  isExpanded: true,
                  isDense: false,
                  decoration: const InputDecoration(
                    labelText: 'Pilih lingkup pembelajaran',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedLearningScope,
                  items: _learningScopes.map((learningScope) {
                    return DropdownMenuItem(
                      value: learningScope,
                      child: Text(
                        learningScope.learningScopeName,
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLearningScope = value;
                      _selectedSubLearningScope = null;
                      selectedLearningGoal = null;
                      if (value != null) _fetchSubLearningScopes(value.id);
                    });
                  }),
              const SizedBox(
                height: 20,
              ),
              if (_subLearningScopeError != null) Text(_subLearningScopeError!),
              DropdownButtonFormField(
                  isExpanded: true,
                  isDense: false,
                  decoration: const InputDecoration(
                    labelText: 'Pilih sub lingkup pembelajaran',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSubLearningScope,
                  items: _subLearningScopes.map((subLearningScope) {
                    return DropdownMenuItem(
                      value: subLearningScope,
                      child: Text(
                        subLearningScope.subLearningScopeName,
                        softWrap: true,
                        maxLines: 3,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubLearningScope = value;
                      selectedLearningGoal = null;

                      if (value != null) _fetchLearningGoals(value.id);
                    });
                  }),
              const SizedBox(
                height: 20,
              ),
              DropdownButtonFormField(
                  isExpanded: true,
                  isDense: false,
                  decoration: const InputDecoration(
                    labelText: 'Pilih capaian pembelajaran',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedLearningGoal,
                  items: _learningGoals.map((learningGoal) {
                    return DropdownMenuItem(
                        value: learningGoal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              learningGoal.learningGoalCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              learningGoal.learningGoalName,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                            )
                          ],
                        ));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLearningGoal = value;
                    });
                  }),
              const SizedBox(
                height: 20,
              ),
              if (_learningGoalError != null) Text(_learningGoalError!),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, selectedLearningGoal);
                  },
                  child: const Text('Pilih'))
            ],
          ),
        ));
  }
}
