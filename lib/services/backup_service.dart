import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../models/address.dart';
import '../models/appointment.dart';
import '../models/customer.dart';
import '../models/user_profile.dart';
import 'appointment_service.dart';

class BackupService extends ChangeNotifier {
  BackupService(this._appointmentService);

  final AppointmentService _appointmentService;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
      drive.DriveApi.driveFileScope,
    ],
  );

  bool _isBackingUp = false;
  DateTime? _lastBackupAt;
  String? _lastError;

  bool get isBackingUp => _isBackingUp;

  DateTime? get lastBackupAt => _lastBackupAt;

  String? get lastError => _lastError;

  Future<void> backUpToGoogleDrive() async {
    if (_isBackingUp) return;

    _isBackingUp = true;
    _lastError = null;
    notifyListeners();

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw StateError('Sign-in aborted');
      }

      final authHeaders = await account.authHeaders;
      final client = _GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(client);

      final backupPayload = _buildBackupPayload();
      final bytes = utf8.encode(jsonEncode(backupPayload));
      final media = drive.Media(Stream<List<int>>.value(bytes), bytes.length);

      final file = drive.File()
        ..name = 'vogue_vault_backup.json'
        ..parents = ['appDataFolder']
        ..mimeType = 'application/json';

      await driveApi.files.create(
        file,
        uploadMedia: media,
        $fields: 'id',
      );

      _lastBackupAt = DateTime.now();
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    } finally {
      _isBackingUp = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _buildBackupPayload() {
    final appointments = _appointmentService.appointments
        .map<Map<String, dynamic>>((appointment) => appointment.toMap())
        .toList();
    final customers = _appointmentService.customers
        .map<Map<String, dynamic>>((customer) => customer.toMap())
        .toList();
    final providers = _appointmentService.users
        .map<Map<String, dynamic>>((user) => user.toMap())
        .toList();
    final addresses = _appointmentService.addresses
        .map<Map<String, dynamic>>((address) => address.toMap())
        .toList();

    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'appointments': appointments,
      'customers': customers,
      'providers': providers,
      'addresses': addresses,
    };
  }
}

class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
