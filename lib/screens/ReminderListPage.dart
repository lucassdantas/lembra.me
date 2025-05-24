import 'package:flutter/material.dart';
import 'package:lembra_me/models/Reminder.dart';
import 'package:lembra_me/screens/ReminderFormPage.dart';
import 'package:lembra_me/services/NotificationService.dart';

class ReminderListPage extends StatefulWidget {
  const ReminderListPage({super.key});
  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  final List<Reminder> _reminders = [];

  void _addReminder() async {
    final newReminder = await Navigator.push<Reminder>(
      context,
      MaterialPageRoute(builder: (_) => const ReminderFormPage()),
    );
    if (newReminder != null) {
      setState(() => _reminders.add(newReminder));
      await NotificationService().schedule(newReminder, context);
    }
  }

  void _deleteReminder(Reminder reminder) {
    setState(() => _reminders.remove(reminder));
    NotificationService().cancel(reminder.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lembretes')),
      body: ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (_, i) {
          final r = _reminders[i];
          return ListTile(
            title: Text(r.title),
            subtitle: Text('${r.description}\n${r.formattedDate}'),
            isThreeLine: true,
            trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteReminder(r)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addReminder, child: const Icon(Icons.add)),
    );
  }
}
