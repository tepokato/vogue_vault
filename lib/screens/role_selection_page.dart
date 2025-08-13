import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/role_provider.dart';
import 'auth_page.dart';
import 'appointments_page.dart';
import 'welcome_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

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
              if (roles.contains(UserRole.customer))
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<RoleProvider>().selectedRole = UserRole.customer;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WelcomePage(),
                        ),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.customerRole),
                  ),
                ),
              if (roles.contains(UserRole.customer))
                const SizedBox(height: 16),
              if (roles.contains(UserRole.professional))
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<RoleProvider>().selectedRole = UserRole.professional;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppointmentsPage(),
                        ),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.professionalRole),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

