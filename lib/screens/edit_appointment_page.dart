import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../models/service_type.dart';
import '../services/appointment_service.dart';

class EditAppointmentPage extends StatefulWidget {
  final Appointment? appointment;
  final ServiceType? initialService;
  final String? initialProviderId;

  const EditAppointmentPage(
      {super.key, this.appointment, this.initialService, this.initialProviderId});

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  late ServiceType _service;
  DateTime _dateTime = DateTime.now();
  String? _selectedClientId;
  String? _selectedProviderId;

  @override
  void initState() {
    super.initState();
    _service =
        widget.appointment?.service ?? widget.initialService ?? ServiceType.barber;
    _dateTime = widget.appointment?.dateTime ?? DateTime.now();
    _selectedClientId = widget.appointment?.clientId;
    _selectedProviderId = widget.appointment?.providerId ?? widget.initialProviderId;
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final clients = service.clients;
    final providers = service.providersFor(_service);
    if (_selectedClientId != null &&
        !clients.any((c) => c.id == _selectedClientId)) {
      _selectedClientId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Previously selected client was removed. Please choose another.'),
          ),
        );
      });
    }
    if (_selectedProviderId != null &&
        !providers.any((p) => p.id == _selectedProviderId)) {
      _selectedProviderId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Previously selected provider was removed or unavailable. Please choose another.'),
          ),
        );
      });
    }
    final isEditing = widget.appointment != null;

    if (clients.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Appointment' : 'New Appointment'),
        ),
        body: const Center(
          child: Text('No clients available. Please add a client first.'),
        ),
      );
    }

    if (providers.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Appointment' : 'New Appointment'),
        ),
        body: const Center(
          child: Text('No providers available. Please add a provider first.'),
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
                onChanged: (value) {
                  if (value == null) return;
                  final availableProviders =
                      context.read<AppointmentService>().providersFor(value);
                  setState(() {
                    _service = value;
                    if (_selectedProviderId != null &&
                        !availableProviders
                            .any((p) => p.id == _selectedProviderId)) {
                      _selectedProviderId = null;
                    }
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a service' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedProviderId,
                decoration: const InputDecoration(labelText: 'Provider'),
                items: providers
                    .map(
                      (p) => DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(p.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedProviderId = value),
                validator: (value) =>
                    value == null ? 'Please select a provider' : null,
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
                    providerId: _selectedProviderId!,
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
