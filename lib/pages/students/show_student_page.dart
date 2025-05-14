import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/student_payload.dart';
import 'package:asesmen_paud/api/service/student_service.dart';
import 'package:asesmen_paud/helper/date_time_manipulator.dart';
import 'package:asesmen_paud/pages/students/edit_student_page.dart';
import 'package:asesmen_paud/widget/assessment/photo_manager.dart';
import 'package:asesmen_paud/widget/assessment/show_field.dart';
import 'package:asesmen_paud/widget/assessment/show_menu.dart';
import 'package:asesmen_paud/widget/color_snackbar.dart';
import 'package:flutter/material.dart';

class ShowStudentPage extends StatefulWidget {
  final Student student;

  const ShowStudentPage({super.key, required this.student});

  @override
  State<ShowStudentPage> createState() => _ShowStudentPageState();
}

class _ShowStudentPageState extends State<ShowStudentPage> {
  Student? _student;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _student ??= widget.student;
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await StudentService().showStudent(widget.student.id);
      setState(() {
        _student = response.payload;
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

  Future<void> _delete(BuildContext context, int studentId) async {
    try {
      // final response = await AnecdotalService().deleteAnecdotal(
      //   studentId,
      //   anecdotalId,
      // );

      if (!context.mounted) return;
      Navigator.popUntil(context, ModalRoute.withName('/students'));
      ScaffoldMessenger.of(context).showSnackBar(
        ColorSnackbar.build(
          message: 'Delete',
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
        builder: (context) => EditStudentPage(
          student: _student!,
        ),
      ),
    );
    await _fetchStudentData();
  }

  Future<void> _showDeleteDialog(BuildContext context, int studentId) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus murid'),
        content: const Text('Yakin ingin hapus data murid?'),
        actions: [
          TextButton(
            onPressed: () {
              _delete(context, studentId);
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
              title: 'Nama',
              content: _student!.name,
            ),
            ShowField(
              title: 'NISN',
              content: _student!.nisn,
            ),
            ShowField(
              title: 'Tempat Lahir',
              content: _student!.placeOfBirth!,
            ),
            ShowField(
              title: 'Tanggal Lahir',
              content: DateTimeManipulator()
                  .convertIsoToDate(_student!.dateOfBirth!),
            ),
            ShowField(
              title: 'Jenis Kelamin',
              content: _student!.gender!,
            ),
            ShowField(
              title: 'Agama',
              content: _student!.religion!,
            ),
            ShowField(
              title: 'Tanggal Penerimaan',
              content: DateTimeManipulator()
                  .convertIsoToDate(_student!.acceptanceDate!),
            ),
            ShowField(
              title: 'Nama Kelas',
              content: _student!.className!,
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
            if (_student?.photoProfileLink != null)
              PhotoManager(
                mode: PhotoMode.show,
                initialImageUrl: _student!.photoProfileLink!,
                onImageSelected: (_) {},
              ),
            const SizedBox(
              height: 10,
            ),
            ShowMenu<Student>(
              item: _student!,
              onEdit: (context) => _goToEditPage(),
              onDelete: (context) => _showDeleteDialog(
                context,
                _student!.id,
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

    if (_student == null) {
      return const Center(child: Text('Data tidak ditemukan'));
    }

    return _buildShowPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail murid'),
      ),
      body: _buildContent(),
    );
  }
}
