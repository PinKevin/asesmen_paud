import 'package:asesmen_paud/api/payload/artwork_payload.dart';
import 'package:asesmen_paud/api/service/artwork_service.dart';
import 'package:asesmen_paud/helper/datetime_converter.dart';
import 'package:asesmen_paud/pages/artworks/show_artwork_page.dart';
import 'package:asesmen_paud/widget/index_list_tile.dart';
import 'package:flutter/material.dart';

class ArtworksPage extends StatefulWidget {
  const ArtworksPage({super.key});

  @override
  ArtworksPageState createState() => ArtworksPageState();
}

class ArtworksPageState extends State<ArtworksPage> {
  final ScrollController _scrollController = ScrollController();

  final List<Artwork> _artworks = [];
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
    _fetchArtworks();
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
        _artworks.clear();
        _currentPage = 1;
        _hasMoreData = true;
      });
      _fetchArtworks();
    }
  }

  void _onSortSelected(String order) {
    setState(() {
      _sortOrder = order;
      _artworks.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
    _fetchArtworks(sortBy: order);
  }

  Future<void> _fetchArtworks({int page = 1, String sortBy = 'desc'}) async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final artworksResponse = await ArtworkService().getAllStudentArtworks(
          studentId, page, _formattedStartDate, _formattedEndDate, sortBy);

      final newArtworks = artworksResponse.payload!.data;

      setState(() {
        if (newArtworks.isEmpty || newArtworks.length < 10) {
          _hasMoreData = false;
        }

        for (var artwork in newArtworks) {
          if (!_artworks.any((a) => a.id == artwork.id)) {
            _artworks.add(artwork);
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
      _fetchArtworks(page: _currentPage + 1, sortBy: _sortOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil karya'),
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
                child: _artworks.isEmpty && _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _artworks.length + 1,
                        itemBuilder: (context, index) {
                          if (index < _artworks.length) {
                            final artwork = _artworks[index];
                            return IndexListTile<Artwork>(
                                item: artwork,
                                getCreateDate: (item) =>
                                    formatDate(item.createdAt!),
                                getUpdateDate: (item) =>
                                    formatDate(item.updatedAt!),
                                onTap: (artwork) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ShowArtworkPage(
                                              artwork: artwork)));
                                });
                          } else {
                            return _hasMoreData
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : _artworks.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: Text(
                                              'Belum ada hasil karya. Buat hasil karya baru dengan menekan tombol di kanan bawah!'),
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
          Navigator.pushNamed(context, '/create-artwork', arguments: studentId);
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
