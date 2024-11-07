import 'package:flutter/material.dart';

class SortButton extends StatelessWidget {
  final String label;
  final String sortOrder;

  final Function(String newSortOrder) onSortChanged;

  const SortButton(
      {super.key,
      required this.label,
      required this.sortOrder,
      required this.onSortChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          final newSortOrder = sortOrder == 'asc' ? 'desc' : 'asc';
          onSortChanged(newSortOrder);
        },
        child: Row(children: [
          Text(label),
          Icon(sortOrder == 'asc' ? Icons.arrow_drop_up : Icons.arrow_drop_down)
        ]));
  }
}
