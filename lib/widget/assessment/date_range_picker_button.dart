import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePickerButton extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final void Function(DateTimeRange?) onDateRangeSelected;

  const DateRangePickerButton({
    super.key,
    this.selectedDateRange,
    required this.onDateRangeSelected,
  });

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 7),
      lastDate: DateTime.now(),
    );

    onDateRangeSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    late String startDate, endDate;
    if (selectedDateRange != null) {
      startDate = DateFormat('dd-MM-yyyy').format(selectedDateRange!.start);
      endDate = DateFormat('dd-MM-yyyy').format(selectedDateRange!.end);
    }

    return ElevatedButton(
      onPressed: () => _selectDateRange(context),
      child: Text(
        selectedDateRange == null
            ? 'Pilih rentang tanggal'
            : 'Rentang $startDate hingga $endDate',
      ),
    );
  }
}
