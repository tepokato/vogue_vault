import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../screens/profile_page.dart';
import '../screens/appointments_page.dart';
import '../screens/settings_page.dart';

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

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions = const [],
    this.floatingActionButton,
    this.showProfileButton = true,
    this.showHomeButton = true,
    this.showSettingsButton = true,
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
        leading: showHomeButton
            ? IconButton(
                icon: const Icon(Icons.home),
                tooltip: loc.homeTooltip,
                onPressed: () => _navigateHome(context),
              )
            : null,
        actions: [
          ...actions,
          if (showSettingsButton)
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
      floatingActionButton: floatingActionButton,
    );
  }
}

