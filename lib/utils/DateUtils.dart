import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy - HH:mm').format(dateTime);
  }
}
