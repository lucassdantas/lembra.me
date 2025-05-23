import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

class Reminder {
  final int id;
  String title;
  String description;
  DateTime dateTime;

  Reminder({required this.id, required this.title, required this.description, required this.dateTime});
}

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
            subtitle: Text('${r.description}\n${r.dateTime}'),
            isThreeLine: true,
            trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteReminder(r)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addReminder, child: const Icon(Icons.add)),
    );
  }
}

class ReminderFormPage extends StatefulWidget {
  const ReminderFormPage({super.key});
  @override
  State<ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends State<ReminderFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _dateTime = DateTime.now().add(const Duration(minutes: 1));

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
    if (time == null) return;

    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_dateTime.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('A data/hora deve ser no futuro')));
        return;
      }

      final reminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: _title,
        description: _description,
        dateTime: _dateTime,
      );
      Navigator.pop(context, reminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Lembrete')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value!.isEmpty ? 'Informe o título' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) => value!.isEmpty ? 'Informe a descrição' : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Data e Hora: ${_dateTime.toString()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Salvar Lembrete')),
            ],
          ),
        ),
      ),
    );
  }
}
