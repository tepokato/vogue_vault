import 'package:flutter/material.dart';

import '../models/service_type.dart';
import '../utils/service_type_utils.dart';
import 'appointments_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore our services',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: ServiceType.values
                    .map((type) => _ServiceCard(type: type))
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
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AppointmentsPage(),
            ),
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                serviceTypeIcon(type),
                size: 40,
                color: serviceTypeColor(type),
              ),
              const SizedBox(height: 8),
              Text(serviceTypeLabel(type)),
            ],
          ),
        ),
      ),
    );
  }
}
