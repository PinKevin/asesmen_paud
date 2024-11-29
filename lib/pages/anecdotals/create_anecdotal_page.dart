import 'package:asesmen_paud/api/dto/anecdotal_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/anecdotal_payload.dart';
import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/anecdotal_service.dart';
import 'package:asesmen_paud/pages/learning_goals_page.dart';
import 'package:asesmen_paud/widget/assessment/expanded_text_field.dart';
import 'package:asesmen_paud/widget/assessment/learning_goal_list.dart';
import 'package:asesmen_paud/widget/assessment/photo_manager.dart';
import 'package:asesmen_paud/widget/color_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateAnecdotalPage extends StatefulWidget {
  const CreateAnecdotalPage({super.key});

  @override
  State<CreateAnecdotalPage> createState() => CreateAnecdotalPageState();
}

class CreateAnecdotalPageState extends State<CreateAnecdotalPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  List<dynamic> learningGoals = [];
  XFile? _image;

  bool _isLoading = false;
  String? _descriptionError;
  String? _feedbackError;
  String? _learningGoalsError;

  Future<void> _goToLearningGoalSelection() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const LearningGoalsPage()));
    if (result != null) {
      setState(() {
        learningGoals.add(result);
      });
    }
  }

  Future<void> _showDeleteLearningGoalDialog(LearningGoal learningGoal) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Peringatan'),
            content: const Text('Yakin ingin hapus capaian pembelajaran?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Kembali')),
              TextButton(
                  onPressed: () {
                    learningGoals.remove(learningGoal);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        });
  }

  Future<void> _submit(int studentId) async {
    setState(() {
      _isLoading = true;
      _descriptionError = null;
      _feedbackError = null;
      _learningGoalsError = null;
    });

    final dto = CreateAnecdotalDto(
        description: _descriptionController.text,
        feedback: _feedbackController.text,
        learningGoals: learningGoals.map((goal) => goal.id as int).toList(),
        photo: _image);

    try {
      final SuccessResponse<Anecdotal> response =
          await AnecdotalService().createAnecdotal(studentId, dto);

      if (response.status == 'success') {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
            ColorSnackbar.build(message: response.message, success: true));
        Navigator.pop(context);
      }
    } on ValidationException catch (e) {
      setState(() {
        _descriptionError = e.errors['description']?.message ?? '';
        _feedbackError = e.errors['feedback']?.message ?? '';
        _learningGoalsError = e.errors['learningGoals']?.message ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          ColorSnackbar.build(message: e.toString(), success: false));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int studentId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Buat penilaian anekdot'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Description
                ExpandedTextField(
                    controller: _descriptionController,
                    labelText: 'Deskripsi',
                    errorText: _descriptionError),
                const SizedBox(
                  height: 20,
                ),

                // Feedback
                ExpandedTextField(
                    controller: _feedbackController,
                    labelText: 'Umpan Balik',
                    errorText: _feedbackError),
                const SizedBox(
                  height: 20,
                ),

                //Learning Goals
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Capaian Pembelajaran',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                LearningGoalList(
                  learningGoals: learningGoals,
                  learningGoalsError: _learningGoalsError,
                  editing: true,
                  onAddLearningGoal: _goToLearningGoalSelection,
                  onDeleteLearningGoal: (goal) =>
                      _showDeleteLearningGoalDialog(goal),
                ),
                const SizedBox(
                  height: 20,
                ),

                // Photo
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Foto',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                PhotoManager(
                    mode: PhotoMode.create,
                    onImageSelected: (image) {
                      setState(() {
                        _image = image;
                      });
                    }),
                const SizedBox(height: 10),

                // Submit
                ElevatedButton(
                  onPressed: () {
                    _submit(studentId);
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(200, 40),
                      backgroundColor: Colors.deepPurple),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const Text(
                          'Tambah Anekdot',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ));
  }
}
