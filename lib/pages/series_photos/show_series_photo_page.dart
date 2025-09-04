import 'package:asesmen_paud/api/payload/series_photo_payload.dart';
import 'package:asesmen_paud/api/service/series_photo_service.dart';
import 'package:asesmen_paud/pages/series_photos/edit_series_photo_page.dart';
import 'package:asesmen_paud/widget/assessment/learning_goal_list.dart';
import 'package:asesmen_paud/widget/assessment/multi_photo_manager.dart';
import 'package:asesmen_paud/widget/assessment/show_field.dart';
import 'package:asesmen_paud/widget/assessment/show_menu.dart';
import 'package:flutter/material.dart';

class ShowSeriesPhotoPage extends StatefulWidget {
  final SeriesPhoto seriesPhoto;

  const ShowSeriesPhotoPage({super.key, required this.seriesPhoto});

  @override
  State<ShowSeriesPhotoPage> createState() => _ShowSeriesPhotoPageState();
}

class _ShowSeriesPhotoPageState extends State<ShowSeriesPhotoPage> {
  SeriesPhoto? _seriesPhoto;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchSeriesPhotoData();
  }

  Future<void> _fetchSeriesPhotoData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await SeriesPhotoService()
          .showSeriesPhoto(widget.seriesPhoto.studentId, widget.seriesPhoto.id);
      setState(() {
        _seriesPhoto = response.payload;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  void _goToEditPage() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditSeriesPhotoPage(
                  seriesPhoto: _seriesPhoto!,
                )));

    if (result) {
      await _fetchSeriesPhotoData();
    }
  }

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

  Widget _buildShowPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShowField(title: 'Deskripsi', content: _seriesPhoto!.description),
            ShowField(title: 'Umpan balik', content: _seriesPhoto!.feedback),
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
            LearningGoalList(
              learningGoals: _seriesPhoto!.learningGoals!,
              editing: false,
            ),
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
            MultiPhotoManager(
              mode: PhotoMode.show,
              initialImageUrls: _seriesPhoto!.seriesPhotos!
                  .map((photo) => photo.photoLink)
                  .toList(),
              onImagesSelected: (_) {},
            ),
            const SizedBox(
              height: 10,
            ),
            ShowMenu<SeriesPhoto>(
              item: _seriesPhoto!,
              onEdit: (context) => _goToEditPage(),
              onDelete: (context) => _showDeleteDialog(
                context,
                _seriesPhoto!.studentId,
                _seriesPhoto!.id,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_seriesPhoto == null) {
      return const Center(child: Text('Data tidak ditemukan'));
    }

    return _buildShowPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail foto berseri'),
      ),
      body: _buildContent(),
    );
  }
}
