import 'package:flutter/material.dart';

import 'edit_appointment_page.dart';
import 'edit_client_page.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = <String>[
      'Consultation with Alice - Sep 10 10:00 AM',
      'Facial for Bob - Sep 12 2:00 PM',
      'Hair styling for Carol - Sep 14 1:00 PM',
    ];

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
          final appointment = appointments[index];
          return ListTile(
            title: Text(appointment),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditAppointmentPage(appointment: appointment),
                ),
              );
            },
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
