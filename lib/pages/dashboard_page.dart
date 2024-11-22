import 'package:asesmen_paud/api/service/auth_service.dart';
import 'package:asesmen_paud/widget/dashboard/greeting.dart';
import 'package:asesmen_paud/widget/dashboard/menu_button.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  bool _isLoading = false;
  final AuthService authService = AuthService();

  late Future<String?> _teacherName;

  @override
  void initState() {
    super.initState();
    _teacherName = _getTeacherInfo();
  }

  Future<String?> _getTeacherInfo() async {
    try {
      final response = await AuthService().getProfile();
      return response.payload!.name;
    } catch (e) {
      return 'Guru';
    }
  }

  void _logout() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await authService.logout();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda berhasil sign out')));

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to logout: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToStudents({Map<String, dynamic>? arguments}) {
    Navigator.pushNamed(context, '/students', arguments: arguments);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: _teacherName,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final teacherName = snapshot.data ?? 'Guru';

          return Scaffold(
              appBar: AppBar(
                title: const Text('Dashboard'),
                actions: [
                  IconButton(
                      onPressed: _logout,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const Icon(Icons.logout))
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Greeting(teacherName: teacherName),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MenuButton(
                            icon: Icons.create,
                            label: 'Anekdot',
                            onPressed: () => _navigateToStudents(
                                arguments: {'mode': 'anecdotal'})),
                        MenuButton(
                            icon: Icons.palette,
                            label: 'Hasil Karya',
                            onPressed: () => _navigateToStudents(
                                arguments: {'mode': 'artwork'}))
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MenuButton(
                              icon: Icons.check,
                              label: 'Ceklis',
                              onPressed: () => _navigateToStudents(
                                  arguments: {'mode': 'checklist'})),
                          MenuButton(
                              icon: Icons.camera_alt,
                              label: 'Foto Berseri',
                              onPressed: () => _navigateToStudents(
                                  arguments: {'mode': 'series-photo'}))
                        ]),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MenuButton(
                              icon: Icons.article,
                              label: 'Laporan Bulanan',
                              onPressed: () => _navigateToStudents(
                                  arguments: {'mode': 'report'}))
                        ]),
                  ],
                ),
              ));
        });
  }
}
