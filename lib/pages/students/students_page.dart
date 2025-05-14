import 'dart:async';

import 'package:asesmen_paud/api/payload/student_payload.dart';
import 'package:asesmen_paud/api/service/student_service.dart';
import 'package:asesmen_paud/widget/search_field.dart';
import 'package:asesmen_paud/widget/sort_button.dart';
import 'package:asesmen_paud/widget/student/student_list_view.dart';
import 'package:flutter/material.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  StudentsPageState createState() => StudentsPageState();
}

class StudentsPageState extends State<StudentsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Student> _students = [];

  String _errorMessage = '';
  String _mode = 'student';
  String _sortOrder = 'asc';
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setMode();
    _fetchStudents();
  }

  void _setMode() {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map?;
    _mode = routeArgs?['mode'] ?? 'student';
  }

  void _resetStudents() {
    setState(() {
      _students.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
  }

  void _onSortSelected(String order) {
    setState(() {
      _sortOrder = order;
      _resetStudents();
    });
    _fetchStudents();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _resetStudents();
      _fetchStudents();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMoreData) {
      _fetchStudents(page: _currentPage + 1);
    }
  }

  void _updateStudents(List<Student> newStudents, int page) {
    setState(() {
      _students.addAll(newStudents.where((student) =>
          !_students.any((existing) => existing.id == student.id)));
      _currentPage = page;
      _hasMoreData = newStudents.length >= 10;
    });
  }

  Future<void> _fetchStudents({int page = 1}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await StudentService().getAllStudents(
        page,
        _searchController.text.trim(),
        _sortOrder,
      );

      _updateStudents(response.payload!.data, page);
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

  void _onAddStudent() {
    Navigator.pushNamed(context, '/create-student');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Murid'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchField(controller: _searchController),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Chip(label: Text('tes')),
                SortButton(
                  label: 'Nama',
                  sortOrder: _sortOrder,
                  onSortChanged: _onSortSelected,
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: StudentListView(
                students: _students,
                errorMessage: _errorMessage,
                isLoading: _isLoading,
                hasMoreData: _hasMoreData,
                mode: _mode,
                onRefresh: () async {
                  _resetStudents();
                  await _fetchStudents();
                },
                scrollController: _scrollController,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: _mode == 'student'
          ? FloatingActionButton(
              onPressed: _onAddStudent,
              tooltip: 'Tambah Murid',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
