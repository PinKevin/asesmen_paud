import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/payload/login_payload.dart';
import 'package:asesmen_paud/widget/button/submit_primary.dart';
import 'package:asesmen_paud/widget/error_message.dart';
import 'package:flutter/material.dart';
import 'package:asesmen_paud/api/service/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _passwordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() {
        _isLoading = true;
        _emailError = null;
        _passwordError = null;
        _errorMessage = '';
      });

      final SuccessResponse<LoginPayload> response = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (response.status == 'success') {
        if (!mounted) return;
        AuthService.saveToken(response.payload!.token);
        Navigator.pushReplacementNamed(context, '/dashboard');
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        border: const OutlineInputBorder(),
        errorText: _emailError,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email wajib diisi';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Format email tidak valid';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        border: const OutlineInputBorder(),
        errorText: _passwordError,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
          icon: Icon(
            _passwordVisible ? Icons.visibility_off : Icons.visibility,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ErrorMessage(message: _errorMessage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign-in'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 10),
                _buildErrorMessage(),
                SubmitPrimaryButton(
                  text: 'Sign-in',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
              ],
            )),
      ),
    );
  }
}
