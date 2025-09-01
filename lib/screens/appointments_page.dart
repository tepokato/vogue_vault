import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/appointment_tile.dart';
import 'edit_appointment_page.dart';
import 'my_business_page.dart';
import 'calendar_page.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final appointments = service.appointments;

    return AppScaffold(
      title: AppLocalizations.of(context)!.appointmentsTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          tooltip: AppLocalizations.of(context)!.calendarTooltip,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.person),
          tooltip: AppLocalizations.of(context)!.myBusinessTooltip,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyBusinessPage()),
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
                final appt = appointments[index];
                return AppointmentTile(
                  appointment: appt,
                  showDate: true,
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
                    tooltip:
                        AppLocalizations.of(context)!.deleteAppointmentTooltip,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context)!
                                  .deleteAppointmentTitle),
                              content: Text(AppLocalizations.of(context)!
                                  .deleteAppointmentConfirmation),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(
                                      AppLocalizations.of(context)!.cancelButton),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                      AppLocalizations.of(context)!.deleteButton),
                                ),
                              ],
                            );
                        },
                      );

                      if (confirm == true) {
                        await service.deleteAppointment(appt.id);
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditAppointmentPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
