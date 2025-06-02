import 'package:asesmen_paud/api/payload/checklist_payload.dart';
import 'package:asesmen_paud/api/service/checklist_service.dart';
import 'package:asesmen_paud/pages/checklists/show_checklist_page.dart';
import 'package:asesmen_paud/widget/assessment/create_button.dart';
import 'package:asesmen_paud/widget/assessment/date_range_picker_button.dart';
import 'package:asesmen_paud/widget/assessment/index_list_tile.dart';
import 'package:asesmen_paud/widget/assessment/index_list_view.dart';
import 'package:asesmen_paud/widget/sort_button.dart';
import 'package:flutter/material.dart';

class ChecklistsPage extends StatefulWidget {
  const ChecklistsPage({super.key});

  @override
  ChecklistsPageState createState() => ChecklistsPageState();
}

class ChecklistsPageState extends State<ChecklistsPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Checklist> _checklists = [];

  String _errorMessage = '';
  String _sortOrder = 'desc';
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;

  late int studentId;

  DateTimeRange? _selectedDateRange;

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

  void _resetChecklists() {
    setState(() {
      _checklists.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
  }

  void _onSortSelected(String order) {
    setState(() {
      _sortOrder = order;
      _resetChecklists();
    });
    _fetchChecklists();
  }

  void _onDateRangeSelected(DateTimeRange? picked) {
    setState(() {
      _selectedDateRange = picked;
      _resetChecklists();
    });
    _fetchChecklists();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchChecklists(page: _currentPage + 1);
    }
  }

  void _updateChecklists(List<Checklist> newChecklists, int page) {
    setState(() {
      _checklists.addAll(newChecklists.where((checklist) =>
          !_checklists.any((existing) => existing.id == checklist.id)));
      _currentPage = page;
      _hasMoreData = newChecklists.length >= 10;
    });
  }

  Future<void> _onRefresh() async {
    _resetChecklists();
    await _fetchChecklists();
  }

  void _onTileTap(BuildContext context, Checklist checklist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowChecklistPage(checklist: checklist),
      ),
    );
  }

  Future<void> _fetchChecklists({int page = 1}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ChecklistService().getAllStudentChecklists(
        studentId,
        page,
        _selectedDateRange?.start.toIso8601String().substring(0, 10),
        _selectedDateRange?.end.toIso8601String().substring(0, 10),
        _sortOrder,
      );

      _updateChecklists(response.payload!.data, page);
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
              DateRangePickerButton(
                  selectedDateRange: _selectedDateRange,
                  onDateRangeSelected: _onDateRangeSelected),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SortButton(
                    label: 'Tanggal dibuat',
                    sortOrder: _sortOrder,
                    onSortChanged: _onSortSelected,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: IndexListView<Checklist>(
                errorMessage: _errorMessage,
                isLoading: _isLoading,
                hasMoreData: _hasMoreData,
                onRefresh: _onRefresh,
                scrollController: _scrollController,
                items: _checklists,
                itemBuilder: (context, checklist) => IndexListTile<Checklist>(
                    item: checklist,
                    createDate: checklist.createdAt!,
                    updateDate: checklist.updatedAt!,
                    onTap: (c) => _onTileTap(context, c)),
              ))
            ],
          ),
        ),
        floatingActionButton:
            CreateButton(mode: 'checklist', studentId: studentId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
