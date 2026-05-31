import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../utils/service_type_utils.dart';
import 'ui/app_card.dart';
import 'ui/service_avatar.dart';

/// A modern card presenting an [Appointment]: service badge, title, time
/// range, client/location and an optional price pill.
///
/// Keeps the original public API ([appointment], [onTap], [trailing],
/// [showDate]) so existing call sites continue to work.
class AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDate;

  /// Outer padding around the card. Defaults to list spacing; callers that
  /// manage their own horizontal insets (e.g. the dashboard) can override.
  final EdgeInsetsGeometry? padding;

  const AppointmentTile({
    super.key,
    required this.appointment,
    this.onTap,
    this.trailing,
    this.showDate = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final service = context.watch<AppointmentService>();
    final locale = Localizations.localeOf(context).toString();
    final l10n = AppLocalizations.of(context)!;

    final customerName = appointment.customerId != null
        ? service.getCustomer(appointment.customerId!)?.fullName ??
            l10n.unknownUser
        : appointment.guestName ?? l10n.unknownUser;

    final start = appointment.dateTime.toLocal();
    final end = start.add(appointment.duration);
    final timeRange =
        '${DateFormat.jm(locale).format(start)} – ${DateFormat.jm(locale).format(end)}';
    final dateLabel =
        showDate ? DateFormat.MMMEd(locale).format(start) : null;

    final priceStr = appointment.totalPrice != null
        ? NumberFormat.simpleCurrency(locale: locale)
            .format(appointment.totalPrice)
        : null;

    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppTokens.space,
            vertical: AppTokens.spaceSm,
          ),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceAvatar(type: appointment.service),
            const SizedBox(width: AppTokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          serviceTypeLabel(context, appointment.service),
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (priceStr != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.12),
                            borderRadius: AppTokens.pillRadius,
                          ),
                          child: Text(
                            priceStr,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _IconLine(
                    icon: Icons.schedule,
                    text: dateLabel != null
                        ? '$dateLabel · $timeRange'
                        : timeRange,
                  ),
                  const SizedBox(height: 2),
                  _IconLine(
                    icon: Icons.person_outline,
                    text: customerName,
                  ),
                  if (appointment.location != null &&
                      appointment.location!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    _IconLine(
                      icon: Icons.place_outlined,
                      text: appointment.location!,
                    ),
                  ],
                  if (appointment.addOns.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    _IconLine(
                      icon: Icons.add_circle_outline,
                      text: l10n.addOnsSummary(
                        appointment.addOns.map((a) => a.name).join(', '),
                      ),
                    ),
                  ],
                  if (appointment.bufferDuration > Duration.zero) ...[
                    const SizedBox(height: 2),
                    _IconLine(
                      icon: Icons.timelapse_outlined,
                      text: l10n.bufferMinutesSummary(
                        appointment.bufferDuration.inMinutes,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
