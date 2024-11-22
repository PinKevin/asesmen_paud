import 'package:asesmen_paud/api/payload/student_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/student_service.dart';
import 'package:asesmen_paud/widget/search_field.dart';
import 'package:asesmen_paud/widget/sort_button.dart';
import 'package:asesmen_paud/widget/student/student_list_tile.dart';
import 'package:flutter/material.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  StudentsPageState createState() => StudentsPageState();
}

class StudentsPageState extends State<StudentsPage> {
  String _mode = 'anecdotal';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _errorMessage = '';

  final List<Student> _students = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMoreData = true;
  late int studentId;

  String _sortOrder = 'asc';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map?;
    _mode = routeArgs != null && routeArgs.containsKey('mode')
        ? routeArgs['mode']
        : 'anecdotal';
    _fetchStudents();
  }

  void _onSortSelected(String order) {
    setState(() {
      _sortOrder = order;
      _students.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
    _fetchStudents(sortBy: order);
  }

  void _onSearchChanged() {
    setState(() {
      _students.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
    _fetchStudents();
  }

  Future<void> _fetchStudents({int page = 1, String sortBy = 'asc'}) async {
    if (_isLoading || !_hasMoreData) return;
    String searchQuery = _searchController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      SuccessResponse<StudentsPaginated> studentsResponse;
      if (searchQuery.isEmpty) {
        studentsResponse =
            await StudentService().getAllStudents(page, '', sortBy);
      } else {
        studentsResponse =
            await StudentService().getAllStudents(page, searchQuery, sortBy);
      }

      final newStudents = studentsResponse.payload!.data;

      setState(() {
        if (newStudents.isEmpty || newStudents.length < 10) {
          _hasMoreData = false;
        }

        for (var student in newStudents) {
          if (!_students.any((s) => s.id == student.id)) {
            _students.add(student);
          }
        }

        _currentPage = page;
      });
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchStudents(page: _currentPage + 1, sortBy: _sortOrder);
    }
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SortButton(
                      label: 'Nama',
                      sortOrder: _sortOrder,
                      onSortChanged: _onSortSelected)
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _students.clear();
                    _currentPage = 1;
                    _hasMoreData = true;
                  });
                  await _fetchStudents();
                },
                child: _errorMessage.isNotEmpty
                    ? const SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Center(
                            child: Text(
                              'Belum ada murid. Tarik ke bawah untuk menyegarkan.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : _students.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _students.length + 1,
                            itemBuilder: (context, index) {
                              if (index < _students.length) {
                                final student = _students[index];
                                return StudentListTile(
                                    student: student,
                                    onStudentTap: (anecdot) {
                                      if (_mode == 'anecdotal') {
                                        Navigator.pushNamed(
                                            context, '/anecdotals',
                                            arguments: student.id);
                                      } else if (_mode == 'artwork') {
                                        Navigator.pushNamed(
                                            context, '/artworks',
                                            arguments: student.id);
                                      } else if (_mode == 'checklist') {
                                        Navigator.pushNamed(
                                            context, '/checklists',
                                            arguments: student.id);
                                      } else if (_mode == 'series-photo') {
                                        Navigator.pushNamed(
                                            context, '/series-photos',
                                            arguments: student.id);
                                      } else if (_mode == 'report') {
                                        Navigator.pushNamed(context, '/reports',
                                            arguments: student.id);
                                      }
                                    });
                              } else {
                                return _hasMoreData
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Center(
                                          child: Text(_students.isEmpty
                                              ? 'Belum ada murid. Silakan hubungi admin!'
                                              : 'Anda sudah mencapai akhir halaman'),
                                        ),
                                      );
                              }
                            },
                          ),
              ))
            ],
          ),
        ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
