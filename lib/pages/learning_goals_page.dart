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
  CompetencyPayload? selectedCompetency;
  LearningScopePayload? selectedLearningScope;
  SubLearningScopePayload? selectedSubLearningScope;
  LearningGoalPayload? selectedLearningGoal;

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
        selectedLearningScope = null;
        selectedSubLearningScope = null;
        selectedLearningGoal = null;
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
        selectedSubLearningScope = null;
        selectedLearningGoal = null;
      });
    } catch (e) {
      print('Error fetching sub-learning scopes: $e');
    }
  }

  Future<void> _fetchLearningGoals(int subLearningScopeId) async {
    try {
      final response =
          await LearningService.getAllLearningGoals(subLearningScopeId);
      print('Fetched lg: ${response.payload}');
      setState(() {
        learningGoals = response.payload ?? [];
        selectedLearningGoal = null;
      });
    } catch (e) {
      print('Error fetching learning goals: $e');
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
              DropdownButtonFormField(
                  isExpanded: true,
                  isDense: false,
                  decoration: const InputDecoration(
                    labelText: 'Pilih kompetensi',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedCompetency,
                  items: competencies.map((competency) {
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
                      selectedCompetency = value;
                      selectedLearningScope = null;
                      selectedSubLearningScope = null;
                      selectedLearningGoal = null;
                      if (value != null) _fetchLearningScopes(value.id);
                    });
                  }),
              const SizedBox(
                height: 20,
              ),
              DropdownButtonFormField(
                  isExpanded: true,
                  isDense: false,
                  decoration: const InputDecoration(
                    labelText: 'Pilih lingkup pembelajaran',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedLearningScope,
                  items: learningScopes.map((learningScope) {
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
                      selectedLearningScope = value;
                      selectedSubLearningScope = null;
                      selectedLearningGoal = null;
                      if (value != null) _fetchSubLearningScopes(value.id);
                    });
                  }),
              const SizedBox(
                height: 20,
              ),
              DropdownButtonFormField(
                  isExpanded: true,
                  isDense: false,
                  decoration: const InputDecoration(
                    labelText: 'Pilih sub lingkup pembelajaran',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedSubLearningScope,
                  items: subLearningScopes.map((subLearningScope) {
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
                      selectedSubLearningScope = value;
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
                  items: learningGoals.map((learningGoal) {
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
