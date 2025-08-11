import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/client.dart';
import '../models/user_role.dart';
import '../services/appointment_service.dart';
import '../services/role_provider.dart';

class EditClientPage extends StatelessWidget {
  const EditClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>().selectedRole;
    final service = context.watch<AppointmentService>();
    final clients = service.clients;

    if (role != UserRole.professional) {
      return const Scaffold(
        body: Center(
          child: Text('Available only for professionals'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return ListTile(
            title: Text(client.name),
            onTap: () => _showClientDialog(context, client: client),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => service.deleteClient(client.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClientDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showClientDialog(BuildContext context, {Client? client}) async {
    final nameController = TextEditingController(text: client?.name ?? '');
    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(client == null ? 'New Client' : 'Edit Client'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Please enter a name' : null,
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
              final id =
                  client?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
              final newClient = Client(id: id, name: nameController.text);
              if (client == null) {
                await service.addClient(newClient);
              } else {
                await service.updateClient(newClient);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameController.dispose();
  }
}
