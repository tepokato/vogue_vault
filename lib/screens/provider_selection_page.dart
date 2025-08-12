import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service_type.dart';
import '../services/appointment_service.dart';
import 'edit_appointment_page.dart';

class ProviderSelectionPage extends StatelessWidget {
  final ServiceType serviceType;

  const ProviderSelectionPage({super.key, required this.serviceType});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final providers = service.providersFor(serviceType);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Provider'),
      ),
      body: providers.isEmpty
          ? const Center(
              child: Text('No providers available.'),
            )
          : ListView.builder(
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final provider = providers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: provider.photoUrl != null &&
                            provider.photoUrl!.isNotEmpty
                        ? FileImage(File(provider.photoUrl!))
                        : null,
                    child: provider.photoUrl == null ||
                            provider.photoUrl!.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(provider.name),
                  onTap: () {
                    final validProviders =
                        service.providersFor(serviceType);
                    if (!validProviders.any((p) => p.id == provider.id)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Selected provider no longer offers this service.'),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditAppointmentPage(
                          initialService: serviceType,
                          initialProviderId: provider.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

