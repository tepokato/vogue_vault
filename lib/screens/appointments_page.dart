import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../services/appointment_service.dart';
import 'edit_appointment_page.dart';
import 'edit_client_page.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final appointments = service.appointments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Clients',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditClientPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final Appointment appt = appointments[index];
          final client = service.getClient(appt.clientId);
          return ListTile(
            title: Text('${client?.name ?? 'Unknown'} - ${appt.service}'),
            subtitle: Text(appt.dateTime.toLocal().toString()),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditAppointmentPage(appointment: appt),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => service.deleteAppointment(appt.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EditAppointmentPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
