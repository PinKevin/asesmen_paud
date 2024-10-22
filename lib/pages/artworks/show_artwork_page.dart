import 'package:asesmen_paud/api/payload/artwork_payload.dart';
import 'package:asesmen_paud/api/service/artwork_service.dart';
import 'package:asesmen_paud/api/service/photo_service.dart';
import 'package:asesmen_paud/pages/artworks/edit_artwork_page.dart';
import 'package:flutter/material.dart';

class ShowArtworkPage extends StatefulWidget {
  final Artwork artwork;

  const ShowArtworkPage({super.key, required this.artwork});

  @override
  State<ShowArtworkPage> createState() => _ShowArtworkPageState();
}

class _ShowArtworkPageState extends State<ShowArtworkPage> {
  String? errorMessage;

  Future<void> _delete(
      BuildContext context, int studentId, int artworkId) async {
    try {
      final response =
          await ArtworkService().deleteArtwork(studentId, artworkId);

      if (!context.mounted) return;
      Navigator.popUntil(context, ModalRoute.withName('/artworks'));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _fetchArtworkData() async {
    Artwork? artwork = widget.artwork;
    try {
      final updatedArtwork =
          await ArtworkService().showArtwork(artwork.studentId, artwork.id);
      setState(() {
        artwork = updatedArtwork.payload;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void _goToEditPage(BuildContext context, Artwork artwork) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditArtworkPage(
                  artwork: artwork,
                )));

    if (result) {
      await _fetchArtworkData();
    }
  }

  Future<void> _showDeleteDialog(
      BuildContext context, int studentId, int artworkId) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Hapus hasil karya'),
                content: const Text('Yakin ingin hapus hasil karya?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        _delete(context, studentId, artworkId);
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
    final artwork = widget.artwork;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail hasil karya'),
        ),
        body: FutureBuilder(
            future: ArtworkService().showArtwork(artwork.studentId, artwork.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Data tidak ditemukan'));
              }

              final updatedArtwork = snapshot.data!.payload!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Deskripsi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        updatedArtwork.description,
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Umpan Balik',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        updatedArtwork.feedback,
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Capaian Pembelajaran',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (updatedArtwork.learningGoals!.isNotEmpty)
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: updatedArtwork.learningGoals!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final learningGoal =
                                  updatedArtwork.learningGoals?[index];
                              return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(0),
                                        backgroundColor: Colors.deepPurple[50],
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      FutureBuilder(
                          future:
                              PhotoService().getPhoto(updatedArtwork.photoLink),
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _showDeleteDialog(
                                  context, artwork.studentId, artwork.id);
                            },
                            label: const Text(
                              'Hapus hasil karya',
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
                            onPressed: () {
                              _goToEditPage(context, updatedArtwork);
                            },
                            label: const Text(
                              'Ubah hasil karya',
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
              );
            }));
  }
}
