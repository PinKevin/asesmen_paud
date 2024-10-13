import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/login_payload.dart';
import 'package:asesmen_paud/pages/dashboard_page.dart';
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

  bool _passwordVisible = false;

  bool isLoading = false;
  String _errorMessage = '';
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  void _login() async {
    try {
      isLoading = true;

      setState(() {
        _emailError = null;
        _passwordError = null;
        _errorMessage = '';
      });

      final SuccessResponse<LoginPayload> response = await _authService.login(
          _emailController.text, _passwordController.text);

      if (response.status == 'success') {
        if (!mounted) return;

        AuthService.saveToken(response.payload!.token);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const DashboardPage()));
      }
    } catch (e) {
      if (e is ValidationException) {
        setState(() {
          _emailError = e.errors['email']?.message ?? '';
          _passwordError = e.errors['password']?.message ?? '';
        });
      } else if (e is ErrorException) {
        setState(() {
          _errorMessage = e.message;
        });
      } else {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      isLoading = false;
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
              decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  errorText: _emailError,
                  errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red))),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  errorText: _passwordError,
                  errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                      icon: Icon(_passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility))),
              obscureText: !_passwordVisible,
            ),
            const SizedBox(
              height: 10,
            ),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 40),
                  backgroundColor: Colors.deepPurple),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : const Text(
                      'Login',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
