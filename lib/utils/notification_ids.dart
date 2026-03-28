/// Stable positive notification id derived from [appointmentId] (typically a UUID).
int stableNotificationId(String appointmentId) {
  final hex = appointmentId.replaceAll('-', '');
  if (hex.length >= 8 &&
      RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex.substring(0, 8))) {
    return int.parse(hex.substring(0, 8), radix: 16) & 0x7fffffff;
  }
  return appointmentId.hashCode & 0x7fffffff;
}
