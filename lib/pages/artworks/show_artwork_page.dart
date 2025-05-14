import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/artwork_payload.dart';
import 'package:asesmen_paud/api/service/artwork_service.dart';
import 'package:asesmen_paud/pages/artworks/edit_artwork_page.dart';
import 'package:asesmen_paud/widget/assessment/learning_goal_list.dart';
import 'package:asesmen_paud/widget/assessment/photo_manager.dart';
import 'package:asesmen_paud/widget/assessment/show_field.dart';
import 'package:asesmen_paud/widget/assessment/show_menu.dart';
import 'package:asesmen_paud/widget/color_snackbar.dart';
import 'package:flutter/material.dart';

class ShowArtworkPage extends StatefulWidget {
  final Artwork artwork;

  const ShowArtworkPage({super.key, required this.artwork});

  @override
  State<ShowArtworkPage> createState() => _ShowArtworkPageState();
}

class _ShowArtworkPageState extends State<ShowArtworkPage> {
  Artwork? _artwork;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchArtworkData();
  }

  Future<void> _fetchArtworkData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ArtworkService().showArtwork(
        widget.artwork.studentId,
        widget.artwork.id,
      );
      setState(() {
        _artwork = response.payload;
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
          await ArtworkService().deleteArtwork(studentId, artworkId);

      if (!context.mounted) return;
      Navigator.popUntil(context, ModalRoute.withName('/artworks'));
      ScaffoldMessenger.of(context).showSnackBar(
          ColorSnackbar.build(message: response.message, success: true));
    } on ErrorException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        ColorSnackbar.build(
          message: e.message,
          success: false,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        ColorSnackbar.build(
          message: e.toString(),
          success: false,
        ),
      );
    }
  }

  void _goToEditPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditArtworkPage(
          artwork: _artwork!,
        ),
      ),
    );
    await _fetchArtworkData();
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    int studentId,
    int artworkId,
  ) async {
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
            ShowField(
              title: 'Deskripsi',
              content: _artwork!.description,
            ),
            ShowField(
              title: 'Umpan balik',
              content: _artwork!.feedback,
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
            LearningGoalList(
              learningGoals: _artwork!.learningGoals!,
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
            PhotoManager(
              mode: PhotoMode.show,
              initialImageUrl: _artwork!.photoLink,
              onImageSelected: (_) {},
            ),
            const SizedBox(
              height: 10,
            ),
            ShowMenu<Artwork>(
              item: _artwork!,
              onEdit: (context) => _goToEditPage(),
              onDelete: (context) => _showDeleteDialog(
                context,
                _artwork!.studentId,
                _artwork!.id,
              ),
            )
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

    if (_artwork == null) {
      return const Center(child: Text('Data tidak ditemukan'));
    }

    return _buildShowPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail hasil karya'),
      ),
      body: _buildContent(),
    );
  }
}
