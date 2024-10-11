import 'package:flutter/material.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String _message = '';

  void _login() async {
    try {
      final response = await _authService.login(
          _emailController.text, _passwordController.text);

      if (response.status == 'success') {
        setState(() {
          _message = 'Login success! Token: ${response.payload.token}';
        });
      } else {
        setState(() {
          _message = 'Login failed! ${response.message}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            const SizedBox(
              height: 20,
            ),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
