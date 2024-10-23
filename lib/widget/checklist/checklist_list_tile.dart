import 'package:asesmen_paud/api/payload/checklist_payload.dart';
import 'package:asesmen_paud/helper/datetime_converter.dart';
import 'package:flutter/material.dart';

class ChecklistListTile extends StatelessWidget {
  final Checklist checklist;
  final Function(Checklist) onChecklistTap;

  const ChecklistListTile(
      {super.key, required this.checklist, required this.onChecklistTap});

  @override
  Widget build(BuildContext context) {
    String formattedCreateDate = formatDate(checklist.createdAt!);
    String formattedUpdateDate = formatDate(checklist.updatedAt!);

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              backgroundColor: Colors.deepPurple[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              )),
          onPressed: () => onChecklistTap(checklist),
          child: Card(
            margin: EdgeInsets.zero,
            color: Colors.transparent,
            elevation: 0,
            child: ListTile(
              title: Text(formattedCreateDate),
              subtitle: Text(
                'Terakhir diubah: $formattedUpdateDate',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_right_outlined),
            ),
          ),
        ));
  }
}
