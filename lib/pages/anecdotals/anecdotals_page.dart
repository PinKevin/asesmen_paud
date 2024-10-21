import 'package:asesmen_paud/api/payload/anecdotal_payload.dart';
import 'package:asesmen_paud/api/service/anecdotal_service.dart';
import 'package:asesmen_paud/pages/anecdotals/show_anecdotal_page.dart';
import 'package:asesmen_paud/widget/anecdotal/anecdotal_list_tile.dart';
import 'package:asesmen_paud/widget/search_field.dart';
import 'package:flutter/material.dart';

class AnecdotalsPage extends StatefulWidget {
  const AnecdotalsPage({super.key});

  @override
  AnecdotalsPageState createState() => AnecdotalsPageState();
}

class AnecdotalsPageState extends State<AnecdotalsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Anecdotal> _anecdotals = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMoreData = true;
  late int studentId;

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

  Future<void> _fetchAnecdotals({int page = 1}) async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final anecdotalsResponse =
          await AnecdotalService().getAllStudentAnecdotals(studentId, page);

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
      _fetchAnecdotals(page: _currentPage + 1);
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
            SearchField(controller: _searchController),
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
    _searchController.dispose();
    super.dispose();
  }
}
