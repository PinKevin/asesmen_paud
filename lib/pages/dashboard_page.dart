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

  void _goToAnecdotStudentsMenu() {
    Navigator.pushNamed(context, '/students', arguments: {'mode': 'anecdotal'});
  }

  void _goToArtworkStudentsMenu() {
    Navigator.pushNamed(context, '/students', arguments: {'mode': 'artwork'});
  }

  void _goToChecklistStudentsMenu() {
    Navigator.pushNamed(context, '/students', arguments: {'mode': 'checklist'});
  }

  void _goToSeriesPhotoStudentsMenu() {
    Navigator.pushNamed(context, '/students',
        arguments: {'mode': 'series-photo'});
  }

  void _goToReportMenu() {
    Navigator.pushNamed(context, '/students', arguments: {'mode': 'report'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
                onPressed: _logout,
                icon: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : const Icon(Icons.logout))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Greeting(
                teacherName: 'Orang',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MenuButton(
                      icon: Icons.create,
                      label: 'Anekdot',
                      onPressed: () {
                        _goToAnecdotStudentsMenu();
                      }),
                  MenuButton(
                      icon: Icons.palette,
                      label: 'Hasil Karya',
                      onPressed: () {
                        _goToArtworkStudentsMenu();
                      })
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                MenuButton(
                    icon: Icons.check,
                    label: 'Ceklis',
                    onPressed: () {
                      _goToChecklistStudentsMenu();
                    }),
                MenuButton(
                    icon: Icons.camera_alt,
                    label: 'Foto Berseri',
                    onPressed: () {
                      _goToSeriesPhotoStudentsMenu();
                    })
              ]),
              const SizedBox(
                height: 30,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                MenuButton(
                    icon: Icons.article,
                    label: 'Laporan Bulanan',
                    onPressed: () {
                      _goToReportMenu();
                    })
              ]),
            ],
          ),
        ));
  }
}
