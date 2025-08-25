import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/role_provider.dart';
import 'auth_page.dart';
import 'appointments_page.dart';
import 'profile_page.dart';

/// Maps each [UserRole] to the page that should be displayed when that role is
/// selected. Tests may extend this map to verify new roles without modifying
/// the widget implementation.
final Map<UserRole, WidgetBuilder> rolePages = {
  UserRole.professional: (_) => const AppointmentsPage(),
};

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  List<Widget> _buildRoleButtons(BuildContext context, Set<UserRole> roles) {
    final loc = AppLocalizations.of(context)!;
    final labels = {
      UserRole.professional: loc.professionalRole,
    };
    final available = roles.where(rolePages.containsKey).toList();
    final widgets = <Widget>[];
    for (var i = 0; i < available.length; i++) {
      final role = available[i];
      widgets.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<RoleProvider>().selectedRole = role;
              Navigator.push(
                context,
                MaterialPageRoute(builder: rolePages[role]!),
              );
            },
            child: Text(labels[role] ?? role.name),
          ),
        ),
      );
      if (i < available.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
    }
    return widgets;
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roles = context.watch<RoleProvider>().roles;
    final auth = context.watch<AuthService>();

    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
        );
      });
      return const SizedBox.shrink();
    }

    if (roles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.selectRoleTitle),
          actions: [
            IconButton(
              onPressed: () {
                context.read<AuthService>().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
              },
              icon: const Icon(Icons.logout),
              tooltip: AppLocalizations.of(context)!.logoutTooltip,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.selectAtLeastOneRole),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfilePage(),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.profileTitle),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectRoleTitle),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthService>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: AppLocalizations.of(context)!.logoutTooltip,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.iAmA,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ..._buildRoleButtons(context, roles),
            ],
          ),
        ),
      ),
    );
  }
}

