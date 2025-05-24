import 'package:flutter/material.dart';
import 'package:lembra_me/models/Reminder.dart';
import 'package:lembra_me/utils/DateUtils.dart';

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
                title: Text('Data e Hora: ${DateUtilsHelper.formatDateTime(_dateTime)}'),
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
