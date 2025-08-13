import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.selectProviderTitle),
      ),
      body: providers.isEmpty
          ? Center(
              child: Text(
                  AppLocalizations.of(context)!.noProvidersAvailable),
            )
          : ListView.builder(
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final provider = providers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: provider.photoBytes != null
                        ? MemoryImage(provider.photoBytes!)
                        : null,
                    child: provider.photoBytes == null ||
                            provider.photoBytes!.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(provider.name),
                  onTap: () {
                    final validProviders =
                        service.providersFor(serviceType);
                    if (!validProviders.any((p) => p.id == provider.id)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!
                                  .providerNoLongerOffersService),
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

