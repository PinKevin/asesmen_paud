import 'package:asesmen_paud/api/payload/student_report_payload.dart';
import 'package:asesmen_paud/api/service/report_service.dart';
import 'package:asesmen_paud/helper/month_list.dart';
import 'package:asesmen_paud/widget/report/index_report_list_tile.dart';
import 'package:asesmen_paud/widget/sort_button.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ScrollController _scrollController = ScrollController();

  final List<StudentReport> _studentReports = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMoreData = true;
  late int studentId;

  String? _formattedStartDate;
  String? _formattedEndDate;

  String _sortOrder = 'desc';

  final List<Map<int, String>> _monthList = monthList;
  final List<int> _yearList = [];
  late int _startYear;
  late int _endYear;

  int? _selectedMonth;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _endYear = DateTime.now().year;
    _startYear = _endYear - 2;

    for (var i = _startYear; i <= _endYear; i++) {
      _yearList.add(i);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    studentId = ModalRoute.of(context)!.settings.arguments as int;
    _fetchReports();
  }

  void _onFilter() {
    if (_selectedMonth != null && _selectedYear != null) {
      final startDate = DateTime(_selectedYear!, _selectedMonth!, 1);
      final endDate = DateTime(_selectedYear!, _selectedMonth! + 1, 0);

      setState(() {
        _formattedStartDate = startDate.toIso8601String().substring(0, 10);
        _formattedEndDate = endDate.toIso8601String().substring(0, 10);

        _studentReports.clear();
        _currentPage = 1;
        _hasMoreData = true;
      });

      _fetchReports();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih bulan dan tahun untuk mem-filter')));
    }
  }

  void _onSortSelected(String order) {
    setState(() {
      _sortOrder = order;
      _studentReports.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
    _fetchReports(sortBy: order);
  }

  Future<void> _fetchReports({int page = 1, String sortBy = 'desc'}) async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final reportsResponse = await ReportService().getAllStudentReports(
          studentId, page, _formattedStartDate, _formattedEndDate, sortBy);

      final newReports = reportsResponse.payload!.data;
      setState(() {
        if (newReports.isEmpty || newReports.length < 10) {
          _hasMoreData = false;
        }

        for (var report in newReports) {
          if (!_studentReports.any((r) => r.id == report.id)) {
            _studentReports.add(report);
          }
        }

        _currentPage = page;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchReports(page: _currentPage + 1, sortBy: _sortOrder);
    }
  }

  Future<void> _showDownloadConfirmDialog(StudentReport studentReport) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Peringatan'),
            content: const Text('Ingin download laporan bulanan?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Kembali',
                    style: TextStyle(color: Colors.black),
                  )),
              TextButton(
                  onPressed: () {
                    _downloadExistingReport(studentId, studentReport.id);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Ya',
                  )),
            ],
          );
        });
  }

  Future<void> _downloadExistingReport(int studentId, int reportId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final String filePath =
          await ReportService().downloadExistingReport(studentId, reportId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Laporan berhasil diunduh'),
        action: SnackBarAction(
            label: 'BUKA',
            onPressed: () async {
              await OpenFilex.open(filePath);
            }),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Terjadi masalah saat mengunduh laporan')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Bulanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: DropdownButtonFormField<int>(
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
                ),
                const SizedBox(
                  width: 15,
                ),
                Flexible(
                  child: DropdownButtonFormField<int>(
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
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    onPressed: () {
                      _onFilter();
                    },
                    child: const Text('Filter')),
                SortButton(
                    label: 'Tanggal dibuat',
                    sortOrder: _sortOrder,
                    onSortChanged: _onSortSelected)
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _studentReports.clear();
                  _currentPage = 1;
                  _hasMoreData = true;
                });
                await _fetchReports();
              },
              child: _studentReports.isEmpty && _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _studentReports.length + 1,
                      itemBuilder: (context, index) {
                        if (index < _studentReports.length) {
                          final report = _studentReports[index];
                          return IndexReportListTile(
                              studentReport: report,
                              onTap: (report) {
                                _showDownloadConfirmDialog(report);
                              });
                        } else {
                          return _hasMoreData
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(_studentReports.isEmpty
                                        ? 'Belum ada penilaian foto berseri. Buat baru dengan tekan tombol kanan bawah!'
                                        : 'Anda sudah mencapai akhir halaman'),
                                  ),
                                );
                        }
                      },
                    ),
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create-report',
              arguments: studentId);
          if (result == true) {
            _studentReports.clear();
            _currentPage = 1;
            _hasMoreData = true;
            _fetchReports();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
