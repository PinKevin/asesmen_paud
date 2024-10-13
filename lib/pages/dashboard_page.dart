import 'package:asesmen_paud/api/service/auth_service.dart';
import 'package:asesmen_paud/pages/login_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
              onPressed: () {
                AuthService.clearToken();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: const Center(
        child: Text('Welcome'),
      ),
    );
  }
}
