import 'package:asesmen_paud/api/payload/learning_goal_payload.dart';
import 'package:asesmen_paud/widget/anecdotal/anecdotal_field.dart';
import 'package:asesmen_paud/pages/learning_goals_page.dart';
import 'package:asesmen_paud/widget/photo_field.dart';
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

  String? _descriptionError;
  String? _feedbackError;

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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(0),
                                  backgroundColor: Colors.deepPurple[100],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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
                PhotoField(
                    image: _image,
                    onImageSelected: (image) {
                      setState(() {
                        _image = image;
                      });
                    }),
                Text('$studentId'),
                Text('$_image'),
                Text('$learningGoals')
              ],
            ),
          ),
        ));
  }
}
