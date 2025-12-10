import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/appointment.dart';
import '../models/service_type.dart';
import '../services/appointment_service.dart';
import '../utils/service_type_utils.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/appointment_tile.dart';
import 'calendar_page.dart';
import 'edit_appointment_page.dart';
import 'customers_page.dart';
import 'my_business_page.dart';

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

  void _replaceWithPage(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesTime(Appointment appointment) {
    final now = DateTime.now();
    final appointmentEnds = appointment.dateTime.add(appointment.duration);
    switch (_timeFilter) {
      case AppointmentTimeFilter.all:
        return true;
      case AppointmentTimeFilter.upcoming:
        return appointmentEnds.isAfter(now);
      case AppointmentTimeFilter.past:
        return appointmentEnds.isBefore(now);
    }
  }

  bool _matchesService(Appointment appointment) {
    if (_serviceFilter == null) return true;
    return appointment.service == _serviceFilter;
  }

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

    return [
      providerName,
      customerName,
      guestName,
      location,
      serviceLabel,
    ].any((field) => field.toLowerCase().contains(query));
  }

  List<Appointment> _filteredAppointments(AppointmentService service) {
    return service.appointments.where((appt) {
      return _matchesTime(appt) &&
          _matchesService(appt) &&
          _matchesSearch(appt, service);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final appointments = service.appointments;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.appointmentsTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          tooltip: l10n.calendarTooltip,
          onPressed: () => _replaceWithPage(const CalendarPage()),
        ),
        IconButton(
          icon: const Icon(Icons.store),
          tooltip: l10n.myBusinessTooltip,
          onPressed: () => _replaceWithPage(const MyBusinessPage()),
        ),
      ],
      body: appointments.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(l10n.noAppointmentsScheduled,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      l10n.appointmentsEmptyDescription,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditAppointmentPage(),
                          ),
                        );
                      },
                      child: Text(
                        l10n.addFirstAppointment,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.contacts),
                                    title: Text(l10n.customersTitle),
                                    subtitle: Text(l10n.importAppointmentsCta),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _replaceWithPage(
                                        const CustomersPage(),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.calendar_today),
                                    title: Text(l10n.calendarTitle),
                                    subtitle: Text(l10n.importAppointmentsCta),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _replaceWithPage(
                                        const CalendarPage(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text(l10n.importAppointmentsCta),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: l10n.searchAppointmentsLabel,
                          hintText: l10n.searchAppointmentsHint,
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<AppointmentTimeFilter>(
                              value: _timeFilter,
                              decoration: InputDecoration(
                                labelText: l10n.appointmentTimeFilterLabel,
                                border: const OutlineInputBorder(),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: AppointmentTimeFilter.all,
                                  child:
                                      Text(l10n.appointmentFilterAllLabel),
                                ),
                                DropdownMenuItem(
                                  value: AppointmentTimeFilter.upcoming,
                                  child: Text(
                                      l10n.appointmentFilterUpcomingLabel),
                                ),
                                DropdownMenuItem(
                                  value: AppointmentTimeFilter.past,
                                  child:
                                      Text(l10n.appointmentFilterPastLabel),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _timeFilter = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<ServiceType?>(
                              value: _serviceFilter,
                              decoration: InputDecoration(
                                labelText: l10n.appointmentServiceFilterLabel,
                                border: const OutlineInputBorder(),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(l10n.appointmentServiceAllLabel),
                                ),
                                ...ServiceType.values.map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      serviceTypeLabel(context, type),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _serviceFilter = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final filtered = _filteredAppointments(service);
                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(l10n.noAppointmentsMatchFilters),
                        );
                      }

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final appt = filtered[index];
                          return AppointmentTile(
                            appointment: appt,
                            showDate: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditAppointmentPage(appointment: appt),
                                ),
                              );
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: l10n.deleteAppointmentTooltip,
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                          AppLocalizations.of(context)!
                                              .deleteAppointmentTitle),
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .deleteAppointmentConfirmation),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(AppLocalizations.of(context)!
                                              .cancelButton),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text(AppLocalizations.of(context)!
                                              .deleteButton),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  await service.deleteAppointment(appt.id);
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditAppointmentPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
