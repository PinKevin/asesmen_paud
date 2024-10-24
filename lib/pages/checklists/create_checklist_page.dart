import 'package:asesmen_paud/api/dto/checklist_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/checklist_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/checklist_service.dart';
import 'package:asesmen_paud/pages/checklists/create_checklist_point_page.dart';
import 'package:flutter/material.dart';

class CreateChecklistPage extends StatefulWidget {
  const CreateChecklistPage({super.key});

  @override
  State<CreateChecklistPage> createState() => CreateChecklistPageState();
}

class CreateChecklistPageState extends State<CreateChecklistPage> {
  List<dynamic> checklistPoints = [];

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _goToAddChecklistPointPage() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ChecklistPointPage()));
    if (result != null && result is ChecklistPointDto) {
      setState(() {
        checklistPoints.add(result);
      });
    }
  }

  Future<void> _showDeleteChecklistDialog(ChecklistPointDto checklistPoint) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Peringatan'),
            content: const Text('Yakin ingin hapus poin ceklis?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Kembali')),
              TextButton(
                  onPressed: () {
                    checklistPoints.remove(checklistPoint);
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

  Future<void> _submit(int studentId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final dto = CreateChecklistDto(checklistPoints);

    try {
      if (checklistPoints.isEmpty) {
        _errorMessage = 'Isi poin ceklis terlebih dahulu';
        return;
      }
      final SuccessResponse<Checklist> response =
          await ChecklistService().createChecklist(studentId, dto);

      if (response.status == 'success') {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response.message)));
        Navigator.pop(context);
      }
    } catch (e) {
      if (e is ValidationException) {
        setState(() {
          // _descriptionError = e.errors['description']?.message ?? '';
          // _feedbackError = e.errors['feedback']?.message ?? '';
          // _learningGoalsError = e.errors['learningGoals']?.message ?? '';
          // _imageError = e.errors['photo']?.message ?? '';
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
  Widget build(BuildContext context) {
    final int studentId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Buat penilaian ceklis'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Poin Ceklis',
                  ),
                ),
                if (checklistPoints.isNotEmpty)
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: checklistPoints.length,
                      itemBuilder: (context, index) {
                        final checklistPoint = checklistPoints[index];
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
                                    checklistPoint.context,
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    checklistPoint.hasAppeared == true
                                        ? 'Sudah muncul'
                                        : 'Belum muncul',
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: IconButton(
                                      onPressed: () {
                                        _showDeleteChecklistDialog(
                                            checklistPoint);
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
                    onPressed: _goToAddChecklistPointPage,
                    child: const Text('Tambah Poin Ceklis')),
                const SizedBox(
                  height: 10,
                ),
                if (_errorMessage.isNotEmpty)
                  Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)),
                ElevatedButton(
                  onPressed: () {
                    _submit(studentId);
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(280, 40),
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
                          'Tambah Penilaian Ceklis',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ));
  }
}
