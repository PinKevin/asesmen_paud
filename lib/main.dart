import 'package:asesmen_paud/api/service/auth_service.dart';
import 'package:asesmen_paud/pages/dashboard_page.dart';
import 'package:asesmen_paud/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkToken() async {
    final token = await AuthService.getToken();
    if (token != null) {
      final isValidToken = await AuthService.checkToken(token);
      return isValidToken;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
          future: _checkToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data == true) {
              return const DashboardPage();
            } else {
              return const LoginPage();
            }
          }),
    );
  }
}

// class MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     _checkTokenAndNavigate();
//   }

//   Future<void> _checkTokenAndNavigate() async {
//     final token = await AuthService.getToken();

//     if (token != null) {
//       final isValidToken = await AuthService.checkToken(token);
//       if (isValidToken) {
//         if (!mounted) return;
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => const DashboardPage()));
//       } else {
//         if (!mounted) return;
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => const LoginPage()));
//       }
//     } else {
//       if (!mounted) return;
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => const LoginPage()));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Ikan'),
//         ),
//       ),
//     );
//   }
// }
