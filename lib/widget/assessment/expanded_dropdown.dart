import 'package:flutter/material.dart';

class ExpandedDropdown<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? selectedItem;
  final String? Function(T?)? itemLabel;
  final String? Function(T?)? itemSubLabel;
  final String? errorText;
  final Function(T?)? onChanged;

  const ExpandedDropdown({
    super.key,
    required this.label,
    required this.items,
    this.selectedItem,
    this.itemLabel,
    this.itemSubLabel,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      isDense: false,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: errorText,
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      value: selectedItem,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (itemSubLabel != null)
                Text(
                  itemSubLabel != null
                      ? itemSubLabel!(item) ?? ''
                      : item.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              Text(
                itemLabel != null ? itemLabel!(item) ?? '' : item.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              )
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
