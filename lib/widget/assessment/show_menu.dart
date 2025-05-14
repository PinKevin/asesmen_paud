import 'package:flutter/material.dart';

class ShowMenu<T> extends StatelessWidget {
  final T item;
  final Function(BuildContext) onEdit;
  final Function(BuildContext) onDelete;

  const ShowMenu({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => onDelete(context),
          label: const Text(
            'Hapus Data',
            style: TextStyle(color: Colors.red),
          ),
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        ),
        ElevatedButton.icon(
          onPressed: () => onEdit(context),
          label: const Text(
            'Ubah Data',
            style: TextStyle(color: Colors.blue),
          ),
          icon: const Icon(
            Icons.edit,
            color: Colors.blue,
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        ),
      ],
    );
  }
}
