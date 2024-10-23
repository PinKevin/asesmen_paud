import 'package:asesmen_paud/api/service/auth_service.dart';
import 'package:asesmen_paud/pages/anecdotals/anecdotals_page.dart';
import 'package:asesmen_paud/pages/anecdotals/create_anecdotal_page.dart';
import 'package:asesmen_paud/pages/artworks/artworks_page.dart';
import 'package:asesmen_paud/pages/artworks/create_artwork_page.dart';
import 'package:asesmen_paud/pages/checklists/checklists_page.dart';
import 'package:asesmen_paud/pages/dashboard_page.dart';
import 'package:asesmen_paud/pages/login_page.dart';
import 'package:asesmen_paud/pages/students_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await initializeDateFormatting('id_ID', null);

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
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
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
        '/dashboard': (context) => const DashboardPage(),
        '/login': (context) => const LoginPage(),
        '/students': (context) => const StudentsPage(),
        '/anecdotals': (context) => const AnecdotalsPage(),
        '/create-anecdotal': (context) => const CreateAnecdotalPage(),
        '/artworks': (context) => const ArtworksPage(),
        '/create-artwork': (context) => const CreateArtworkPage(),
        '/checklists': (context) => const ChecklistsPage(),
      },
    );
  }
}
