import 'package:asesmen_paud/api/service/report_service.dart';
import 'package:asesmen_paud/helper/month_list.dart';
import 'package:flutter/material.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final List<Map<int, String>> _monthList = monthList;
  final List<int> _yearList = [];
  late int _startYear;
  late int _endYear;

  int? _selectedMonth;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _endYear = DateTime.now().year;
    _startYear = _endYear - 2;

    for (var i = _startYear; i <= _endYear; i++) {
      _yearList.add(i);
    }
  }

  Future<void> _createReport(int studentId) async {
    if (_selectedMonth == null || _selectedYear == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih bulan dan tahun')));
      return;
    }

    try {
      await ReportService()
          .createAndDownloadReport(studentId, _selectedMonth!, _selectedYear!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil dibuat')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi masalah saat membuat laporan. $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final int studentId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Buat laporan bulanan'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Pilih bulan',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedMonth,
                    items: _monthList.map((month) {
                      final monthKey = month.keys.first;
                      final monthValue = month.values.first;
                      return DropdownMenuItem<int>(
                          value: monthKey,
                          child: Text(
                            monthValue,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value;
                      });
                    }),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Pilih tahun',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedYear,
                    items: _yearList.map((year) {
                      return DropdownMenuItem(
                          value: year,
                          child: Text(
                            '$year',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                      });
                    }),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      _createReport(studentId);
                    },
                    child: const Text('Pilih'))
              ],
            ),
          ),
        ));
  }
}
