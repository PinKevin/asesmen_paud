import 'package:asesmen_paud/api/dto/checklist_dto.dart';
import 'package:flutter/material.dart';

class ChecklistPointItem extends StatelessWidget {
  final ChecklistPointDto checklistPoint;
  final VoidCallback onPressed;
  final VoidCallback onDelete;

  const ChecklistPointItem({
    super.key,
    required this.checklistPoint,
    required this.onPressed,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(0),
            backgroundColor: Colors.deepPurple[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            )),
        onPressed: onPressed,
        child: Card(
          margin: EdgeInsets.zero,
          color: Colors.transparent,
          elevation: 0,
          child: ListTile(
            title: Text(
              checklistPoint.context,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              checklistPoint.hasAppeared == true
                  ? 'Sudah muncul'
                  : 'Belum muncul',
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Hapus'),
                  ),
                ];
              },
            ),
          ),
        ),
      ),
    );
  }
}
