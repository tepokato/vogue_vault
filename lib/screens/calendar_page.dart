import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/appointment_tile.dart';
import 'edit_appointment_page.dart';

/// Displays appointments on a calendar and lists those for the
/// currently selected day.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const Duration _workingDayCapacity = Duration(hours: 8);

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
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    final selectedAppointments = service.appointments
        .where((a) => isSameDay(a.dateTime, _selectedDay))
        .toList();

    return AppScaffold(
      title: l10n.calendarTitle,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: l10n.previousMonthTooltip,
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month - 1,
                        1,
                      );
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    DateFormat.yMMMM().format(_focusedDay),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: l10n.nextMonthTooltip,
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month + 1,
                        1,
                      );
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addAppointmentTooltip),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditAppointmentPage(
                          initialDate: DateTime(
                            _selectedDay.year,
                            _selectedDay.month,
                            _selectedDay.day,
                            now.hour,
                            now.minute,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          TableCalendar<Appointment>(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            eventLoader: (day) => service.appointments
                .where((a) => isSameDay(a.dateTime, day))
                .toList(),
            headerVisible: false,
            onPageChanged: (day) {
              setState(() {
                _focusedDay = day;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildAvailabilityCell(context, day, service,
                    isOutside: day.month != _focusedDay.month);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildAvailabilityCell(context, day, service,
                    isToday: true, isOutside: day.month != _focusedDay.month);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildAvailabilityCell(context, day, service,
                    isSelected: true,
                    isOutside: day.month != _focusedDay.month);
              },
              outsideBuilder: (context, day, focusedDay) {
                return _buildAvailabilityCell(context, day, service,
                    isOutside: true);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _AvailabilityLegend(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  label: l10n.availabilityLegendAvailable,
                ),
                const SizedBox(width: 12),
                _AvailabilityLegend(
                  color: Theme.of(context).colorScheme.errorContainer,
                  label: l10n.availabilityLegendFull,
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedAppointments.isEmpty
                ? Center(
                    child: Text(
                      l10n.noAppointmentsScheduled,
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedAppointments.length,
                    itemBuilder: (context, index) {
                      final appt = selectedAppointments[index];
                      return AppointmentTile(
                        appointment: appt,
                        showDate: false,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCell(
    BuildContext context,
    DateTime day,
    AppointmentService service, {
    bool isSelected = false,
    bool isToday = false,
    bool isOutside = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final availability = _availabilityForDay(day, service);

    Color? background;
    Color? borderColor;

    if (availability == _DayAvailability.full) {
      background = colorScheme.errorContainer;
    } else {
      background = colorScheme.secondaryContainer;
    }

    if (isSelected) {
      background = colorScheme.primary;
    } else if (isToday) {
      borderColor = colorScheme.primary;
    }

    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isSelected
              ? colorScheme.onPrimary
              : isOutside
                  ? colorScheme.onSurface.withOpacity(0.4)
                  : colorScheme.onSurface,
        );

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isOutside ? null : background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: borderColor != null ? 1.5 : 0,
        ),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: textStyle,
        ),
      ),
    );
  }

  _DayAvailability _availabilityForDay(
    DateTime day,
    AppointmentService service,
  ) {
    final appointmentsOnDay = service.appointments
        .where((a) => isSameDay(a.dateTime, day))
        .toList();
    if (appointmentsOnDay.isEmpty) return _DayAvailability.available;

    final totalDuration = appointmentsOnDay.fold<Duration>(
      Duration.zero,
      (sum, appt) => sum + appt.duration,
    );

    return totalDuration >= _workingDayCapacity
        ? _DayAvailability.full
        : _DayAvailability.available;
  }
}

enum _DayAvailability { available, full }

class _AvailabilityLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _AvailabilityLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
