import 'package:asesmen_paud/api/service/auth_service.dart';
import 'package:asesmen_paud/widget/color_snackbar.dart';
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
        ColorSnackbar.build(message: 'Anda berhasil sign-out', success: true),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        ColorSnackbar.build(message: '$e', success: false),
      );
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
                    : const Icon(Icons.logout),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Align(
                  alignment: Alignment.centerLeft,
                  child: Greeting(teacherName: teacherName),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 10,
                    ),
                    children: [
                      MenuButton(
                        icon: Icons.create,
                        label: 'Anekdot',
                        onPressed: () => _navigateToStudents(
                          arguments: {'mode': 'anecdotal'},
                        ),
                      ),
                      MenuButton(
                        icon: Icons.palette,
                        label: 'Hasil Karya',
                        onPressed: () => _navigateToStudents(
                          arguments: {'mode': 'artwork'},
                        ),
                      ),
                      MenuButton(
                        icon: Icons.check,
                        label: 'Ceklis',
                        onPressed: () => _navigateToStudents(
                          arguments: {'mode': 'checklist'},
                        ),
                      ),
                      MenuButton(
                        icon: Icons.camera_alt,
                        label: 'Foto Berseri',
                        onPressed: () => _navigateToStudents(
                          arguments: {'mode': 'series-photo'},
                        ),
                      ),
                      MenuButton(
                        icon: Icons.article,
                        label: 'Laporan Bulanan',
                        onPressed: () => _navigateToStudents(
                          arguments: {'mode': 'report'},
                        ),
                      ),
                      MenuButton(
                        icon: Icons.person,
                        label: 'Murid',
                        onPressed: () => _navigateToStudents(
                          arguments: {'mode': 'student'},
                        ),
                      ),
                      MenuButton(
                        icon: Icons.info,
                        label: 'Murid',
                        onPressed: () => _navigateToStudents(
                          arguments: {'mode': 'student'},
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
