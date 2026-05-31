import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/appointments_page.dart';
import '../screens/calendar_page.dart';
import '../screens/customers_page.dart';
import '../screens/dashboard_page.dart';
import '../screens/edit_appointment_page.dart';
import '../screens/settings_page.dart';
import 'app_scaffold.dart';

/// Exposes the [MainShell] tab controller to descendant pages so they can
/// programmatically switch tabs (e.g. a dashboard "View all" shortcut).
class MainShellScope extends InheritedWidget {
  const MainShellScope({
    super.key,
    required this.goToTab,
    required this.currentIndex,
    required super.child,
  });

  final void Function(AppDestination destination) goToTab;
  final int currentIndex;

  static MainShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainShellScope>();

  @override
  bool updateShouldNotify(MainShellScope oldWidget) =>
      currentIndex != oldWidget.currentIndex;
}

/// The post-login home: a persistent [IndexedStack] of the five primary
/// destinations with a modern bottom [NavigationBar] and a contextual FAB.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialDestination = AppDestination.dashboard});

  final AppDestination initialDestination;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialDestination.index;

  /// Tabs are built lazily on first visit and kept alive afterwards so each
  /// retains its scroll position and state without forcing every provider to
  /// exist before the shell renders.
  final List<Widget?> _builtPages = List<Widget?>.filled(5, null);

  Widget _pageFor(int index) {
    switch (AppDestination.values[index]) {
      case AppDestination.dashboard:
        return const DashboardPage();
      case AppDestination.appointments:
        return const AppointmentsPage();
      case AppDestination.calendar:
        return const CalendarPage();
      case AppDestination.customers:
        return const CustomersPage();
      case AppDestination.settings:
        return const SettingsPage();
    }
  }

  void _goToTab(AppDestination destination) {
    setState(() => _index = destination.index);
  }

  void _openNewAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditAppointmentPage()),
    );
  }

  Widget? _buildFab(AppLocalizations loc) {
    // The "+" quick-add is global to scheduling-centric tabs. Customers and
    // Settings provide their own primary actions inline.
    const appointmentTabs = {0, 1, 2};
    if (!appointmentTabs.contains(_index)) return null;
    return FloatingActionButton(
      heroTag: 'mainShellFab',
      onPressed: _openNewAppointment,
      tooltip: loc.addAppointmentTooltip,
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final destinations = [
      _NavItem(Icons.dashboard_outlined, Icons.dashboard, loc.homeTooltip),
      _NavItem(Icons.event_note_outlined, Icons.event_note,
          loc.appointmentsTitle),
      _NavItem(Icons.calendar_month_outlined, Icons.calendar_month,
          loc.calendarTitle),
      _NavItem(Icons.people_outline, Icons.people, loc.customersTitle),
      _NavItem(Icons.settings_outlined, Icons.settings, loc.settingsTitle),
    ];

    _builtPages[_index] ??= _pageFor(_index);

    return MainShellScope(
      goToTab: _goToTab,
      currentIndex: _index,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            for (var i = 0; i < _builtPages.length; i++)
              _builtPages[i] ?? const SizedBox.shrink(),
          ],
        ),
        floatingActionButton: _buildFab(loc),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
