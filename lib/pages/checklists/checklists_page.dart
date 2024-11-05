import 'package:asesmen_paud/api/payload/checklist_payload.dart';
import 'package:asesmen_paud/api/service/checklist_service.dart';
import 'package:asesmen_paud/helper/datetime_converter.dart';
import 'package:asesmen_paud/pages/checklists/show_checklist_page.dart';
import 'package:asesmen_paud/widget/index_list_tile.dart';
import 'package:flutter/material.dart';

class ChecklistsPage extends StatefulWidget {
  const ChecklistsPage({super.key});

  @override
  ChecklistsPageState createState() => ChecklistsPageState();
}

class ChecklistsPageState extends State<ChecklistsPage> {
  final ScrollController _scrollController = ScrollController();

  final List<Checklist> _checklists = [];
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
    _fetchChecklists();
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
        _checklists.clear();
        _currentPage = 1;
        _hasMoreData = true;
      });
      _fetchChecklists();
    }
  }

  void _onSortSelected(String order) {
    setState(() {
      _sortOrder = order;
      _checklists.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
    _fetchChecklists(sortBy: order);
  }

  Future<void> _fetchChecklists({int page = 1, String sortBy = 'desc'}) async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final checklistsResponse = await ChecklistService()
          .getAllStudentChecklists(
              studentId, page, _formattedStartDate, _formattedEndDate, sortBy);

      final newChecklists = checklistsResponse.payload!.data;

      setState(() {
        if (newChecklists.isEmpty || newChecklists.length < 10) {
          _hasMoreData = false;
        }

        for (var checklist in newChecklists) {
          if (!_checklists.any((a) => a.id == checklist.id)) {
            _checklists.add(checklist);
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
      _fetchChecklists(page: _currentPage + 1, sortBy: _sortOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ceklis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () => _selectDateRange(context),
                child: Text(_selectedDateRange == null
                    ? 'Pilih rentang tanggal'
                    : 'Rentang: $_formattedStartDate hingga $_formattedEndDate')),
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
                  child: Row(
                    children: [
                      const Text('Tanggal dibuat'),
                      Icon(_sortOrder == 'asc'
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down)
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: _checklists.isEmpty && _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _checklists.length + 1,
                        itemBuilder: (context, index) {
                          if (index < _checklists.length) {
                            final checklist = _checklists[index];
                            return IndexListTile<Checklist>(
                                item: checklist,
                                getCreateDate: (item) =>
                                    formatDate(checklist.createdAt!),
                                getUpdateDate: (item) =>
                                    formatDate(checklist.updatedAt!),
                                onTap: (checklist) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ShowChecklistPage(
                                                  checklist: checklist)));
                                });
                          } else {
                            return _hasMoreData
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : _checklists.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: Text(
                                              'Belum ada penilaian ceklis. Buat ceklis baru dengan menekan tombol di kanan bawah!'),
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
          Navigator.pushNamed(context, '/create-checklist',
              arguments: studentId);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
