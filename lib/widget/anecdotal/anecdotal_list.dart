import 'package:asesmen_paud/api/payload/anecdotal_payload.dart';
import 'package:asesmen_paud/helper/datetime_converter.dart';
import 'package:flutter/material.dart';

class AnecdotalList extends StatelessWidget {
  final List<AnecdotalPayload> anecdotals;
  final Function(AnecdotalPayload) onAnecdotalTap;

  const AnecdotalList(
      {super.key, required this.anecdotals, required this.onAnecdotalTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
                itemCount: anecdotals.length,
                itemBuilder: (context, index) {
                  final anecdot = anecdotals[index];
                  String formattedDate = formatDate(anecdot.createdAt!);

                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            backgroundColor: Colors.deepPurple[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                        onPressed: () => onAnecdotalTap(anecdot),
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Colors.transparent,
                          elevation: 0,
                          child: ListTile(
                            title: Text(formattedDate),
                            // subtitle: Text('NISN: ${anecdot.nisn}'),
                            trailing: const Icon(Icons.arrow_right_outlined),
                          ),
                        ),
                      ));
                }))
      ],
    );
  }
}
