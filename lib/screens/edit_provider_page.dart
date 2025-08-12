import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service_provider.dart';
import '../models/service_type.dart';
import '../models/user_role.dart';
import '../services/appointment_service.dart';
import '../services/role_provider.dart';

class EditProviderPage extends StatelessWidget {
  const EditProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>().selectedRole;
    final service = context.watch<AppointmentService>();
    final providers = service.providers;

    if (role != UserRole.professional) {
      return const Scaffold(
        body: Center(
          child: Text('Available only for professionals'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Providers'),
      ),
      body: ListView.builder(
        itemCount: providers.length,
        itemBuilder: (context, index) {
          final provider = providers[index];
          return ListTile(
            title: Text(provider.name),
            subtitle: Text(provider.serviceType.name),
            onTap: () => _showProviderDialog(context, provider: provider),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => service.deleteProvider(provider.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProviderDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showProviderDialog(BuildContext context,
      {ServiceProvider? provider}) async {
    final nameController = TextEditingController(text: provider?.name ?? '');
    final formKey = GlobalKey<FormState>();
    var selectedType = provider?.serviceType ?? ServiceType.barber;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(provider == null ? 'New Provider' : 'Edit Provider'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter a name'
                        : null,
                  ),
                  DropdownButtonFormField<ServiceType>(
                    key: const Key('serviceTypeDropdown'),
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Service Type'),
                    items: ServiceType.values
                        .map(
                          (s) => DropdownMenuItem<ServiceType>(
                            value: s,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => selectedType = value!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final service = context.read<AppointmentService>();
                  final id = provider?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString();
                  final newProvider = ServiceProvider(
                    id: id,
                    name: nameController.text,
                    serviceType: selectedType,
                  );
                  if (provider == null) {
                    await service.addProvider(newProvider);
                  } else {
                    await service.updateProvider(newProvider);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    nameController.dispose();
  }
}

