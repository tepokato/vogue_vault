import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/client.dart';
import '../services/client_service.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ClientService>();
    final clients = service.clients;
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
            subtitle: Text(client.contact),
            onTap: () => _editClient(context, client),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editClient(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _editClient(BuildContext context, Client? client) async {
    final service = context.read<ClientService>();
    final nameController =
        TextEditingController(text: client != null ? client.name : '');
    final contactController =
        TextEditingController(text: client != null ? client.contact : '');
    final notesController =
        TextEditingController(text: client != null ? client.notes ?? '' : '');

    await showDialog(
      context: context,
      builder: (context) {
        final appointments =
            client != null ? service.history(client.id) : <dynamic>[];
        return AlertDialog(
          title: Text(client == null ? 'New Client' : 'Edit Client'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                if (appointments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Past Appointments'),
                  ),
                  for (final appt in appointments)
                    ListTile(
                      title: Text(appt.service.name),
                      subtitle: Text(appt.dateTime.toLocal().toString()),
                    ),
                ]
              ],
            ),
          ),
          actions: [
            if (client != null)
              TextButton(
                onPressed: () async {
                  await service.deleteClient(client.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final id = client?.id ?? const Uuid().v4();
                final updated = Client(
                  id: id,
                  name: nameController.text,
                  contact: contactController.text,
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                );
                if (client == null) {
                  await service.addClient(updated);
                } else {
                  await service.updateClient(updated);
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

