import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/profile_page.dart';

/// Identifies the primary navigation destinations hosted by [MainShell].
enum AppDestination { dashboard, appointments, calendar, customers, settings }

/// A shared page scaffold used by both tab roots (hosted in [MainShell]) and
/// pushed secondary pages.
///
/// Primary navigation now lives in [MainShell]'s bottom bar, so this scaffold
/// only owns the app bar (title, actions, optional profile shortcut and an
/// automatic back button for pushed routes) plus an optional FAB.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions = const [],
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showProfileButton = true,
    this.showBackButton = true,
    this.leading,
    this.backgroundColor,
  });

  /// The primary content of the page.
  final Widget body;

  /// Optional title displayed in the [AppBar].
  final String? title;

  /// Additional actions shown before the profile button.
  final List<Widget> actions;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Whether to show the profile shortcut. Defaults to true.
  final bool showProfileButton;

  /// When true (default), shows a back button if the route can pop.
  final bool showBackButton;

  /// Overrides [leading] entirely when non-null.
  final Widget? leading;

  final Color? backgroundColor;

  void _navigateProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  Widget? _effectiveLeading(BuildContext context) {
    if (leading != null) return leading;
    if (!showBackButton) return null;
    final route = ModalRoute.of(context);
    if (route?.canPop ?? false) {
      return const BackButton();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final hasAppBar = title != null ||
        actions.isNotEmpty ||
        showProfileButton ||
        _effectiveLeading(context) != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: hasAppBar
          ? AppBar(
              automaticallyImplyLeading: false,
              leading: _effectiveLeading(context),
              titleSpacing: 20,
              title: title != null ? Text(title!) : null,
              actions: [
                ...actions,
                if (showProfileButton)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: const Icon(Icons.person_outline),
                      tooltip: loc.profileTooltip,
                      onPressed: () => _navigateProfile(context),
                    ),
                  ),
              ],
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
