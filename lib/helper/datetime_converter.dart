import 'package:intl/intl.dart';

String formatDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString).toLocal();
  final DateFormat formatter = DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id_ID');
  return formatter.format(dateTime);
}
