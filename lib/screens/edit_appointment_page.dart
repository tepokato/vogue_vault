import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../models/service_type.dart';
import '../models/user_role.dart';
import '../services/appointment_service.dart';
import '../services/role_provider.dart';

class EditAppointmentPage extends StatefulWidget {
  final Appointment? appointment;

  const EditAppointmentPage({super.key, this.appointment});

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  late ServiceType _service;
  DateTime _dateTime = DateTime.now();
  String? _selectedClientId;

  @override
  void initState() {
    super.initState();
    _service = widget.appointment?.service ?? ServiceType.barber;
    _dateTime = widget.appointment?.dateTime ?? DateTime.now();
    _selectedClientId = widget.appointment?.clientId;
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>().selectedRole;
    final service = context.watch<AppointmentService>();
    final clients = service.clients;
    if (_selectedClientId != null &&
        !clients.any((c) => c.id == _selectedClientId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedClientId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Previously selected client was removed. Please choose another.'),
          ),
        );
      });
    }
    final isEditing = widget.appointment != null;

    if (role != UserRole.professional) {
      return const Scaffold(
        body: Center(
          child: Text('Available only for professionals'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Appointment' : 'New Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedClientId,
                hint: const Text('Select Client'),
                items: clients
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedClientId = value),
                validator: (value) =>
                    value == null ? 'Please select a client' : null,
              ),
              DropdownButtonFormField<ServiceType>(
                value: _service,
                decoration: const InputDecoration(labelText: 'Service'),
                items: ServiceType.values
                    .map(
                      (s) => DropdownMenuItem<ServiceType>(
                        value: s,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _service = value!),
                validator: (value) =>
                    value == null ? 'Please select a service' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(_dateTime.toLocal().toString()),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date == null) return;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_dateTime),
                      );
                      if (time == null) return;
                      setState(() {
                        _dateTime = DateTime(
                            date.year, date.month, date.day, time.hour, time.minute);
                      });
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  final id = widget.appointment?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString();
                  final newAppt = Appointment(
                    id: id,
                    clientId: _selectedClientId!,
                    service: _service,
                    dateTime: _dateTime,
                  );
                  if (isEditing) {
                    service.updateAppointment(newAppt);
                  } else {
                    service.addAppointment(newAppt);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
