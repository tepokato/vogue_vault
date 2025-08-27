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
  String? _customerId;
  final _guestController = TextEditingController();
  final _locationController = TextEditingController();
  String? _addressId;

  @override
  void initState() {
    super.initState();
    _service = widget.appointment?.service ??
        widget.initialService ??
        ServiceType.barber;
    _dateTime = widget.appointment?.dateTime ?? DateTime.now();
    _duration = widget.appointment?.duration ?? const Duration(hours: 1);
    _customerId = widget.appointment?.customerId;
    _guestController.text = widget.appointment?.guestName ?? '';
    _locationController.text = widget.appointment?.location ?? '';
    _addressId = null;
  }

  @override
  void dispose() {
    _guestController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final locale = Localizations.localeOf(context).toString();
    final isEditing = widget.appointment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? AppLocalizations.of(context)!.editAppointmentTitle
              : AppLocalizations.of(context)!.newAppointmentTitle,
        ),
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
              DropdownButtonFormField<ServiceType>(
                value: _service,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.serviceLabel,
                ),
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.durationMinutesLabel,
                ),
                items: List.generate(8, (i) => (i + 1) * 15)
                    .map(
                      (m) => DropdownMenuItem<int>(value: m, child: Text('$m')),
                    )
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
                  Text(
                    DateFormat.yMMMd(
                      locale,
                    ).add_jm().format(_dateTime.toLocal()),
                  ),
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
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    },
                    child: Text(AppLocalizations.of(context)!.selectDateButton),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _customerId,
                decoration: const InputDecoration(labelText: 'Customer'),
                items: service.customers
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.fullName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _customerId = value;
                    if (value != null) {
                      _guestController.clear();
                    }
                  });
                },
              ),
              TextFormField(
                controller: _guestController,
                decoration: const InputDecoration(labelText: 'Guest name'),
                onChanged: (_) {
                  setState(() {
                    _customerId = null;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _addressId,
                decoration: const InputDecoration(labelText: 'Saved address'),
                items: service.addresses
                    .map(
                      (a) => DropdownMenuItem<String>(
                        value: a.id,
                        child: Text(a.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _addressId = value;
                    if (value != null) {
                      final addr =
                          service.addresses.firstWhere((a) => a.id == value);
                      _locationController.text = addr.details;
                    }
                  });
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                onChanged: (_) {
                  setState(() {
                    _addressId = null;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final id = widget.appointment?.id ?? const Uuid().v4();
                  final newAppt = Appointment(
                    id: id,
                    providerId: widget.appointment?.providerId,
                    customerId: _customerId,
                    guestName:
                        _guestController.text.isEmpty ? null : _guestController.text,
                    location: _locationController.text.isEmpty
                        ? null
                        : _locationController.text,
                    service: _service,
                    dateTime: _dateTime,
                    duration: _duration,
                  );
                  try {
                    if (isEditing) {
                      await service.updateAppointment(newAppt);
                    } else {
                      await service.addAppointment(newAppt);
                    }
                    if (!mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.appointmentConflict,
                        ),
                      ),
                    );
                  }
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
