import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/appointment.dart';
import '../utils/service_type_utils.dart';
import '../services/appointment_service.dart';
import '../widgets/app_scaffold.dart';
import 'edit_appointment_page.dart';
import 'edit_user_page.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final appointments = service.appointments;
    final locale = Localizations.localeOf(context).toString();

    return AppScaffold(
      title: AppLocalizations.of(context)!.appointmentsTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.group),
          tooltip: AppLocalizations.of(context)!.usersTooltip,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditUserPage()),
            );
          },
        ),
      ],
      body: appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.noAppointmentsScheduled),
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
              ),
            )
          : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final Appointment appt = appointments[index];
                final clientName = appt.clientId != null
                    ? service.getUser(appt.clientId!)?.name ??
                        AppLocalizations.of(context)!.unknownUser
                    : appt.guestName ??
                        AppLocalizations.of(context)!.unknownUser;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: serviceTypeColor(appt.service),
                    child: ImageIcon(
                      AssetImage(serviceTypeIcon(appt.service)),
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  title: Text(
                    '$clientName - ${serviceTypeLabel(context, appt.service)}',
                  ),
                  subtitle: Text(
                    '${DateFormat.yMMMd(locale).format(appt.dateTime.toLocal())} '
                    '${DateFormat.jm(locale).format(appt.dateTime.toLocal())} - '
                    '${DateFormat.jm(locale).format(appt.dateTime.toLocal().add(appt.duration))}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditAppointmentPage(appointment: appt),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await service.deleteAppointment(appt.id);
                    },
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
