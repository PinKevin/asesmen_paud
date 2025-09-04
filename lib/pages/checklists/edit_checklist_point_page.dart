import 'package:asesmen_paud/api/dto/checklist_dto.dart';
import 'package:asesmen_paud/api/payload/checklist_payload.dart';
import 'package:asesmen_paud/api/payload/competency_payload.dart';
import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/payload/learning_scope_payload.dart';
import 'package:asesmen_paud/api/payload/sub_learning_scope_payload.dart';
import 'package:asesmen_paud/api/service/learning_service.dart';
import 'package:asesmen_paud/widget/assessment/expanded_dropdown.dart';
import 'package:asesmen_paud/widget/assessment/expanded_text_field.dart';
import 'package:flutter/material.dart';

class EditChecklistPointPage extends StatefulWidget {
  final ChecklistPoint? checklistPoint;
  final ChecklistPointDto? checklistPointDto;

  const EditChecklistPointPage({
    super.key,
    this.checklistPoint,
    this.checklistPointDto,
  }) : assert(checklistPoint != null || checklistPointDto != null,
            'Salah satu harus diisi');

  @override
  EditChecklistPointPageState createState() => EditChecklistPointPageState();
}

class EditChecklistPointPageState extends State<EditChecklistPointPage> {
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

    ChecklistPoint? checklistPoint;
    ChecklistPointDto? checklistPointDto;

    if (widget.checklistPoint != null) {
      checklistPoint = widget.checklistPoint;

      _contextController.text = checklistPoint!.context;
      _observedEventController.text = checklistPoint.observedEvent;
      _hasAppearedSelectedOption =
          checklistPoint.hasAppeared == 1 ? true : false;
    } else {
      checklistPointDto = widget.checklistPointDto;

      _contextController.text = checklistPointDto!.context;
      _observedEventController.text = checklistPointDto.observedEvent;
      _hasAppearedSelectedOption = checklistPointDto.hasAppeared;
    }

    _fetchCompetencies();
    _initializeDropdowns();
  }

  Future<void> _initializeDropdowns() async {
    try {
      final learningGoalId = widget.checklistPoint?.learningGoalId ??
          widget.checklistPointDto?.learningGoalId;

      if (learningGoalId != null) {
        final learningGoalResponse =
            await LearningService.getLearningGoalById(learningGoalId);
        selectedLearningGoal = learningGoalResponse.payload;

        final subLearningScopeResponse =
            await LearningService.getSubLearningScopeById(
                selectedLearningGoal!.subLearningScopeId);
        _selectedSubLearningScope = subLearningScopeResponse.payload;

        final learningScopeResponse =
            await LearningService.getLearningScopeById(
                _selectedSubLearningScope!.learningScopeId);
        _selectedLearningScope = learningScopeResponse.payload;

        final competencyResponse = await LearningService.getCompetencyById(
            _selectedLearningScope!.competencyId);
        _selectedCompetency = competencyResponse.payload;
      }
    } catch (e) {
      _learningGoalError = '$e';
    }
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
    bool isValid = true;
    setState(() {
      _contextError =
          _contextController.text.isEmpty ? 'Konteks harus diisi' : null;
      _observedEventError = _observedEventController.text.isEmpty
          ? 'Kejadian yang teramati harus diisi'
          : null;
      _hasAppearedError = _hasAppearedSelectedOption == null
          ? 'Kemunculan perilaku anak harus diisi'
          : null;
      _competencyError = _selectedCompetency == null
          ? 'Kompetensi pembelajaran harus diisi'
          : null;
      _learningScopeError = _selectedLearningScope == null
          ? 'Lingkup pembelajaran harus diisi'
          : null;
      _subLearningScopeError = _selectedSubLearningScope == null
          ? 'Sub lingkup pembelajaran harus diisi'
          : null;
      _learningGoalError = selectedLearningGoal == null
          ? 'Capaian pembelajaran harus diisi'
          : null;

      isValid = [
        _contextError,
        _observedEventError,
        _hasAppearedError,
        _competencyError,
        _learningScopeError,
        _subLearningScopeError,
        _learningGoalError
      ].every((error) => error == null);
    });

    if (isValid) {
      ChecklistPointDto dto = ChecklistPointDto(
          learningGoalId: selectedLearningGoal!.id,
          context: _contextController.text,
          observedEvent: _observedEventController.text,
          hasAppeared: _hasAppearedSelectedOption!);
      Navigator.pop(context, dto);
    } else {
      return;
    }
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
              ExpandedTextField(
                controller: _contextController,
                labelText: 'Konteks',
                errorText: _contextError,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _contextError = null;
                    });
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ExpandedTextField(
                controller: _observedEventController,
                labelText: 'Kejadian yang Teramati',
                errorText: _observedEventError,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _observedEventError = null;
                    });
                  }
                },
              ),
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
                    },
                  ),
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
                    },
                  ),
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
                },
                child: const Text('Pilih'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
