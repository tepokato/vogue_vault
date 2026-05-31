import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../app/theme.dart';
import '../models/add_on.dart';
import '../models/appointment.dart';
import '../models/service_offering.dart';
import '../models/service_type.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../utils/service_type_utils.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/ui/ui.dart';

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
  ServiceOffering? _selectedOffering;
  bool _offeringSetupDone = false;

  @override
  void initState() {
    super.initState();
    _service = widget.appointment?.service ??
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_offeringSetupDone) return;
    final auth = context.read<AuthService>();
    final appointmentService = context.read<AppointmentService>();
    final offerings = auth.currentUser != null
        ? appointmentService.getUser(auth.currentUser!)?.offerings ??
            <ServiceOffering>[]
        : <ServiceOffering>[];
    if (offerings.isEmpty) {
      _offeringSetupDone = true;
      return;
    }
    if (widget.appointment != null) {
      final appt = widget.appointment!;
      ServiceOffering? match;
      for (final o in offerings) {
        if (o.type == appt.service) {
          match = o;
          break;
        }
      }
      final pick = match ?? offerings.first;
      setState(() {
        _selectedOffering = pick;
        _service = pick.type;
        _serviceName = pick.name;
      });
    }
    _offeringSetupDone = true;
  }

  @override
  void dispose() {
    _guestController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null) return;
    setState(() {
      _dateTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _showAddOnDialog({AddOn? addOn, int? index}) async {
    final nameController = TextEditingController(text: addOn?.name ?? '');
    final priceController =
        TextEditingController(text: addOn?.price.toStringAsFixed(2) ?? '');
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<AddOn>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(addOn == null ? l10n.addAddOnTitle : l10n.editAddOnTitle),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.addOnNameLabel),
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.addOnNameValidation
                    : null,
              ),
              const SizedBox(height: AppTokens.spaceMd),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: l10n.addOnPriceLabel),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.addOnPriceValidation;
                  final parsed = double.tryParse(v);
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
          FilledButton(
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
      ),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final service = context.read<AppointmentService>();
    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.appointment != null;
    final id = widget.appointment?.id ?? const Uuid().v4();
    final newAppt = Appointment(
      id: id,
      providerId: widget.appointment?.providerId ?? auth.currentUser,
      customerId: _customerId,
      guestName: _guestController.text.isEmpty ? null : _guestController.text,
      location:
          _locationController.text.isEmpty ? null : _locationController.text,
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
        await service.updateAppointment(newAppt,
            context: context, serviceName: _serviceName);
      } else {
        await service.addAppointment(newAppt,
            context: context, serviceName: _serviceName);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appointmentConflict)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = context.watch<AppointmentService>();
    final auth = context.watch<AuthService>();
    final locale = Localizations.localeOf(context).toString();
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.appointment != null;
    final offerings = auth.currentUser != null
        ? service.getUser(auth.currentUser!)?.offerings ?? <ServiceOffering>[]
        : <ServiceOffering>[];
    final currency = NumberFormat.simpleCurrency(locale: locale);
    final basePrice = double.tryParse(_priceController.text);
    final addOnTotal = _addOns.fold<double>(0, (sum, a) => sum + a.price);
    final totalPrice =
        basePrice == null && addOnTotal == 0 ? null : (basePrice ?? 0) + addOnTotal;

    return AppScaffold(
      title: isEditing ? l10n.editAppointmentTitle : l10n.newAppointmentTitle,
      showProfileButton: false,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppTokens.space,
            AppTokens.spaceSm,
            AppTokens.space,
            AppTokens.spaceLg + MediaQuery.of(context).viewInsets.bottom,
          ),
          children: [
            // --- Service ---
            _Section(
              title: l10n.serviceLabel,
              children: [
                if (offerings.isNotEmpty)
                  DropdownButtonFormField<ServiceOffering>(
                    key: const ValueKey('offeringDropdown'),
                    value: _selectedOffering,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.serviceLabel,
                      hintText: l10n.selectCatalogServiceHint,
                    ),
                    items: offerings
                        .map(
                          (o) => DropdownMenuItem<ServiceOffering>(
                            value: o,
                            child: Text(
                              '${serviceTypeLabel(context, o.type)} · ${o.name} (${currency.format(o.price)})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedOffering = value;
                        _service = value.type;
                        _priceController.text = value.price.toStringAsFixed(2);
                        _serviceName = value.name;
                      });
                    },
                    validator: (value) =>
                        value == null ? l10n.selectServiceValidation : null,
                  )
                else
                  DropdownButtonFormField<ServiceType>(
                    key: const ValueKey('serviceDropdown'),
                    value: _service,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.serviceLabel),
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
                  ),
                const SizedBox(height: AppTokens.spaceMd),
                TextFormField(
                  key: const ValueKey('priceField'),
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: l10n.priceLabel,
                    hintText: l10n.priceExampleHint,
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    return double.tryParse(value) == null
                        ? l10n.invalidPrice
                        : null;
                  },
                ),
                if (totalPrice != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppTokens.spaceSm),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.totalWithAddOnsLabel(currency.format(totalPrice)),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppTokens.spaceMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.addOnsLabel, style: theme.textTheme.titleSmall),
                    TextButton.icon(
                      onPressed: () => _showAddOnDialog(),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addAddOnButton),
                    ),
                  ],
                ),
                if (_addOns.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.addOnsEmptyState,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ..._addOns.asMap().entries.map((entry) {
                    final index = entry.key;
                    final addOn = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(top: AppTokens.spaceSm),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                          borderRadius: AppTokens.fieldRadius,
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(addOn.name)),
                            Text(currency.format(addOn.price)),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              tooltip: l10n.editAddOnTooltip,
                              onPressed: () =>
                                  _showAddOnDialog(addOn: addOn, index: index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              tooltip: l10n.deleteAddOnTooltip,
                              onPressed: () =>
                                  setState(() => _addOns.removeAt(index)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
            const SizedBox(height: AppTokens.space),
            // --- When ---
            _Section(
              title: l10n.appointmentTimeFilterLabel,
              children: [
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: AppTokens.fieldRadius,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.selectDateButton,
                      prefixIcon: const Icon(Icons.event),
                    ),
                    child: Text(
                      DateFormat.yMMMEd(locale)
                          .add_jm()
                          .format(_dateTime.toLocal()),
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                DropdownButtonFormField<int>(
                  value: _duration.inMinutes,
                  decoration:
                      InputDecoration(labelText: l10n.durationMinutesLabel),
                  items: List.generate(8, (i) => (i + 1) * 15)
                      .map((m) =>
                          DropdownMenuItem<int>(value: m, child: Text('$m')))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _duration = Duration(minutes: value));
                  },
                ),
                const SizedBox(height: AppTokens.spaceMd),
                DropdownButtonFormField<int>(
                  value: _bufferDuration.inMinutes,
                  decoration: InputDecoration(labelText: l10n.bufferTimeLabel),
                  items: const [0, 10, 15, 30, 45, 60]
                      .map((m) =>
                          DropdownMenuItem<int>(value: m, child: Text('$m')))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _bufferDuration = Duration(minutes: value));
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space),
            // --- Who & where ---
            _Section(
              title: l10n.customerLabel,
              children: [
                DropdownButtonFormField<String>(
                  value: _customerId,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.customerLabel),
                  items: service.customers
                      .map((c) => DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.fullName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _customerId = value;
                      if (value != null) _guestController.clear();
                    });
                  },
                ),
                const SizedBox(height: AppTokens.spaceMd),
                TextFormField(
                  controller: _guestController,
                  decoration: InputDecoration(
                    labelText: l10n.guestNameLabel,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (_) {
                    if ((_customerId == null || _customerId!.isEmpty) &&
                        _guestController.text.isEmpty) {
                      return l10n.guestOrCustomerValidation;
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() => _customerId = null),
                ),
                const SizedBox(height: AppTokens.spaceMd),
                DropdownButtonFormField<String>(
                  value: _addressId,
                  isExpanded: true,
                  decoration:
                      InputDecoration(labelText: l10n.savedAddressLabel),
                  items: service.addresses
                      .map((a) => DropdownMenuItem<String>(
                            value: a.id,
                            child: Text(a.label),
                          ))
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
                const SizedBox(height: AppTokens.spaceMd),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: l10n.locationLabel,
                    prefixIcon: const Icon(Icons.place_outlined),
                  ),
                  onChanged: (_) => setState(() => _addressId = null),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceLg),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.saveButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.spaceMd),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...children,
        ],
      ),
    );
  }
}
