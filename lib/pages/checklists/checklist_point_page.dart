import 'package:asesmen_paud/api/payload/competency_payload.dart';
import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/payload/learning_scope_payload.dart';
import 'package:asesmen_paud/api/payload/sub_learning_scope_payload.dart';
import 'package:asesmen_paud/api/service/learning_service.dart';
import 'package:asesmen_paud/widget/checklist/checklist_field.dart';
import 'package:flutter/material.dart';

class ChecklistPointPage extends StatefulWidget {
  const ChecklistPointPage({
    super.key,
  });

  @override
  ChecklistPointPageState createState() => ChecklistPointPageState();
}

class ChecklistPointPageState extends State<ChecklistPointPage> {
  final TextEditingController _contextController = TextEditingController();
  final TextEditingController _observedEventController =
      TextEditingController();
  bool? _hasAppearedSelectedOption;

  String? _contextError;
  String? _observedEventError;
  String? _hasAppearedError;

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

  void _validateFieldAndBack() {
    setState(() {
      if (_contextController.text.isEmpty) {
        _contextError = 'Konteks harus diisi';
      } else {
        _contextError = null;
      }

      if (_observedEventController.text.isEmpty) {
        _observedEventError = 'Konteks harus diisi';
      } else {
        _observedEventError = null;
      }

      if (_hasAppearedSelectedOption == null) {
        _hasAppearedError = 'Kemunculan perilaku anak harus diisi';
      } else {
        _hasAppearedError = null;
      }

      if (_selectedCompetency == null) {
        _competencyError = 'Kompetensi pembelajaran harus diisi';
      } else {
        _competencyError = null;
      }

      if (_selectedLearningScope == null) {
        _learningScopeError = 'Lingkup pembelajaran harus diisi';
      } else {
        _learningScopeError = null;
      }

      if (_selectedSubLearningScope == null) {
        _subLearningScopeError = 'Sub lingkup pembelajaran harus diisi';
      } else {
        _subLearningScopeError = null;
      }

      if (selectedLearningGoal == null) {
        _learningGoalError = 'Capaian pembelajaran harus diisi';
      } else {
        _learningGoalError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pilih capaian pembelajaran'),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField(
                  isExpanded: true,
                  isDense: false,
                  decoration: InputDecoration(
                      labelText: 'Pilih kompetensi',
                      border: const OutlineInputBorder(),
                      errorText: _competencyError,
                      errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red))),
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
                      _competencyError = null;
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
              DropdownButtonFormField(
                  isExpanded: true,
                  isDense: false,
                  decoration: InputDecoration(
                      labelText: 'Pilih lingkup pembelajaran',
                      border: const OutlineInputBorder(),
                      errorText: _learningScopeError,
                      errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red))),
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
                      _learningScopeError = null;
                      _selectedLearningScope = value;
                      _selectedSubLearningScope = null;
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
                  decoration: InputDecoration(
                      labelText: 'Pilih sub lingkup pembelajaran',
                      border: const OutlineInputBorder(),
                      errorText: _subLearningScopeError,
                      errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red))),
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
                      _subLearningScopeError = null;
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
                  decoration: InputDecoration(
                      labelText: 'Pilih capaian pembelajaran',
                      border: const OutlineInputBorder(),
                      errorText: _learningGoalError,
                      errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red))),
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
                      _learningGoalError = null;
                      selectedLearningGoal = value;
                    });
                  }),
              const SizedBox(
                height: 20,
              ),
              ChecklistField(
                  controller: _contextController,
                  labelText: 'Konteks',
                  errorText: _contextError,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _contextError = null;
                      });
                    }
                  }),
              const SizedBox(
                height: 20,
              ),
              ChecklistField(
                  controller: _observedEventController,
                  labelText: 'Kejadian yang Teramati',
                  errorText: _observedEventError,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _observedEventError = null;
                      });
                    }
                  }),
              const SizedBox(
                height: 20,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Apakah sudah muncul?',
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RadioListTile(
                      title: const Text('Sudah muncul'),
                      value: true,
                      groupValue: _hasAppearedSelectedOption,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (bool? value) {
                        setState(() {
                          _hasAppearedError = null;
                          _hasAppearedSelectedOption = value;
                        });
                      }),
                  RadioListTile(
                      title: const Text('Belum muncul'),
                      value: false,
                      groupValue: _hasAppearedSelectedOption,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (bool? value) {
                        setState(() {
                          _hasAppearedError = null;
                          _hasAppearedSelectedOption = value;
                        });
                      }),
                ],
              ),
              if (_hasAppearedError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _hasAppearedError!,
                    style: const TextStyle(fontSize: 13, color: Colors.red),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    _validateFieldAndBack();
                    // Navigator.pop(context, selectedLearningGoal);
                  },
                  child: const Text('Pilih'))
            ],
          ),
        )));
  }
}
