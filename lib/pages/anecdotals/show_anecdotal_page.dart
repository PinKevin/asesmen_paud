import 'package:asesmen_paud/api/payload/anecdotal_payload.dart';
import 'package:asesmen_paud/api/service/anecdotal_service.dart';
import 'package:asesmen_paud/api/service/photo_service.dart';
import 'package:flutter/material.dart';

class ShowAnecdotalPage extends StatelessWidget {
  final Anecdotal anecdotal;

  const ShowAnecdotalPage({super.key, required this.anecdotal});

  Future<void> _delete(
      BuildContext context, int studentId, int anecdotalId) async {
    try {
      final response =
          await AnecdotalService().deleteAnecdotal(studentId, anecdotalId);

      if (!context.mounted) return;
      Navigator.popUntil(context, ModalRoute.withName('/anecdotals'));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _showDeleteDialog(
      BuildContext context, int studentId, int anecdotalId) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Hapus anekdot'),
                content: const Text('Yakin ingin hapus anekdot?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        _delete(context, studentId, anecdotalId);
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.red),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Batal')),
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail anekdot'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  anecdotal.description,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Umpan Balik',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  anecdotal.feedback,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Capaian Pembelajaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (anecdotal.learningGoals!.isNotEmpty)
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: anecdotal.learningGoals!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final learningGoal = anecdotal.learningGoals?[index];
                        return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(0),
                                  backgroundColor: Colors.deepPurple[50],
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
                                    learningGoal!.learningGoalName,
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    learningGoal.learningGoalCode,
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ));
                      }),
                const SizedBox(
                  height: 10,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Foto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder(
                    future: PhotoService().getPhoto(anecdotal.photoLink),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                      } else if (snapshot.hasData && snapshot.data != null) {
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
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _showDeleteDialog(
                            context, anecdotal.studentId, anecdotal.id);
                      },
                      label: const Text(
                        'Hapus anekdot',
                        style: TextStyle(color: Colors.red),
                      ),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      label: const Text(
                        'Ubah anekdot',
                        style: TextStyle(color: Colors.blue),
                      ),
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
