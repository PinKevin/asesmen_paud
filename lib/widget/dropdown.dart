import 'package:flutter/material.dart';

class Dropdown<T> extends StatelessWidget {
  final String labelText;
  final T? value;
  final List<T> options;
  final String Function(T) displayText;
  final ValueChanged<T?>? onChanged;

  const Dropdown(
      {super.key,
      required this.labelText,
      required this.value,
      required this.onChanged,
      required this.options,
      required this.displayText});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        value: value,
        items: options.map((option) {
          return DropdownMenuItem<T>(
              value: option,
              child: Text(
                displayText(option),
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ));
        }).toList(),
        onChanged: onChanged);
  }
}
