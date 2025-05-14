import 'package:asesmen_paud/widget/assessment/expanded_text_field.dart';
import 'package:flutter/material.dart';

class DatePickerTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? errorText;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime) onDateSelected;

  const DatePickerTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.errorText,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: AbsorbPointer(
        child: ExpandedTextField(
          controller: controller,
          labelText: labelText,
          errorText: errorText,
        ),
      ),
    );
  }
}
