import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/appointment.dart';
import '../models/service_type.dart';
import '../models/user_role.dart';
import '../utils/service_type_utils.dart';
import '../services/appointment_service.dart';
import '../services/role_provider.dart';
import 'edit_appointment_page.dart';
import 'edit_client_page.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final role = context.watch<RoleProvider>().selectedRole;
    final appointments = service.appointments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          if (role == UserRole.professional)
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
            leading: CircleAvatar(
              backgroundColor: serviceTypeColor(appt.service),
              child: Icon(
                serviceTypeIcon(appt.service),
                color: Colors.white,
              ),
            ),
            title: Text(
              '${client?.name ?? 'Unknown'} - ${serviceTypeLabel(appt.service)}',
            ),
            subtitle: Text(
              DateFormat.yMMMd().add_jm().format(
                    appt.dateTime.toLocal(),
                  ),
            ),
            onTap: role == UserRole.professional
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditAppointmentPage(appointment: appt),
                      ),
                    );
                  }
                : null,
            trailing: role == UserRole.professional
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => service.deleteAppointment(appt.id),
                  )
                : null,
          );
        },
      ),
      floatingActionButton: role == UserRole.professional
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditAppointmentPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
