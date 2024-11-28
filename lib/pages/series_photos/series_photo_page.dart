import 'package:asesmen_paud/api/payload/series_photo_payload.dart';
import 'package:asesmen_paud/api/service/series_photo_service.dart';
import 'package:asesmen_paud/pages/series_photos/show_series_photo_page.dart';
import 'package:asesmen_paud/widget/assessment/create_button.dart';
import 'package:asesmen_paud/widget/assessment/date_range_picker_button.dart';
import 'package:asesmen_paud/widget/assessment/index_list_tile.dart';
import 'package:asesmen_paud/widget/assessment/index_list_view.dart';
import 'package:asesmen_paud/widget/sort_button.dart';
import 'package:flutter/material.dart';

class SeriesPhotosPage extends StatefulWidget {
  const SeriesPhotosPage({super.key});

  @override
  SeriesPhotosPageState createState() => SeriesPhotosPageState();
}

class SeriesPhotosPageState extends State<SeriesPhotosPage> {
  final ScrollController _scrollController = ScrollController();
  final List<SeriesPhoto> _seriesPhotos = [];

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
    _fetchSeriesPhotos();
  }

  void _resetSeriesPhotos() {
    setState(() {
      _seriesPhotos.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
  }

  void _onSortSelected(String order) {
    setState(() {
      _sortOrder = order;
      _resetSeriesPhotos();
    });
    _fetchSeriesPhotos();
  }

  void _onDateRangeSelected(DateTimeRange? picked) {
    setState(() {
      _selectedDateRange = picked;
      _resetSeriesPhotos();
    });
    _fetchSeriesPhotos();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchSeriesPhotos(page: _currentPage + 1);
    }
  }

  void _updateSeriesPhotos(List<SeriesPhoto> newSeriesPhotos, int page) {
    setState(() {
      _seriesPhotos.addAll(newSeriesPhotos.where((seriesPhoto) =>
          !_seriesPhotos.any((existing) => existing.id == seriesPhoto.id)));
      _currentPage = page;
      _hasMoreData = newSeriesPhotos.length >= 10;
    });
  }

  Future<void> _onRefresh() async {
    _resetSeriesPhotos();
    await _fetchSeriesPhotos();
  }

  _onTileTap(BuildContext context, SeriesPhoto seriesPhoto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowSeriesPhotoPage(seriesPhoto: seriesPhoto),
      ),
    );
  }

  Future<void> _fetchSeriesPhotos({int page = 1}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await SeriesPhotoService().getAllStudentSeriesPhotos(
          studentId,
          page,
          _selectedDateRange?.start.toIso8601String().substring(0, 10),
          _selectedDateRange?.end.toIso8601String().substring(0, 10),
          _sortOrder);

      _updateSeriesPhotos(response.payload!.data, page);
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
          title: const Text('Foto Berseri'),
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
                  child: IndexListView<SeriesPhoto>(
                errorMessage: _errorMessage,
                isLoading: _isLoading,
                hasMoreData: _hasMoreData,
                onRefresh: _onRefresh,
                scrollController: _scrollController,
                items: _seriesPhotos,
                itemBuilder: (context, seriesPhoto) =>
                    IndexListTile<SeriesPhoto>(
                        item: seriesPhoto,
                        createDate: seriesPhoto.createdAt!,
                        updateDate: seriesPhoto.updatedAt!,
                        onTap: (s) => _onTileTap(context, s)),
              ))
            ],
          ),
        ),
        floatingActionButton:
            CreateButton(mode: 'series-phoyo', studentId: studentId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
