import 'package:asesmen_paud/api/dto/series_photo_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/payload/series_photo_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/series_photo_service.dart';
import 'package:asesmen_paud/pages/learning_goals_page.dart';
import 'package:asesmen_paud/widget/assessment/expanded_text_field.dart';
import 'package:asesmen_paud/widget/assessment/learning_goal_list.dart';
import 'package:asesmen_paud/widget/assessment/multi_photo_manager.dart';
import 'package:asesmen_paud/widget/button/submit_primary.dart';
import 'package:asesmen_paud/widget/color_snackbar.dart';
import 'package:flutter/material.dart';

class EditSeriesPhotoPage extends StatefulWidget {
  final SeriesPhoto seriesPhoto;

  const EditSeriesPhotoPage({super.key, required this.seriesPhoto});

  @override
  State<EditSeriesPhotoPage> createState() => _EditArtworkPageState();
}

class _EditArtworkPageState extends State<EditSeriesPhotoPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  late List<dynamic> _editableLearningGoals = [];
  late List<dynamic> _images = [];
  bool isImagesAdded = false;

  bool _isLoading = false;
  String? _descriptionError;
  String? _feedbackError;
  String? _learningGoalsError;
  String? _imagesError;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.seriesPhoto.description;
    _feedbackController.text = widget.seriesPhoto.feedback;

    _editableLearningGoals = List.from(widget.seriesPhoto.learningGoals ?? []);
    _images = List.from(widget.seriesPhoto.seriesPhotos!
        .map((photo) => photo.photoLink)
        .toList());
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

  bool _validateInputs() {
    bool hasError = false;

    if (_descriptionController.text.isEmpty) {
      setState(() {
        _descriptionError = 'Deskripsi harus diisi';
      });
      hasError = true;
    }

    if (_feedbackController.text.isEmpty) {
      setState(() {
        _feedbackError = 'Umpan balik harus diisi';
      });
      hasError = true;
    }

    if (_editableLearningGoals.isEmpty) {
      setState(() {
        _learningGoalsError = 'Capaian pembelajaran harus dipilih';
      });
      hasError = true;
    }

    if (_images.length < 3 || _images.length > 5) {
      setState(() {
        _imagesError = 'Foto harus berjumlah 3-5 dari validasi';
      });
      hasError = true;
    }

    return hasError;
  }

  Future<void> _submit(int studentId, int artworkId) async {
    setState(() {
      _isLoading = true;
      _descriptionError = null;
      _feedbackError = null;
      _learningGoalsError = null;
      _imagesError = null;
    });

    if (_validateInputs()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final dto = EditSeriesPhotoDto(
      description: _descriptionController.text,
      feedback: _feedbackController.text,
      learningGoals:
          _editableLearningGoals.map((goal) => goal.id as int).toList(),
      photos: _images,
    );

    try {
      final SuccessResponse<SeriesPhoto> response = await SeriesPhotoService()
          .editSeriesPhoto(studentId, widget.seriesPhoto.id, dto);

      if (response.status == 'success') {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(ColorSnackbar.build(
          message: response.message,
          success: true,
        ));
        Navigator.pop(context, true);
      }
    } on ErrorException catch (e) {
      setState(() {
        _imagesError = e.message;
      });
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
    final seriesPhoto = widget.seriesPhoto;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah penilaian foto berseri'),
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
              MultiPhotoManager(
                mode: PhotoMode.edit,
                imageError: _imagesError,
                onImagesSelected: (List<dynamic>? images) {
                  setState(() {
                    _images.clear();
                    _images.addAll(images!);
                    // _images = [..._images, ...images!];
                  });
                },
                initialImageUrls: seriesPhoto.seriesPhotos!
                    .map((photo) => photo.photoLink)
                    .toList(),
              ),
              if (_imagesError != null)
                Text(
                  _imagesError!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 10),

              // Submit
              SubmitPrimaryButton(
                text: 'Ubah',
                onPressed: () => _submit(seriesPhoto.studentId, seriesPhoto.id),
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
