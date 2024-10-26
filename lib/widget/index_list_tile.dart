import 'package:flutter/material.dart';

class IndexListTile<T> extends StatelessWidget {
  final T item;
  final String Function(T) getCreateDate;
  final String Function(T) getUpdateDate;
  final Function(T) onTap;

  const IndexListTile(
      {super.key,
      required this.item,
      required this.getCreateDate,
      required this.getUpdateDate,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    String formattedCreateDate = getCreateDate(item);
    String formattedUpdateDate = getUpdateDate(item);

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              backgroundColor: Colors.deepPurple[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              )),
          onPressed: () => onTap(item),
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
