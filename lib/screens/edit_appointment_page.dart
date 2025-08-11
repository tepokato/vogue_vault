import 'package:flutter/material.dart';

class EditAppointmentPage extends StatelessWidget {
  final String? appointment;

  const EditAppointmentPage({super.key, this.appointment});

  @override
  Widget build(BuildContext context) {
    final isEditing = appointment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Appointment' : 'New Appointment'),
      ),
      body: const Center(
        child: Text('Appointment form goes here'),
      ),
    );
  }
}
