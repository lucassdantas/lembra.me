import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lembra_me/models/Reminder.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);
  }

  Future<void> schedule(Reminder reminder, BuildContext context) async {
    final tzDateTime = tz.TZDateTime.from(reminder.dateTime, tz.local);

    try {
      await _plugin.zonedSchedule(
        reminder.id,
        reminder.title,
        reminder.description,
        tz.TZDateTime.from(reminder.dateTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'lembretes_channel',
            'Lembretes',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    } catch (e) {
      debugPrint('Erro ao agendar notificação: $e');
      if (e.toString().contains('exact_alarms_not_permitted')) {
        // Mostra mensagem pro usuário
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de alarme exato não concedida. Habilite nas configurações.'),
          ),
        );
        // Opcional: abrir configurações do sistema
      }
    }
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
