import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/appointment_tile.dart';
import '../widgets/main_shell.dart';
import '../widgets/ui/ui.dart';
import 'addresses_page.dart';
import 'customers_page.dart';
import 'edit_appointment_page.dart';

/// The landing experience after sign-in: a greeting hero, key metrics,
/// today's agenda and quick actions.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final service = context.watch<AppointmentService>();
    final auth = context.watch<AuthService>();
    final now = DateTime.now();

    final all = service.appointments;
    final today = all
        .where((a) => _sameDay(a.dateTime.toLocal(), now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final weekEnd = now.add(const Duration(days: 7));
    final weekCount = all
        .where((a) =>
            a.dateTime.isAfter(now) && a.dateTime.isBefore(weekEnd))
        .length;
    final clientCount = service.customers.length;

    final greeting = now.hour < 12
        ? l10n.greetingMorning
        : now.hour < 18
            ? l10n.greetingAfternoon
            : l10n.greetingEvening;
    final providerName = auth.currentUser != null
        ? service.getUser(auth.currentUser!)?.firstName
        : null;

    final visibleToday = today.take(4).toList();

    return AppScaffold(
      title: null,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.space,
            0,
            AppTokens.space,
            AppTokens.spaceXl,
          ),
          children: [
            GradientHero(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    providerName != null && providerName.isNotEmpty
                        ? providerName
                        : l10n.appTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceSm),
                  Text(
                    l10n.dashboardTagline,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.today_outlined,
                    value: '${today.length}',
                    label: l10n.statTodayLabel,
                    color: theme.colorScheme.primary,
                    onTap: () => MainShellScope.maybeOf(context)
                        ?.goToTab(AppDestination.calendar),
                  ),
                ),
                const SizedBox(width: AppTokens.spaceMd),
                Expanded(
                  child: StatCard(
                    icon: Icons.date_range_outlined,
                    value: '$weekCount',
                    label: l10n.statWeekLabel,
                    color: theme.colorScheme.secondary,
                    onTap: () => MainShellScope.maybeOf(context)
                        ?.goToTab(AppDestination.appointments),
                  ),
                ),
                const SizedBox(width: AppTokens.spaceMd),
                Expanded(
                  child: StatCard(
                    icon: Icons.groups_outlined,
                    value: '$clientCount',
                    label: l10n.statClientsLabel,
                    color: theme.colorScheme.tertiary,
                    onTap: () => MainShellScope.maybeOf(context)
                        ?.goToTab(AppDestination.customers),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceLg),
            SectionHeader(
              title: l10n.todayScheduleTitle,
              actionLabel: l10n.viewAllLabel,
              onActionTap: () => MainShellScope.maybeOf(context)
                  ?.goToTab(AppDestination.appointments),
            ),
            if (visibleToday.isEmpty)
              _DashboardEmpty(message: l10n.noAppointmentsToday)
            else
              ..._todayTiles(context, visibleToday),
            const SizedBox(height: AppTokens.spaceLg),
            SectionHeader(title: l10n.quickActionsTitle),
            _QuickActions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _todayTiles(BuildContext context, List<Appointment> items) {
    return [
      for (final appt in items)
        AppointmentTile(
          appointment: appt,
          showDate: false,
          padding: const EdgeInsets.only(bottom: AppTokens.spaceMd),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditAppointmentPage(appointment: appt),
            ),
          ),
        ),
    ];
  }
}

class _DashboardEmpty extends StatelessWidget {
  const _DashboardEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.event_available_outlined,
              color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppTokens.spaceMd),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.add,
            label: l10n.addAppointmentTooltip,
            color: scheme.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditAppointmentPage()),
            ),
          ),
        ),
        const SizedBox(width: AppTokens.spaceMd),
        Expanded(
          child: _ActionTile(
            icon: Icons.person_add_alt_1_outlined,
            label: l10n.newClientLabel,
            color: scheme.tertiary,
            onTap: () => showCustomerEditor(context),
          ),
        ),
        const SizedBox(width: AppTokens.spaceMd),
        Expanded(
          child: _ActionTile(
            icon: Icons.add_location_alt_outlined,
            label: l10n.newLocationLabel,
            color: scheme.secondary,
            onTap: () => showAddressEditor(context),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceSm,
        vertical: AppTokens.space,
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppTokens.spaceSm),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
