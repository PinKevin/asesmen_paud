import 'package:asesmen_paud/api/service/auth_service.dart';
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
            children: [
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _goToAnecdotStudentsMenu,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'Anekdot',
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _goToArtworkStudentsMenu,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'Hasil Karya',
                    style: TextStyle(fontSize: 16),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
