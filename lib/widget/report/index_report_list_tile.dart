import 'package:asesmen_paud/api/payload/student_report_payload.dart';
import 'package:asesmen_paud/helper/date_time_manipulator.dart';
import 'package:flutter/material.dart';

class IndexReportListTile extends StatelessWidget {
  final StudentReport studentReport;
  final bool isLoading;
  final Function() onDownload;
  final Function() onDelete;

  const IndexReportListTile(
      {super.key,
      required this.studentReport,
      required this.isLoading,
      required this.onDownload,
      required this.onDelete});

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Peringatan'),
            content: const Text('Ingin hapus laporan bulanan?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Kembali',
                    style: TextStyle(color: Colors.grey[600]),
                  )),
              TextButton(
                  onPressed: () {
                    onDownload();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Ya',
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    DateTimeManipulator manipulator = DateTimeManipulator();

    String formattedMonth =
        manipulator.getWordMonthFromDate(studentReport.startReportDate);
    int formattedYear =
        manipulator.getYearFromDate(studentReport.startReportDate);
    String createdDate = manipulator.formatDate(studentReport.createdAt!);

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
              title: Text('Laporan Bulan $formattedMonth $formattedYear'),
              subtitle: Text('Dibuat tanggal $createdDate'),
              trailing: PopupMenuButton(
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.more_vert,
                          size: 30,
                        ),
                  onSelected: (value) {
                    if (value == 'download') {
                      onDownload();
                    } else if (value == 'delete') {
                      _showDeleteConfirmationDialog(context);
                    }
                  },
                  itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'download',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.download,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text('Download')
                              ],
                            )),
                        const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ))
                      ]),
            ),
          ),
        ));
  }
}
