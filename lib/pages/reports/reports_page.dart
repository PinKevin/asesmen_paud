import 'package:asesmen_paud/api/payload/student_report_payload.dart';
import 'package:asesmen_paud/api/service/report_service.dart';
import 'package:asesmen_paud/widget/index_report_list_tile.dart';
import 'package:flutter/material.dart';

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

  DateTimeRange? _selectedDateRange;
  String? _formattedStartDate;
  String? _formattedEndDate;

  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    studentId = ModalRoute.of(context)!.settings.arguments as int;
    _fetchReports();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2024, 7),
        lastDate: DateTime.now());

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _formattedStartDate =
            _selectedDateRange?.start.toIso8601String().substring(0, 10);
        _formattedEndDate =
            _selectedDateRange?.end.toIso8601String().substring(0, 10);
        _studentReports.clear();
        _currentPage = 1;
        _hasMoreData = true;
      });
      _fetchReports();
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _selectDateRange(context),
                  child: Text(_selectedDateRange == null
                      ? 'Pilih rentang tanggal'
                      : 'Rentang $_formattedStartDate hingga $_formattedEndDate'),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                    onTap: () {
                      _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
                      _onSortSelected(_sortOrder);
                    },
                    child: Row(children: [
                      const Text('Tanggal dibuat'),
                      Icon(_sortOrder == 'asc'
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down)
                    ]))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: _studentReports.isEmpty && _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _studentReports.length + 1,
                        itemBuilder: (context, index) {
                          if (index < _studentReports.length) {
                            final report = _studentReports[index];
                            return IndexReportListTile(
                                studentReport: report, onTap: (report) {});
                          } else {
                            return _hasMoreData
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : _studentReports.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: Text(
                                              'Belum ada laporan bulanan. Buat laporan bulanan baru dengan menekan tombol di kanan bawah!'),
                                        ),
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: Text(
                                              'Anda sudah mencapai akhir halaman'),
                                        ),
                                      );
                          }
                        },
                      ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-report', arguments: studentId);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
