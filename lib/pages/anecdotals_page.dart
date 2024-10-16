import 'package:asesmen_paud/api/payload/anecdotal_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/anecdotal_service.dart';
import 'package:asesmen_paud/widget/anecdotal_list.dart';
import 'package:asesmen_paud/widget/search_field.dart';
import 'package:flutter/material.dart';

class AnecdotalsPage extends StatefulWidget {
  const AnecdotalsPage({super.key});

  @override
  AnecdotalsPageState createState() => AnecdotalsPageState();
}

class AnecdotalsPageState extends State<AnecdotalsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final int studentId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anekdot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchField(controller: _searchController),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: FutureBuilder<SuccessResponse<PaginateAnecdotalsPayload>>(
                future: AnecdotalService().getAllStudentAnecdotals(studentId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    final anecdotals = snapshot.data!.payload!.data;
                    return AnecdotalList(
                        anecdotals: anecdotals, onAnecdotalTap: (anecdot) {});
                  } else {
                    return const Center(
                      child: Text('No anecdot'),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
