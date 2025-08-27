import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../utils/service_type_utils.dart';
import '../widgets/app_scaffold.dart';

/// Displays appointments on a calendar and lists those for the
/// currently selected day.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final locale = Localizations.localeOf(context).toString();

    final selectedAppointments = service.appointments
        .where((a) => isSameDay(a.dateTime, _selectedDay))
        .toList();

    return AppScaffold(
      title: AppLocalizations.of(context)!.calendarTitle,
      body: Column(
        children: [
          TableCalendar<Appointment>(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            eventLoader: (day) => service.appointments
                .where((a) => isSameDay(a.dateTime, day))
                .toList(),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          Expanded(
            child: selectedAppointments.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.noAppointmentsScheduled,
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedAppointments.length,
                    itemBuilder: (context, index) {
                      final appt = selectedAppointments[index];
                      final providerName = appt.providerId != null
                          ? service.getUser(appt.providerId!)?.name ??
                                AppLocalizations.of(context)!.unknownUser
                          : AppLocalizations.of(context)!.unknownUser;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: serviceTypeColor(appt.service),
                          child: ImageIcon(
                            AssetImage(serviceTypeIcon(appt.service)),
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        title: Text(
                          '${serviceTypeLabel(context, appt.service)} - '
                          '$providerName',
                        ),
                        subtitle: Text(
                          '${DateFormat.jm(locale).format(appt.dateTime.toLocal())} - '
                          '${DateFormat.jm(locale).format(appt.dateTime.toLocal().add(appt.duration))}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
