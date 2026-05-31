import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../app/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/appointment_tile.dart';
import '../widgets/ui/ui.dart';
import 'edit_appointment_page.dart';

/// Displays appointments on a calendar and lists those for the selected day.
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

  bool _countsTowardCapacity(Appointment a, String? userId) {
    if (userId == null) return true;
    return a.providerId == null || a.providerId == userId;
  }

  void _addForSelectedDay() {
    final now = DateTime.now();
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final service = context.watch<AppointmentService>();
    final auth = context.watch<AuthService>();
    final l10n = AppLocalizations.of(context)!;
    final userId = auth.currentUser;

    final dayAppointments = service.appointments
        .where((a) => isSameDay(a.dateTime, _selectedDay))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return AppScaffold(
      title: l10n.calendarTitle,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space,
              AppTokens.spaceSm,
              AppTokens.space,
              AppTokens.spaceSm,
            ),
            child: AppCard(
              padding: const EdgeInsets.all(AppTokens.spaceMd),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        tooltip: l10n.previousMonthTooltip,
                        onPressed: () => setState(() {
                          _focusedDay = DateTime(
                              _focusedDay.year, _focusedDay.month - 1, 1);
                        }),
                      ),
                      Expanded(
                        child: Text(
                          DateFormat.yMMMM().format(_focusedDay),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        tooltip: l10n.nextMonthTooltip,
                        onPressed: () => setState(() {
                          _focusedDay = DateTime(
                              _focusedDay.year, _focusedDay.month + 1, 1);
                        }),
                      ),
                    ],
                  ),
                  TableCalendar<Appointment>(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    headerVisible: false,
                    daysOfWeekHeight: 28,
                    rowHeight: 46,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    eventLoader: (day) => service.appointments
                        .where((a) => isSameDay(a.dateTime, day))
                        .where((a) => _countsTowardCapacity(a, userId))
                        .toList(),
                    onPageChanged: (day) => setState(() => _focusedDay = day),
                    onDaySelected: (selectedDay, focusedDay) => setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    }),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (c, day, _) =>
                          _cell(day, service, userId),
                      todayBuilder: (c, day, _) =>
                          _cell(day, service, userId, isToday: true),
                      selectedBuilder: (c, day, _) =>
                          _cell(day, service, userId, isSelected: true),
                      outsideBuilder: (c, day, _) =>
                          _cell(day, service, userId, isOutside: true),
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                  Row(
                    children: [
                      _Legend(
                        color: scheme.tertiary,
                        label: l10n.availabilityLegendAvailable,
                      ),
                      const SizedBox(width: AppTokens.space),
                      _Legend(
                        color: scheme.error,
                        label: l10n.availabilityLegendFull,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.spaceLg,
                AppTokens.spaceSm,
                AppTokens.space,
                0,
              ),
              child: Text(
                DateFormat.yMMMMEEEEd().format(_selectedDay),
                style: theme.textTheme.titleSmall,
              ),
            ),
          ),
          Expanded(
            child: dayAppointments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.spaceLg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.noAppointmentsToday,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppTokens.space),
                          FilledButton.icon(
                            onPressed: _addForSelectedDay,
                            icon: const Icon(Icons.add),
                            label: Text(l10n.addAppointmentTooltip),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      top: AppTokens.spaceSm,
                      bottom: AppTokens.spaceXl,
                    ),
                    itemCount: dayAppointments.length,
                    itemBuilder: (context, index) {
                      final appt = dayAppointments[index];
                      return AppointmentTile(
                        appointment: appt,
                        showDate: false,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditAppointmentPage(appointment: appt),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _cell(
    DateTime day,
    AppointmentService service,
    String? userId, {
    bool isSelected = false,
    bool isToday = false,
    bool isOutside = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final availability = _availabilityForDay(day, service, userId);
    final hasEvents = service.appointments
        .where((a) => isSameDay(a.dateTime, day))
        .where((a) => _countsTowardCapacity(a, userId))
        .isNotEmpty;

    Color? background;
    if (hasEvents) {
      background = availability == _DayAvailability.full
          ? scheme.error.withOpacity(0.16)
          : scheme.tertiary.withOpacity(0.16);
    }
    if (isSelected) background = scheme.primary;

    final textColor = isSelected
        ? scheme.onPrimary
        : isOutside
            ? scheme.onSurface.withOpacity(0.35)
            : scheme.onSurface;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: isToday && !isSelected
            ? Border.all(color: scheme.primary, width: 1.5)
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight:
                    isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ),
    );
  }

  _DayAvailability _availabilityForDay(
    DateTime day,
    AppointmentService service,
    String? userId,
  ) {
    final onDay = service.appointments
        .where((a) => isSameDay(a.dateTime, day))
        .where((a) => _countsTowardCapacity(a, userId))
        .toList();
    if (onDay.isEmpty) return _DayAvailability.available;
    final total = onDay.fold<Duration>(
      Duration.zero,
      (sum, a) => sum + a.duration + a.bufferDuration,
    );
    return total >= _workingDayCapacity
        ? _DayAvailability.full
        : _DayAvailability.available;
  }
}

enum _DayAvailability { available, full }

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
