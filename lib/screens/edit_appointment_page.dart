import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/add_on.dart';
import '../models/appointment.dart';
import '../models/service_offering.dart';
import '../models/service_type.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../utils/service_type_utils.dart';
import '../widgets/app_scaffold.dart';

class EditAppointmentPage extends StatefulWidget {
  final Appointment? appointment;
  final ServiceType? initialService;
  final DateTime? initialDate;
  const EditAppointmentPage({
    super.key,
    this.appointment,
    this.initialService,
    this.initialDate,
  });

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  late ServiceType _service;
  DateTime _dateTime = DateTime.now();
  late Duration _duration;
  late Duration _bufferDuration;
  String? _customerId;
  final _guestController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  String? _addressId;
  String? _serviceName;
  List<AddOn> _addOns = [];

  @override
  void initState() {
    super.initState();
    _service =
        widget.appointment?.service ??
        widget.initialService ??
        ServiceType.barber;
    _dateTime =
        widget.appointment?.dateTime ?? widget.initialDate ?? DateTime.now();
    _duration = widget.appointment?.duration ?? const Duration(hours: 1);
    _bufferDuration = widget.appointment?.bufferDuration ?? Duration.zero;
    _customerId = widget.appointment?.customerId;
    _guestController.text = widget.appointment?.guestName ?? '';
    _locationController.text = widget.appointment?.location ?? '';
    _priceController.text = widget.appointment?.price?.toStringAsFixed(2) ?? '';
    _addressId = null;
    _addOns = [...(widget.appointment?.addOns ?? const [])];
  }

  @override
  void dispose() {
    _guestController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _showAddOnDialog({AddOn? addOn, int? index}) async {
    final nameController = TextEditingController(text: addOn?.name ?? '');
    final priceController = TextEditingController(
      text: addOn?.price.toStringAsFixed(2) ?? '',
    );
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<AddOn>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            addOn == null ? l10n.addAddOnTitle : l10n.editAddOnTitle,
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.addOnNameLabel,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.addOnNameValidation;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: l10n.addOnPriceLabel,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.addOnPriceValidation;
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed < 0) {
                      return l10n.addOnPriceValidation;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancelButton),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(
                  context,
                  AddOn(
                    name: nameController.text.trim(),
                    price: double.parse(priceController.text),
                  ),
                );
              },
              child: Text(l10n.saveButton),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        if (index == null) {
          _addOns.add(result);
        } else {
          _addOns[index] = result;
        }
      });
    }

    nameController.dispose();
    priceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final auth = context.watch<AuthService>();
    final locale = Localizations.localeOf(context).toString();
    final localizations = AppLocalizations.of(context)!;
    final isEditing = widget.appointment != null;
    final offerings = auth.currentUser != null
        ? service.getUser(auth.currentUser!)?.offerings ?? <ServiceOffering>[]
        : <ServiceOffering>[];
    final currency = NumberFormat.simpleCurrency(locale: locale);
    final basePrice = double.tryParse(_priceController.text);
    final addOnTotal =
        _addOns.fold<double>(0, (sum, addOn) => sum + addOn.price);
    final totalPrice = basePrice == null && addOnTotal == 0
        ? null
        : (basePrice ?? 0) + addOnTotal;

    return AppScaffold(
      title: isEditing
          ? AppLocalizations.of(context)!.editAppointmentTitle
          : AppLocalizations.of(context)!.newAppointmentTitle,
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
              DropdownButtonFormField<ServiceOffering>(
                key: const ValueKey('offeringDropdown'),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.serviceLabel,
                ),
                items: offerings
                    .map(
                      (o) => DropdownMenuItem<ServiceOffering>(
                        value: o,
                        child: Text(
                          '${serviceTypeLabel(context, o.type)} - ${o.name} (\$${o.price.toStringAsFixed(2)})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _service = value.type;
                    _priceController.text = value.price.toStringAsFixed(2);
                    _serviceName = value.name;
                  });
                },
              ),
              DropdownButtonFormField<ServiceType>(
                key: const ValueKey('serviceDropdown'),
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
                    _serviceName = null;
                  });
                },
                validator: (value) => value == null
                    ? AppLocalizations.of(context)!.selectServiceValidation
                    : null,
              ),
              TextFormField(
                key: const ValueKey('priceField'),
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.priceLabel,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  return double.tryParse(value) == null
                      ? AppLocalizations.of(context)!.invalidPrice
                      : null;
                },
              ),
              if (totalPrice != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizations.totalWithAddOnsLabel(
                        currency.format(totalPrice),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.addOnsLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddOnDialog(),
                    icon: const Icon(Icons.add),
                    label: Text(localizations.addAddOnButton),
                  ),
                ],
              ),
              if (_addOns.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizations.addOnsEmptyState,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ..._addOns.asMap().entries.map((entry) {
                final index = entry.key;
                final addOn = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(addOn.name),
                    subtitle: Text(currency.format(addOn.price)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: localizations.editAddOnTooltip,
                          onPressed: () =>
                              _showAddOnDialog(addOn: addOn, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: localizations.deleteAddOnTooltip,
                          onPressed: () {
                            setState(() {
                              _addOns.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
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
              DropdownButtonFormField<int>(
                value: _bufferDuration.inMinutes,
                decoration: InputDecoration(
                  labelText: localizations.bufferTimeLabel,
                ),
                items: const [0, 10, 15, 30, 45, 60]
                    .map(
                      (m) => DropdownMenuItem<int>(value: m, child: Text('$m')),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _bufferDuration = Duration(minutes: value);
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
                decoration: InputDecoration(
                  labelText: localizations.customerLabel,
                ),
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
                decoration: InputDecoration(
                  labelText: localizations.guestNameLabel,
                ),
                validator: (_) {
                  if ((_customerId == null || _customerId!.isEmpty) &&
                      _guestController.text.isEmpty) {
                    return localizations.guestOrCustomerValidation;
                  }
                  return null;
                },
                onChanged: (_) {
                  setState(() {
                    _customerId = null;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _addressId,
                decoration: InputDecoration(
                  labelText: localizations.savedAddressLabel,
                ),
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
                      final addr = service.addresses.firstWhere(
                        (a) => a.id == value,
                      );
                      _locationController.text = addr.details;
                    }
                  });
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: localizations.locationLabel,
                ),
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
                    guestName: _guestController.text.isEmpty
                        ? null
                        : _guestController.text,
                    location: _locationController.text.isEmpty
                        ? null
                        : _locationController.text,
                    price: _priceController.text.isEmpty
                        ? null
                        : double.parse(_priceController.text),
                    service: _service,
                    addOns: _addOns,
                    dateTime: _dateTime,
                    duration: _duration,
                    bufferDuration: _bufferDuration,
                  );
                  try {
                    if (isEditing) {
                      await service.updateAppointment(
                        newAppt,
                        context: context,
                        serviceName: _serviceName,
                      );
                    } else {
                      await service.addAppointment(
                        newAppt,
                        context: context,
                        serviceName: _serviceName,
                      );
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
