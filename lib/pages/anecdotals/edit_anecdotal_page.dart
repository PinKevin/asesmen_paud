import 'package:asesmen_paud/api/dto/anecdotal_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/anecdotal_payload.dart';
import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/anecdotal_service.dart';
import 'package:asesmen_paud/api/service/photo_service.dart';
import 'package:asesmen_paud/pages/learning_goals_page.dart';
import 'package:asesmen_paud/widget/anecdotal/anecdotal_field.dart';
import 'package:asesmen_paud/widget/photo_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditAnecdotalPage extends StatefulWidget {
  final Anecdotal anecdotal;

  const EditAnecdotalPage({super.key, required this.anecdotal});

  @override
  State<EditAnecdotalPage> createState() => _EditAnecdotalPageState();
}

class _EditAnecdotalPageState extends State<EditAnecdotalPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  List<dynamic> learningGoals = [];
  XFile? _image;
  bool onChangedImage = false;

  bool _isLoading = false;
  String? _descriptionError;
  String? _feedbackError;
  String? _learningGoalsError;
  String? _imageError;
  String _errorMessage = '';

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

  Future<void> _submit(int studentId, int anecdotalId) async {
    setState(() {
      _isLoading = true;
      _descriptionError = null;
      _feedbackError = null;
      _learningGoalsError = null;
      _imageError = null;
      _errorMessage = '';
    });

    final dto = EditAnecdotalDto(
        description: _descriptionController.text,
        feedback: _feedbackController.text,
        learningGoals: learningGoals.map((goal) => goal.id as int).toList(),
        photo: _image);

    try {
      final SuccessResponse<Anecdotal> response =
          await AnecdotalService().editAnecdotal(studentId, anecdotalId, dto);
      if (response.status == 'success') {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response.message)));
        Navigator.pop(context);
      }
    } catch (e) {
      if (e is ValidationException) {
        setState(() {
          _descriptionError = e.errors['description']?.message ?? '';
          _feedbackError = e.errors['feedback']?.message ?? '';
          _learningGoalsError = e.errors['learningGoals']?.message ?? '';
          _imageError = e.errors['photo']?.message ?? '';
        });
      } else {
        setState(() {
          _errorMessage = '$e';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.anecdotal.description;
    _feedbackController.text = widget.anecdotal.feedback;
    learningGoals = widget.anecdotal.learningGoals ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final anecdotal = widget.anecdotal;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Ubah penilaian anekdot'),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnecdotalField(
                          controller: _descriptionController,
                          labelText: 'Deskripsi',
                          errorText: _descriptionError),
                      const SizedBox(
                        height: 20,
                      ),
                      AnecdotalField(
                          controller: _feedbackController,
                          labelText: 'Umpan Balik',
                          errorText: _feedbackError),
                      const SizedBox(
                        height: 20,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Capaian Pembelajaran',
                        ),
                      ),
                      if (learningGoals.isNotEmpty)
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: learningGoals.length,
                            itemBuilder: (context, index) {
                              final learningGoal = learningGoals[index];
                              return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(0),
                                        backgroundColor: Colors.deepPurple[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        )),
                                    onPressed: () {},
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      color: Colors.transparent,
                                      elevation: 0,
                                      child: ListTile(
                                        title: Text(
                                          learningGoal.learningGoalName,
                                          textAlign: TextAlign.justify,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${learningGoal.learningGoalCode}',
                                          textAlign: TextAlign.justify,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        trailing: IconButton(
                                            onPressed: () {
                                              _showDeleteLearningGoalDialog(
                                                  learningGoal);
                                            },
                                            icon: const Icon(Icons.delete)),
                                      ),
                                    ),
                                  ));
                            }),
                      const SizedBox(
                        height: 5,
                      ),
                      if (_learningGoalsError != null)
                        Text(
                          _learningGoalsError ??
                              'Terjadi error pada capaian pembelajaran',
                          style: const TextStyle(color: Colors.red),
                        ),
                      if (_learningGoalsError != null)
                        const SizedBox(
                          height: 5,
                        ),
                      ElevatedButton(
                          onPressed: _goToLearningGoalSelection,
                          child: const Text('Tambah Capaian Pembelajaran')),
                      const SizedBox(
                        height: 20,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Foto Anekdot',
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (onChangedImage == true)
                        PhotoField(
                            image: _image,
                            onImageSelected: (image) {
                              setState(() {
                                _image = image;
                              });
                            }),
                      if (onChangedImage == false)
                        FutureBuilder(
                            future:
                                PhotoService().getPhoto(anecdotal.photoLink),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return const Center(
                                  child: Text('Gagal memuat foto'),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data != null) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else {
                                return const Center(
                                  child: Text('Tidak ada foto'),
                                );
                              }
                            }),
                      if (onChangedImage == false)
                        const SizedBox(
                          height: 10,
                        ),
                      if (onChangedImage == false)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              onChangedImage = !onChangedImage;
                            });
                          },
                          child: const Text('Ganti foto'),
                        ),
                      if (_imageError != null)
                        const SizedBox(
                          height: 5,
                        ),
                      if (_imageError != null)
                        Text(
                          _imageError ?? 'Terjadi error pada gambar',
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (_errorMessage.isNotEmpty)
                        Text(_errorMessage,
                            style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: () {
                          _submit(anecdotal.studentId, anecdotal.id);
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
                                'Ubah Anekdot',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ]))));
  }
}
