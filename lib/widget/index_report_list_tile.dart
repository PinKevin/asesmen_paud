import 'package:asesmen_paud/api/payload/student_report_payload.dart';
import 'package:asesmen_paud/helper/date_time_manipulator.dart';
import 'package:flutter/material.dart';

class IndexReportListTile extends StatelessWidget {
  final StudentReport studentReport;
  final Function(StudentReport) onTap;

  const IndexReportListTile(
      {super.key, required this.studentReport, required this.onTap});

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
          onLongPress: () => onTap(studentReport),
          onPressed: () => onTap(studentReport),
          child: Card(
            margin: EdgeInsets.zero,
            color: Colors.transparent,
            elevation: 0,
            child: ListTile(
              title: Text('Laporan Bulan $formattedMonth $formattedYear'),
              subtitle: Text('Dibuat tanggal $createdDate'),
              trailing: const Icon(Icons.download),
            ),
          ),
        ));
  }
}
