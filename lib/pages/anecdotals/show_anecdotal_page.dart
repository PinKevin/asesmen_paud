import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/anecdotal_payload.dart';
import 'package:asesmen_paud/api/service/anecdotal_service.dart';
import 'package:asesmen_paud/pages/anecdotals/edit_anecdotal_page.dart';
import 'package:asesmen_paud/widget/assessment/learning_goal_list.dart';
import 'package:asesmen_paud/widget/assessment/photo_manager.dart';
import 'package:asesmen_paud/widget/assessment/show_field.dart';
import 'package:asesmen_paud/widget/assessment/show_menu.dart';
import 'package:asesmen_paud/widget/color_snackbar.dart';
import 'package:flutter/material.dart';

class ShowAnecdotalPage extends StatefulWidget {
  final Anecdotal anecdotal;

  const ShowAnecdotalPage({super.key, required this.anecdotal});

  @override
  State<ShowAnecdotalPage> createState() => _ShowAnecdotalPageState();
}

class _ShowAnecdotalPageState extends State<ShowAnecdotalPage> {
  Anecdotal? _anecdotal;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchAnecdotalData();
  }

  Future<void> _fetchAnecdotalData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AnecdotalService().showAnecdotal(
        widget.anecdotal.studentId,
        widget.anecdotal.id,
      );
      setState(() {
        _anecdotal = response.payload;
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
      BuildContext context, int studentId, int anecdotalId) async {
    try {
      final response =
          await AnecdotalService().deleteAnecdotal(studentId, anecdotalId);

      if (!context.mounted) return;
      Navigator.popUntil(context, ModalRoute.withName('/anecdotals'));
      ScaffoldMessenger.of(context).showSnackBar(
        ColorSnackbar.build(
          message: response.message,
          success: true,
        ),
      );
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

  Future<void> _goToEditPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAnecdotalPage(
          anecdotal: _anecdotal!,
        ),
      ),
    );
    await _fetchAnecdotalData();
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
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
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
              content: _anecdotal!.description,
            ),
            ShowField(
              title: 'Umpan balik',
              content: _anecdotal!.feedback,
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
              learningGoals: _anecdotal!.learningGoals!,
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
              initialImageUrl: _anecdotal!.photoLink,
              onImageSelected: (_) {},
            ),
            const SizedBox(
              height: 10,
            ),
            ShowMenu<Anecdotal>(
              assessment: _anecdotal!,
              onEdit: (context) => _goToEditPage(),
              onDelete: (context) => _showDeleteDialog(
                context,
                _anecdotal!.studentId,
                _anecdotal!.id,
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

    if (_anecdotal == null) {
      return const Center(child: Text('Data tidak ditemukan'));
    }

    return _buildShowPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail anekdot'),
      ),
      body: _buildContent(),
    );
  }
}
