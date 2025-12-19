import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../screens/appointments_page.dart';
import '../screens/calendar_page.dart';
import '../screens/customers_page.dart';
import '../screens/edit_appointment_page.dart';
import '../screens/profile_page.dart';
import '../screens/settings_page.dart';

/// Identifies the main navigation destinations in the app.
enum AppDestination { appointments, calendar, customers, settings }

/// A reusable scaffold with a fixed top navigation bar containing
/// common actions across the app.
class AppScaffold extends StatelessWidget {
  /// The primary content of the page.
  final Widget body;

  /// Optional title displayed in the [AppBar].
  final String? title;

  /// Additional actions to display in the [AppBar]. These will appear
  /// before the profile button.
  final List<Widget> actions;

  /// Optional floating action button for the scaffold.
  final Widget? floatingActionButton;

  /// Whether to show the profile button. Defaults to true but can be
  /// disabled on pages like [ProfilePage] itself.
  final bool showProfileButton;

  /// Whether to show the home button. Defaults to true but can be
  /// disabled on pages like onboarding screens.
  final bool showHomeButton;

  /// Whether to show the settings button. Defaults to true but can be
  /// disabled on pages like [SettingsPage] itself.
  final bool showSettingsButton;

  /// When provided, renders a bottom navigation bar with the selected
  /// [AppDestination] highlighted. This keeps the primary navigation
  /// consistent across core screens.
  final AppDestination? currentDestination;

  /// Whether to show a standard "Add appointment" shortcut in the center
  /// of the bottom navigation. Pages can override this by providing a
  /// custom [floatingActionButton].
  final bool showAddAppointmentShortcut;

  /// Optionally override where the floating action button is placed.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions = const [],
    this.floatingActionButton,
    this.showProfileButton = true,
    this.showHomeButton = true,
    this.showSettingsButton = true,
    this.currentDestination,
    this.showAddAppointmentShortcut = true,
    this.floatingActionButtonLocation,
  });

  void _navigateHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AppointmentsPage()),
      (route) => false,
    );
  }

  void _navigateProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  void _navigateSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  void _navigateToDestination(BuildContext context, AppDestination destination) {
    if (destination == currentDestination) return;

    Widget page;
    switch (destination) {
      case AppDestination.appointments:
        page = const AppointmentsPage();
        break;
      case AppDestination.calendar:
        page = const CalendarPage();
        break;
      case AppDestination.customers:
        page = const CustomersPage();
        break;
      case AppDestination.settings:
        page = const SettingsPage();
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  Widget? _buildBottomNavigation(BuildContext context) {
    if (currentDestination == null) return null;

    final loc = AppLocalizations.of(context)!;

    final destinations = [
      _NavigationItem(
        destination: AppDestination.appointments,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: loc.appointmentsTitle,
      ),
      _NavigationItem(
        destination: AppDestination.calendar,
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month,
        label: loc.calendarTitle,
      ),
      _NavigationItem(
        destination: AppDestination.customers,
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
        label: loc.customersTitle,
      ),
      _NavigationItem(
        destination: AppDestination.settings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: loc.settingsTitle,
      ),
    ];

    final selectedIndex = destinations
        .indexWhere((dest) => dest.destination == currentDestination);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedIndex: selectedIndex == -1 ? 0 : selectedIndex,
          height: 72,
          destinations: destinations
              .map(
                (dest) => NavigationDestination(
                  icon: Icon(dest.icon),
                  selectedIcon: Icon(dest.selectedIcon),
                  label: dest.label,
                ),
              )
              .toList(),
          onDestinationSelected: (index) =>
              _navigateToDestination(context, destinations[index].destination),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (floatingActionButton != null) return floatingActionButton;
    if (currentDestination == null || !showAddAppointmentShortcut) return null;

    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditAppointmentPage()),
        );
      },
      tooltip: AppLocalizations.of(context)!.addAppointmentTooltip,
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
        leading: showHomeButton && currentDestination == null
            ? IconButton(
                icon: const Icon(Icons.home),
                tooltip: loc.homeTooltip,
                onPressed: () => _navigateHome(context),
              )
            : null,
        actions: [
          ...actions,
          if (showSettingsButton && currentDestination == null)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: loc.settingsTooltip,
              onPressed: () => _navigateSettings(context),
            ),
          if (showProfileButton)
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: loc.profileTooltip,
              onPressed: () => _navigateProfile(context),
            ),
        ],
      ),
      body: body,
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation:
          floatingActionButtonLocation ??
              (currentDestination != null
                  ? FloatingActionButtonLocation.centerDocked
                  : null),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.destination,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final AppDestination destination;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

