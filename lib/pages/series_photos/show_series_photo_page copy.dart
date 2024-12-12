import 'package:asesmen_paud/api/payload/series_photo_payload.dart';
import 'package:asesmen_paud/api/service/photo_service.dart';
import 'package:asesmen_paud/api/service/series_photo_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ShowSeriesPhotoPage extends StatefulWidget {
  final SeriesPhoto seriesPhoto;

  const ShowSeriesPhotoPage({super.key, required this.seriesPhoto});

  @override
  State<ShowSeriesPhotoPage> createState() => _ShowSeriesPhotoPageState();
}

class _ShowSeriesPhotoPageState extends State<ShowSeriesPhotoPage> {
  String? errorMessage;

  Future<void> _delete(
      BuildContext context, int studentId, int artworkId) async {
    try {
      final response =
          await SeriesPhotoService().deleteSeriesPhoto(studentId, artworkId);

      if (!context.mounted) return;
      Navigator.popUntil(context, ModalRoute.withName('/series-photos'));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  // Future<void> _fetchSeriesPhotoData() async {
  //   SeriesPhoto? seriesPhoto = widget.seriesPhoto;
  //   try {
  //     final updatedSeriesPhoto = await SeriesPhotoService()
  //         .showSeriesPhoto(seriesPhoto.studentId, seriesPhoto.id);
  //     setState(() {
  //       seriesPhoto = updatedSeriesPhoto.payload;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = e.toString();
  //     });
  //   }
  // }

  // void _goToEditPage(BuildContext context, SeriesPhoto seriesPhoto) async {
  //   final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => EditSeriesPhotoPage(
  //                 seriesPhoto: seriesPhoto,
  //               )));

  //   if (result) {
  //     await _fetchSeriesPhotoData();
  //   }
  // }

  Future<void> _showDeleteDialog(
    BuildContext context,
    int studentId,
    int artworkId,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus foto berseri'),
        content: const Text('Yakin ingin hapus foto berseri?'),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seriesPhoto = widget.seriesPhoto;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail foto berseri'),
        ),
        body: FutureBuilder(
            future: SeriesPhotoService()
                .showSeriesPhoto(seriesPhoto.studentId, seriesPhoto.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Data tidak ditemukan'));
              }

              final updatedSeriesPhoto = snapshot.data!.payload!;
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
                        updatedSeriesPhoto.description,
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
                        updatedSeriesPhoto.feedback,
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
                      if (updatedSeriesPhoto.learningGoals!.isNotEmpty)
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: updatedSeriesPhoto.learningGoals!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final learningGoal =
                                  updatedSeriesPhoto.learningGoals?[index];
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
                      updatedSeriesPhoto.seriesPhotos!.isNotEmpty
                          ? CarouselSlider(
                              items:
                                  updatedSeriesPhoto.seriesPhotos?.map((photo) {
                                return FutureBuilder(
                                    future: PhotoService()
                                        .getPhoto(photo.photoLink),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (snapshot.hasError) {
                                        return const Center(
                                          child: Text('Gagal memuat foto'),
                                        );
                                      } else if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                          ),
                                        );
                                      } else {
                                        return const Center(
                                          child: Text('Tidak ada foto'),
                                        );
                                      }
                                    });
                              }).toList(),
                              options: CarouselOptions(
                                  height: 300,
                                  enableInfiniteScroll: true,
                                  enlargeCenterPage: true,
                                  viewportFraction: 0.8,
                                  autoPlay: true))
                          : const Center(child: Text('Tidak ada foto')),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                _showDeleteDialog(context,
                                    seriesPhoto.studentId, seriesPhoto.id);
                              },
                              label: const Text(
                                'Hapus foto berseri',
                                style: TextStyle(color: Colors.red),
                              ),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white),
                            ),
                            // ElevatedButton.icon(
                            //   onPressed: () {
                            //     _goToEditPage(context, updatedSeriesPhoto);
                            //   },
                            //   label: const Text(
                            //     'Ubah foto berseri',
                            //     style: TextStyle(color: Colors.blue),
                            //   ),
                            //   icon: const Icon(
                            //     Icons.edit,
                            //     color: Colors.blue,
                            //   ),
                            //   style: ElevatedButton.styleFrom(
                            //       backgroundColor: Colors.white),
                            // ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }));
  }
}
