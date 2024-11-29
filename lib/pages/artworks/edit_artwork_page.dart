import 'package:asesmen_paud/api/dto/artwork_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/artwork_payload.dart';
import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/artwork_service.dart';
import 'package:asesmen_paud/pages/learning_goals_page.dart';
import 'package:asesmen_paud/widget/assessment/expanded_text_field.dart';
import 'package:asesmen_paud/widget/assessment/learning_goal_list.dart';
import 'package:asesmen_paud/widget/assessment/photo_manager.dart';
import 'package:asesmen_paud/widget/color_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditArtworkPage extends StatefulWidget {
  final Artwork artwork;

  const EditArtworkPage({super.key, required this.artwork});

  @override
  State<EditArtworkPage> createState() => _EditArtworkPageState();
}

class _EditArtworkPageState extends State<EditArtworkPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  late List<dynamic> _editableLearningGoals = [];
  XFile? _image;
  bool onChangedImage = false;

  bool _isLoading = false;
  String? _descriptionError;
  String? _feedbackError;
  String? _learningGoalsError;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.artwork.description;
    _feedbackController.text = widget.artwork.feedback;

    _editableLearningGoals = List.from(widget.artwork.learningGoals ?? []);
  }

  Future<void> _goToLearningGoalSelection() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const LearningGoalsPage()));
    if (result != null) {
      setState(() {
        _editableLearningGoals.add(result);
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
                    setState(() {
                      _editableLearningGoals.remove(learningGoal);
                    });
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

  Future<void> _submit(int studentId, int artworkId) async {
    setState(() {
      _isLoading = true;
      _descriptionError = null;
      _feedbackError = null;
      _learningGoalsError = null;
    });

    final dto = EditArtworkDto(
      description: _descriptionController.text,
      feedback: _feedbackController.text,
      learningGoals:
          _editableLearningGoals.map((goal) => goal.id as int).toList(),
      photo: _image,
    );

    try {
      final SuccessResponse<Artwork> response =
          await ArtworkService().editArtwork(studentId, artworkId, dto);
      if (response.status == 'success') {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(ColorSnackbar.build(
          message: response.message,
          success: true,
        ));
        Navigator.pop(context, true);
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
          ColorSnackbar.build(message: e.toString(), success: true));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final artwork = widget.artwork;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah penilaian hasil karya'),
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
                errorText: _descriptionError,
              ),
              const SizedBox(
                height: 20,
              ),

              // Feedback
              ExpandedTextField(
                controller: _feedbackController,
                labelText: 'Umpan Balik',
                errorText: _feedbackError,
              ),
              const SizedBox(
                height: 20,
              ),

              // Learning Goals
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
                learningGoals: _editableLearningGoals,
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
                  mode: PhotoMode.edit,
                  initialImageUrl: artwork.photoLink,
                  onImageSelected: (image) {
                    setState(() {
                      _image = image;
                    });
                  }),
              const SizedBox(height: 10),

              // Submit
              ElevatedButton(
                onPressed: () {
                  _submit(artwork.studentId, artwork.id);
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
                        'Ubah Hasil Karya',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
