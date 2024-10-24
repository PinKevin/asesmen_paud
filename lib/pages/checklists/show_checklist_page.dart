import 'package:asesmen_paud/api/payload/checklist_payload.dart';
import 'package:asesmen_paud/api/service/checklist_service.dart';
import 'package:asesmen_paud/pages/checklists/edit_checklist_page.dart';
import 'package:asesmen_paud/pages/checklists/show_checklist_point_page.dart';
import 'package:flutter/material.dart';

class ShowChecklistPage extends StatefulWidget {
  final Checklist checklist;

  const ShowChecklistPage({super.key, required this.checklist});

  @override
  State<ShowChecklistPage> createState() => _ShowChecklistPageState();
}

class _ShowChecklistPageState extends State<ShowChecklistPage> {
  String? errorMessage;

  Future<void> _delete(
      BuildContext context, int studentId, int checklistId) async {
    try {
      final response =
          await ChecklistService().deleteChecklist(studentId, checklistId);

      if (!context.mounted) return;
      Navigator.popUntil(context, ModalRoute.withName('/checklists'));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _fetchChecklistData() async {
    Checklist? checklist = widget.checklist;
    try {
      final updatedChecklist = await ChecklistService()
          .showChecklist(checklist.studentId, checklist.id);
      setState(() {
        checklist = updatedChecklist.payload;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void _goToEditPage(BuildContext context, Checklist checklist) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditChecklistPage(
                  checklist: checklist,
                )));

    if (result) {
      await _fetchChecklistData();
    }
  }

  Future<void> _showDeleteDialog(
      BuildContext context, int studentId, int checklistId) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Hapus ceklis'),
                content: const Text('Yakin ingin hapus ceklis?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        _delete(context, studentId, checklistId);
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

  void _viewMoreChecklistPoint(ChecklistPoint checklistPoint) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ShowChecklistPointPage(checklistPoint: checklistPoint)));
  }

  @override
  Widget build(BuildContext context) {
    final checklist = widget.checklist;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail ceklis'),
        ),
        body: FutureBuilder(
            future: ChecklistService()
                .showChecklist(checklist.studentId, checklist.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Data tidak ditemukan'));
              }

              final updatedChecklist = snapshot.data!.payload!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Capaian Pembelajaran',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (updatedChecklist.checklistPoints!.isNotEmpty)
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: updatedChecklist.checklistPoints!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final checklistPoint =
                                  updatedChecklist.checklistPoints?[index];
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
                                    onPressed: () {
                                      _viewMoreChecklistPoint(checklistPoint);
                                    },
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      color: Colors.transparent,
                                      elevation: 0,
                                      child: ListTile(
                                        title: Text(
                                          checklistPoint!.context,
                                          textAlign: TextAlign.justify,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Text(
                                          checklistPoint.hasAppeared == 1
                                              ? 'Sudah muncul'
                                              : 'Belum muncul',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _showDeleteDialog(
                                  context, checklist.studentId, checklist.id);
                            },
                            label: const Text(
                              'Hapus ceklis',
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
                              _goToEditPage(context, updatedChecklist);
                            },
                            label: const Text(
                              'Ubah ceklis',
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
