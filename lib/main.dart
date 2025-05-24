import 'package:flutter/material.dart';
import 'package:lembra_me/screens/ReminderListPage.dart';
import 'package:lembra_me/services/NotificationService.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lembra-me',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const ReminderListPage(),
    );
  }
}
