import 'package:asesmen_paud/widget/button/submit_secondary_button.dart';
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
        SubmitSecondaryButton(
          text: 'Ubah Data',
          onPressed: () => onEdit(context),
          textColor: Colors.blue,
          icon: Icons.edit,
          iconColor: Colors.blue,
        ),
        SubmitSecondaryButton(
          text: 'Hapus Data',
          onPressed: () => onDelete(context),
          textColor: Colors.red,
          icon: Icons.delete,
          iconColor: Colors.red,
        ),
      ],
    );
  }
}
