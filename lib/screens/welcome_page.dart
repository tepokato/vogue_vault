import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service_type.dart';
import '../utils/service_type_utils.dart';
import '../services/role_provider.dart';
import 'appointments_page.dart';
import 'provider_selection_page.dart';
import 'profile_page.dart';
import 'role_selection_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.switch_account),
            tooltip: 'Switch Role',
            onPressed: () {
              context.read<RoleProvider>().clearRole();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const RoleSelectionPage(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore our services',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: ServiceType.values
                    .map(
                      (type) => Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _ServiceCard(type: type),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppointmentsPage(),
                    ),
                  );
                },
                child: const Text('Get Started'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceType type;

  const _ServiceCard({required this.type});

  @override
  Widget build(BuildContext context) {
    final Color color = serviceTypeColor(type);
    final Widget visual = Icon(
      serviceTypeIcon(type),
      size: 40,
      color: color,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      splashColor: color.withOpacity(0.2),
      hoverColor: color.withOpacity(0.1),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProviderSelectionPage(serviceType: type),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.05),
              color.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            visual,
            const SizedBox(height: 8),
            Text(serviceTypeLabel(type)),
          ],
        ),
      ),
    );
  }
}
