import 'package:flutter/material.dart';

import '../../models/service_type.dart';
import '../../utils/service_type_utils.dart';

/// A rounded badge representing a [ServiceType] using its accent colour and
/// icon. Used in lists, cards and the dashboard.
class ServiceAvatar extends StatelessWidget {
  const ServiceAvatar({
    super.key,
    required this.type,
    this.size = 48,
  });

  final ServiceType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = serviceTypeColor(type);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.18)!],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Center(
        child: ImageIcon(
          AssetImage(serviceTypeIcon(type)),
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}
