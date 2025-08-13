import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/appointment.dart';
import '../models/user_role.dart';
import '../utils/service_type_utils.dart';
import '../services/appointment_service.dart';
import '../services/role_provider.dart';
import 'edit_appointment_page.dart';
import 'edit_user_page.dart';
import 'profile_page.dart';
import 'role_selection_page.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final role = context.watch<RoleProvider>().selectedRole;
    final appointments = service.appointments;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appointmentsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: AppLocalizations.of(context)!.profileTooltip,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.switch_account),
            tooltip: AppLocalizations.of(context)!.switchRoleTooltip,
            onPressed: () {
              context.read<RoleProvider>().clearRole();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const RoleSelectionPage(),
                ),
                (route) => false,
              );
            },
          ),
          if (role == UserRole.professional)
            IconButton(
              icon: const Icon(Icons.people),
              tooltip: AppLocalizations.of(context)!.usersTooltip,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditUserPage(),
                  ),
                );
              },
            ),
        ],
      ),
      body: appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.noAppointmentsScheduled),
                  if (role == UserRole.professional) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditAppointmentPage(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.addFirstAppointment,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final Appointment appt = appointments[index];
                final client = service.getUser(appt.clientId);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: serviceTypeColor(appt.service),
                    child: Icon(
                      serviceTypeIcon(appt.service),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    '${client?.name ?? AppLocalizations.of(context)!.unknownUser} - ${serviceTypeLabel(appt.service)}',
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
