import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/appointment.dart';
import '../models/service_type.dart';
import '../services/appointment_service.dart';
import '../utils/service_type_utils.dart';

class EditAppointmentPage extends StatefulWidget {
  final Appointment? appointment;
  final ServiceType? initialService;
  const EditAppointmentPage({super.key, this.appointment, this.initialService});

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  late ServiceType _service;
  DateTime _dateTime = DateTime.now();
  late Duration _duration;
  late final TextEditingController _guestNameController;
  late final TextEditingController _guestContactController;

  @override
  void initState() {
    super.initState();
    _service =
        widget.appointment?.service ?? widget.initialService ?? ServiceType.barber;
    _dateTime = widget.appointment?.dateTime ?? DateTime.now();
    _duration = widget.appointment?.duration ?? const Duration(hours: 1);
    _guestNameController =
        TextEditingController(text: widget.appointment?.guestName ?? '');
    _guestContactController =
        TextEditingController(text: widget.appointment?.guestContact ?? '');
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final locale = Localizations.localeOf(context).toString();
    final isEditing = widget.appointment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? AppLocalizations.of(context)!.editAppointmentTitle
            : AppLocalizations.of(context)!.newAppointmentTitle),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _guestNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.guestNameLabel,
                ),
                validator: (value) => value == null || value.isEmpty
                    ? AppLocalizations.of(context)!.nameRequired
                    : null,
              ),
              TextFormField(
                controller: _guestContactController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.guestContactLabel,
                ),
              ),
              DropdownButtonFormField<ServiceType>(
                value: _service,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.serviceLabel),
                items: ServiceType.values
                    .map(
                      (s) => DropdownMenuItem<ServiceType>(
                        value: s,
                        child: Text(serviceTypeLabel(context, s)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _service = value;
                  });
                },
                validator: (value) => value == null
                    ? AppLocalizations.of(context)!.selectServiceValidation
                    : null,
              ),
              DropdownButtonFormField<int>(
                value: _duration.inMinutes,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                items: List.generate(8, (i) => (i + 1) * 15)
                    .map((m) => DropdownMenuItem<int>(
                          value: m,
                          child: Text('$m'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _duration = Duration(minutes: value);
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(DateFormat.yMMMd(locale).add_jm().format(_dateTime.toLocal())),
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
                    child: Text(
                        AppLocalizations.of(context)!.selectDateButton),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final id =
                      widget.appointment?.id ?? const Uuid().v4();
                  final newAppt = Appointment(
                    id: id,
                    clientId: widget.appointment?.clientId,
                    guestName: _guestNameController.text,
                    guestContact: _guestContactController.text,
                    providerId: widget.appointment?.providerId,
                    service: _service,
                    dateTime: _dateTime,
                    duration: _duration,
                  );
                  if (isEditing) {
                    await service.updateAppointment(newAppt);
                  } else {
                    await service.addAppointment(newAppt);
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
