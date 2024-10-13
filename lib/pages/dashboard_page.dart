import 'package:asesmen_paud/api/service/auth_service.dart';
import 'package:asesmen_paud/pages/login_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  bool isLoading = false;
  final AuthService authService = AuthService();

  void _logout() async {
    try {
      isLoading = true;

      await authService.logout();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda berhasil sign out')));

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to logout: $e')));
    } finally {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
              onPressed: _logout,
              icon: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : const Icon(Icons.logout))
        ],
      ),
      body: const Center(
        child: Text('Welcome'),
      ),
    );
  }
}
