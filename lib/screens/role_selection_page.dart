import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_role.dart';
import '../services/role_provider.dart';
import 'appointments_page.dart';
import 'welcome_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Role'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'I am a...',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
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
                  child: const Text('Customer'),
                ),
              ),
              const SizedBox(height: 16),
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
                  child: const Text('Professional'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

