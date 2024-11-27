import 'package:asesmen_paud/api/payload/anecdotal_payload.dart';
import 'package:asesmen_paud/api/service/anecdotal_service.dart';
import 'package:asesmen_paud/helper/date_time_manipulator.dart';
import 'package:asesmen_paud/pages/anecdotals/show_anecdotal_page.dart';
import 'package:asesmen_paud/widget/assessment/create_button.dart';
import 'package:asesmen_paud/widget/assessment/date_range_picker_button.dart';
import 'package:asesmen_paud/widget/assessment/index_list_tile.dart';
import 'package:asesmen_paud/widget/assessment/index_list_view.dart';
import 'package:asesmen_paud/widget/sort_button.dart';
import 'package:flutter/material.dart';

class AnecdotalsPage extends StatefulWidget {
  const AnecdotalsPage({super.key});

  @override
  AnecdotalsPageState createState() => AnecdotalsPageState();
}

class AnecdotalsPageState extends State<AnecdotalsPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Anecdotal> _anecdotals = [];

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
    _fetchAnecdotals();
  }

  void _resetAnecdotals() {
    setState(() {
      _anecdotals.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
  }

  void _onSortSelected(String order) {
    setState(() {
      _sortOrder = order;
      _resetAnecdotals();
    });
    _fetchAnecdotals();
  }

  void _onDateRangeSelected(DateTimeRange? picked) {
    setState(() {
      _selectedDateRange = picked;
      _resetAnecdotals();
    });
    _fetchAnecdotals();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchAnecdotals(page: _currentPage + 1);
    }
  }

  void _updateAnecdotals(List<Anecdotal> newAnecdotal, int page) {
    setState(() {
      _anecdotals.addAll(newAnecdotal.where((anecdotal) =>
          !_anecdotals.any((existing) => existing.id == anecdotal.id)));
      _currentPage = page;
      _hasMoreData = newAnecdotal.length >= 10;
    });
  }

  Future<void> _fetchAnecdotals({int page = 1}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AnecdotalService().getAllStudentAnecdotals(
          studentId,
          page,
          _selectedDateRange?.start.toIso8601String().substring(0, 10),
          _selectedDateRange?.end.toIso8601String().substring(0, 10),
          _sortOrder);

      _updateAnecdotals(response.payload!.data, page);
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
          title: const Text('Anekdot'),
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
                      onSortChanged: _onSortSelected)
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: IndexListView<Anecdotal>(
                errorMessage: _errorMessage,
                isLoading: _isLoading,
                hasMoreData: _hasMoreData,
                onRefresh: () async {
                  _resetAnecdotals();
                  await _fetchAnecdotals();
                },
                scrollController: _scrollController,
                items: _anecdotals,
                itemBuilder: (context, anecdotal) => IndexListTile(
                  item: anecdotal,
                  getCreateDate: (a) =>
                      DateTimeManipulator().formatDate(a.createdAt!),
                  getUpdateDate: (a) =>
                      DateTimeManipulator().formatDate(a.updatedAt!),
                  onTap: (a) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowAnecdotalPage(anecdotal: a),
                      ),
                    );
                  },
                ),
              ))
            ],
          ),
        ),
        floatingActionButton:
            CreateButton(mode: 'anecdotal', studentId: studentId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
