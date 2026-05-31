import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../app/theme.dart';
import '../models/appointment.dart';
import '../models/service_type.dart';
import '../services/appointment_service.dart';
import '../utils/service_type_utils.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/appointment_tile.dart';
import '../widgets/ui/ui.dart';
import 'addresses_page.dart';
import 'edit_appointment_page.dart';

enum AppointmentTimeFilter { all, upcoming, past }

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  AppointmentTimeFilter _timeFilter = AppointmentTimeFilter.upcoming;
  ServiceType? _serviceFilter;
  final TextEditingController _searchController = TextEditingController();

  void _openNewAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditAppointmentPage()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesTime(Appointment appointment) {
    final now = DateTime.now();
    final ends = appointment.dateTime.add(appointment.duration);
    switch (_timeFilter) {
      case AppointmentTimeFilter.all:
        return true;
      case AppointmentTimeFilter.upcoming:
        return ends.isAfter(now);
      case AppointmentTimeFilter.past:
        return ends.isBefore(now);
    }
  }

  bool _matchesService(Appointment appointment) =>
      _serviceFilter == null || appointment.service == _serviceFilter;

  bool _matchesSearch(Appointment appointment, AppointmentService service) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return true;

    final providerName = appointment.providerId != null
        ? service.getUser(appointment.providerId!)?.name ?? ''
        : '';
    final customerName = appointment.customerId != null
        ? service.getCustomer(appointment.customerId!)?.fullName ?? ''
        : '';
    final guestName = appointment.guestName ?? '';
    final location = appointment.location ?? '';
    final serviceLabel = serviceTypeLabel(context, appointment.service);

    return [providerName, customerName, guestName, location, serviceLabel]
        .any((field) => field.toLowerCase().contains(query));
  }

  List<Appointment> _filtered(AppointmentService service) {
    return service.appointments
        .where((a) =>
            _matchesTime(a) && _matchesService(a) && _matchesSearch(a, service))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final l10n = AppLocalizations.of(context)!;
    final hasAny = service.appointments.isNotEmpty;

    return AppScaffold(
      title: l10n.appointmentsTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.place_outlined),
          tooltip: l10n.addressesTitle,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddressesPage()),
          ),
        ),
      ],
      body: !hasAny
          ? EmptyState(
              icon: Icons.event_note_outlined,
              title: l10n.noAppointmentsScheduled,
              message: l10n.appointmentsEmptyDescription,
              actionLabel: l10n.addFirstAppointment,
              onAction: _openNewAppointment,
            )
          : Column(
              children: [
                _Filters(
                  searchController: _searchController,
                  timeFilter: _timeFilter,
                  serviceFilter: _serviceFilter,
                  onSearchChanged: () => setState(() {}),
                  onTimeChanged: (f) => setState(() => _timeFilter = f),
                  onServiceChanged: (s) => setState(() => _serviceFilter = s),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final filtered = _filtered(service);
                      if (filtered.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppTokens.spaceLg),
                            child: Text(
                              l10n.noAppointmentsMatchFilters,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: AppTokens.spaceXl,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final appt = filtered[index];
                          return AppointmentTile(
                            appointment: appt,
                            showDate: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditAppointmentPage(appointment: appt),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: l10n.deleteAppointmentTooltip,
                              onPressed: () => _confirmDelete(appt, service),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _confirmDelete(
    Appointment appt,
    AppointmentService service,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAppointmentTitle),
        content: Text(l10n.deleteAppointmentConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await service.deleteAppointment(appt.id);
    }
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.searchController,
    required this.timeFilter,
    required this.serviceFilter,
    required this.onSearchChanged,
    required this.onTimeChanged,
    required this.onServiceChanged,
  });

  final TextEditingController searchController;
  final AppointmentTimeFilter timeFilter;
  final ServiceType? serviceFilter;
  final VoidCallback onSearchChanged;
  final ValueChanged<AppointmentTimeFilter> onTimeChanged;
  final ValueChanged<ServiceType?> onServiceChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeLabels = {
      AppointmentTimeFilter.all: l10n.appointmentFilterAllLabel,
      AppointmentTimeFilter.upcoming: l10n.appointmentFilterUpcomingLabel,
      AppointmentTimeFilter.past: l10n.appointmentFilterPastLabel,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space,
        AppTokens.spaceSm,
        AppTokens.space,
        AppTokens.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onChanged: (_) => onSearchChanged(),
            decoration: InputDecoration(
              hintText: l10n.searchAppointmentsHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged();
                      },
                    ),
            ),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Wrap(
            spacing: AppTokens.spaceSm,
            children: [
              for (final entry in timeLabels.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: timeFilter == entry.key,
                  onSelected: (_) => onTimeChanged(entry.key),
                ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceSm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.appointmentServiceAllLabel),
                  selected: serviceFilter == null,
                  onSelected: (_) => onServiceChanged(null),
                ),
                for (final type in ServiceType.values) ...[
                  const SizedBox(width: AppTokens.spaceSm),
                  ChoiceChip(
                    avatar: Icon(
                      Icons.circle,
                      size: 12,
                      color: serviceTypeColor(type),
                    ),
                    label: Text(serviceTypeLabel(context, type)),
                    selected: serviceFilter == type,
                    onSelected: (_) => onServiceChanged(type),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
