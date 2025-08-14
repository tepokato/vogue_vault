import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/appointment.dart';
import '../models/service_type.dart';
import '../services/appointment_service.dart';
import '../utils/service_type_utils.dart';

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
  late final TextEditingController _guestNameController;
  late final TextEditingController _guestContactController;

  @override
  void initState() {
    super.initState();
    _service =
        widget.appointment?.service ?? widget.initialService ?? ServiceType.barber;
    _dateTime = widget.appointment?.dateTime ?? DateTime.now();
    _selectedClientId = widget.appointment?.clientId;
    _selectedProviderId = widget.appointment?.providerId ?? widget.initialProviderId;
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
    final clients = service.clients;
    final providers = service.providersFor(_service);
    if (_selectedClientId != null &&
        !clients.any((c) => c.id == _selectedClientId)) {
      _selectedClientId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.selectedClientRemoved),
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
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.selectedProviderRemoved),
          ),
        );
      });
    }
    final isEditing = widget.appointment != null;

    if (providers.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing
              ? AppLocalizations.of(context)!.editAppointmentTitle
              : AppLocalizations.of(context)!.newAppointmentTitle),
        ),
        body: Center(
          child: Text(AppLocalizations.of(context)!.noProvidersAvailableAdd),
        ),
      );
    }

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
              if (clients.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedClientId,
                  hint: Text(AppLocalizations.of(context)!.selectClientHint),
                  items: clients
                      .map(
                        (c) => DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedClientId = value),
                  validator: (_) {
                    if ((_selectedClientId == null || _selectedClientId!.isEmpty) &&
                        _guestNameController.text.isEmpty) {
                      return AppLocalizations.of(context)!
                          .clientOrGuestValidation;
                    }
                    return null;
                  },
                ),
              TextFormField(
                controller: _guestNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.guestNameLabel,
                ),
                validator: (value) {
                  if ((_selectedClientId == null || _selectedClientId!.isEmpty) &&
                      (value == null || value.isEmpty)) {
                    return AppLocalizations.of(context)!
                        .clientOrGuestValidation;
                  }
                  return null;
                },
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
                        child: Text(serviceTypeLabel(s)),
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
                validator: (value) => value == null
                    ? AppLocalizations.of(context)!.selectServiceValidation
                    : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedProviderId,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.providerLabel),
                items: providers
                    .map(
                      (p) => DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(p.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedProviderId = value),
                validator: (value) => value == null
                    ? AppLocalizations.of(context)!.selectProviderValidation
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(DateFormat.yMMMd().add_jm().format(_dateTime.toLocal())),
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
                  final id = widget.appointment?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString();
                  final newAppt = Appointment(
                    id: id,
                    clientId: _selectedClientId,
                    guestName:
                        _selectedClientId == null || _selectedClientId!.isEmpty
                            ? _guestNameController.text
                            : null,
                    guestContact:
                        _selectedClientId == null || _selectedClientId!.isEmpty
                            ? _guestContactController.text
                            : null,
                    providerId: _selectedProviderId!,
                    service: _service,
                    dateTime: _dateTime,
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
