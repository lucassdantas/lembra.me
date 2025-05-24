import 'package:lembra_me/utils/DateUtils.dart';

class Reminder {
  final int id;
  String title;
  String description;
  DateTime dateTime;

  Reminder({required this.id, required this.title, required this.description, required this.dateTime});

  String get formattedDate => DateUtilsHelper.formatDateTime(dateTime);
}
