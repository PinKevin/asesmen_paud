import 'package:flutter/material.dart';

class DateRangePickerButton extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final void Function(DateTimeRange?) onDateRangeSelected;

  const DateRangePickerButton(
      {super.key, this.selectedDateRange, required this.onDateRangeSelected});

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2024, 7),
        lastDate: DateTime.now());

    onDateRangeSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final startDate =
        selectedDateRange?.start.toIso8601String().substring(0, 10) ?? '';
    final endDate =
        selectedDateRange?.end.toIso8601String().substring(0, 10) ?? '';

    return ElevatedButton(
        onPressed: () => _selectDateRange(context),
        child: Text(selectedDateRange == null
            ? 'Pilih rentang tanggal'
            : 'Rentang $startDate hingga $endDate'));
  }
}
