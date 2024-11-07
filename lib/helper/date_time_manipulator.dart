import 'package:intl/intl.dart';

class DateTimeManipulator {
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString).toLocal();
    final DateFormat formatter =
        DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id_ID');
    return formatter.format(dateTime);
  }

  String getWordMonthFromDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString).toLocal();

    final DateFormat formatter = DateFormat('MMMM', 'id_ID');
    return formatter.format(dateTime);
  }

  int getYearFromDate(String dateString) {
    int year = DateTime.parse(dateString).year;
    return year;
  }
}
