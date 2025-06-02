import 'package:asesmen_paud/api/payload/artwork_payload.dart';
import 'package:asesmen_paud/api/service/artwork_service.dart';
import 'package:asesmen_paud/pages/artworks/show_artwork_page.dart';
import 'package:asesmen_paud/widget/assessment/create_button.dart';
import 'package:asesmen_paud/widget/assessment/date_range_picker_button.dart';
import 'package:asesmen_paud/widget/assessment/index_list_tile.dart';
import 'package:asesmen_paud/widget/assessment/index_list_view.dart';
import 'package:asesmen_paud/widget/sort_button.dart';
import 'package:flutter/material.dart';

class ArtworksPage extends StatefulWidget {
  const ArtworksPage({super.key});

  @override
  ArtworksPageState createState() => ArtworksPageState();
}

class ArtworksPageState extends State<ArtworksPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Artwork> _artworks = [];

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
    _fetchArtworks();
  }

  void _resetArtworks() {
    setState(() {
      _artworks.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
  }

  void _onSortSelected(String order) {
    setState(() {
      _sortOrder = order;
      _resetArtworks();
    });
    _fetchArtworks();
  }

  void _onDateRangeSelected(DateTimeRange? picked) {
    setState(() {
      _selectedDateRange = picked;
      _resetArtworks();
    });
    _fetchArtworks();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchArtworks(page: _currentPage + 1);
    }
  }

  void _updateArtworks(List<Artwork> newArtworks, int page) {
    setState(() {
      _artworks.addAll(newArtworks.where((artwork) =>
          !_artworks.any((existing) => existing.id == artwork.id)));
      _currentPage = page;
      _hasMoreData = newArtworks.length >= 10;
    });
  }

  Future<void> _onRefresh() async {
    _resetArtworks();
    await _fetchArtworks();
  }

  void _onTileTap(BuildContext context, Artwork artwork) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowArtworkPage(artwork: artwork),
      ),
    );
  }

  Future<void> _fetchArtworks({int page = 1}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ArtworkService().getAllStudentArtworks(
          studentId,
          page,
          _selectedDateRange?.start.toIso8601String().substring(0, 10),
          _selectedDateRange?.end.toIso8601String().substring(0, 10),
          _sortOrder);

      _updateArtworks(response.payload!.data, page);
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
          title: const Text('Hasil karya'),
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
                  child: IndexListView<Artwork>(
                errorMessage: _errorMessage,
                isLoading: _isLoading,
                hasMoreData: _hasMoreData,
                onRefresh: _onRefresh,
                scrollController: _scrollController,
                items: _artworks,
                itemBuilder: (context, artwork) => IndexListTile<Artwork>(
                    item: artwork,
                    createDate: artwork.createdAt!,
                    updateDate: artwork.updatedAt!,
                    onTap: (a) => _onTileTap(context, a)),
              ))
            ],
          ),
        ),
        floatingActionButton:
            CreateButton(mode: 'artwork', studentId: studentId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
