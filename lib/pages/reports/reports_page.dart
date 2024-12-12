import 'package:asesmen_paud/api/payload/student_report_payload.dart';
import 'package:asesmen_paud/api/service/report_service.dart';
import 'package:asesmen_paud/widget/assessment/create_button.dart';
import 'package:asesmen_paud/widget/assessment/index_list_view.dart';
import 'package:asesmen_paud/widget/color_snackbar.dart';
import 'package:asesmen_paud/widget/dropdown.dart';
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

  String _errorMessage = '';
  String _sortOrder = 'desc';
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;

  late int studentId;

  int _selectedYear = DateTime.now().year;
  String? _formattedStartDate;
  String? _formattedEndDate;
  List<int> years = List.generate(3, (i) => DateTime.now().year - i);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _formattedStartDate =
        DateTime(_selectedYear, 1, 1).toIso8601String().substring(0, 10);
    _formattedEndDate =
        DateTime(_selectedYear, 12, 31).toIso8601String().substring(0, 10);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    studentId = ModalRoute.of(context)!.settings.arguments as int;
    _fetchReports();
  }

  void _resetStudentReports() {
    setState(() {
      _studentReports.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
  }

  void _onSortSelected(String order) {
    setState(() {
      _sortOrder = order;
      _resetStudentReports();
    });
    _fetchReports();
  }

  void _filterByYear(int selectedYear) {
    setState(() {
      _formattedStartDate =
          DateTime(selectedYear, 1, 1).toIso8601String().substring(0, 10);
      _formattedEndDate =
          DateTime(selectedYear, 12, 31).toIso8601String().substring(0, 10);

      _resetStudentReports();
    });
    _fetchReports();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchReports(page: _currentPage + 1);
    }
  }

  void _updateStudentReports(List<StudentReport> newStudentReports, int page) {
    setState(() {
      _studentReports.addAll(newStudentReports.where((studentReport) =>
          !_studentReports.any((existing) => existing.id == studentReport.id)));
      _currentPage = page;
      _hasMoreData = newStudentReports.length >= 10;
    });
  }

  Future<void> _onRefresh() async {
    _resetStudentReports();
    await _fetchReports();
  }

  Future<void> _fetchReports({int page = 1}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ReportService().getAllStudentReports(
          studentId, page, _formattedStartDate, _formattedEndDate, _sortOrder);

      _updateStudentReports(response.payload!.data, page);
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

  Future<void> _downloadExistingReport(int studentId, int reportId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final String filePath = await ReportService().downloadExistingReport(
        context,
        studentId,
        reportId,
      );

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
      ScaffoldMessenger.of(context)
          .showSnackBar(ColorSnackbar.build(message: '$e', success: false));
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Dropdown<int>(
                          labelText: 'Pilih tahun',
                          value: _selectedYear,
                          options: years,
                          displayText: (year) => year.toString(),
                          onChanged: (value) {
                            if (value != null) {
                              _selectedYear = value;
                              _filterByYear(_selectedYear);
                            }
                          }))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SortButton(
                      label: 'Tanggal laporan',
                      sortOrder: _sortOrder,
                      onSortChanged: _onSortSelected)
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: IndexListView<StudentReport>(
                      errorMessage: _errorMessage,
                      isLoading: _isLoading,
                      hasMoreData: _hasMoreData,
                      onRefresh: _onRefresh,
                      scrollController: _scrollController,
                      items: _studentReports,
                      itemBuilder: (context, report) => IndexReportListTile(
                            studentReport: report,
                            isLoading: _isLoading,
                            onDownload: () {
                              _downloadExistingReport(studentId, report.id);
                            },
                            onDelete: () {},
                          ))),
            ],
          ),
        ),
        floatingActionButton:
            CreateButton(mode: 'report', studentId: studentId));
  }
}
