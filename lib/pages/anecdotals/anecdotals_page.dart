import 'package:asesmen_paud/api/payload/anecdotal_payload.dart';
import 'package:asesmen_paud/api/service/anecdotal_service.dart';
import 'package:asesmen_paud/pages/anecdotals/show_anecdotal_page.dart';
import 'package:asesmen_paud/widget/anecdotal/anecdotal_list_tile.dart';
import 'package:flutter/material.dart';

class AnecdotalsPage extends StatefulWidget {
  const AnecdotalsPage({super.key});

  @override
  AnecdotalsPageState createState() => AnecdotalsPageState();
}

class AnecdotalsPageState extends State<AnecdotalsPage> {
  final ScrollController _scrollController = ScrollController();

  final List<Anecdotal> _anecdotals = [];
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
    _fetchAnecdotals();
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
        _anecdotals.clear();
        _currentPage = 1;
        _hasMoreData = true;
      });
      _fetchAnecdotals();
    }
  }

  void _onSortSelected(String order) {
    setState(() {
      _sortOrder = order;
      _anecdotals.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
    _fetchAnecdotals(sortBy: order);
  }

  Future<void> _fetchAnecdotals({int page = 1, String sortBy = 'desc'}) async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final anecdotalsResponse = await AnecdotalService()
          .getAllStudentAnecdotals(
              studentId, page, _formattedStartDate, _formattedEndDate, sortBy);

      final newAnecdotals = anecdotalsResponse.payload!.data;

      setState(() {
        if (newAnecdotals.isEmpty || newAnecdotals.length < 10) {
          _hasMoreData = false;
        }

        for (var anecdotal in newAnecdotals) {
          if (!_anecdotals.any((a) => a.id == anecdotal.id)) {
            _anecdotals.add(anecdotal);
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
      _fetchAnecdotals(page: _currentPage + 1, sortBy: _sortOrder);
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
                child: _anecdotals.isEmpty && _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _anecdotals.length + 1,
                        itemBuilder: (context, index) {
                          if (index < _anecdotals.length) {
                            final anecdotal = _anecdotals[index];
                            return AnecdotalListTile(
                                anecdotal: anecdotal,
                                onAnecdotalTap: (anecdot) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ShowAnecdotalPage(
                                                  anecdotal: anecdot)));
                                });
                          } else {
                            return _hasMoreData
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : _anecdotals.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: Text(
                                              'Belum ada anekdot. Buat anekdot baru dengan menekan tombol di kanan bawah!'),
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
          Navigator.pushNamed(context, '/create-anecdotal',
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
