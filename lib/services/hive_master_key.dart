import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Secure-storage key name (historically created for the auth box; now shared
/// for all encrypted Hive stores on this device).
const hiveMasterKeyStorageId = 'authEncryptionKey';

/// Returns the existing AES key bytes or generates and persists a new one.
Future<List<int>> getOrCreateHiveMasterKey({
  FlutterSecureStorage? secureStorage,
}) async {
  final storage = secureStorage ?? const FlutterSecureStorage();
  final stored = await storage.read(key: hiveMasterKeyStorageId);
  if (stored != null) {
    return base64Url.decode(stored);
  }
  final key = Hive.generateSecureKey();
  await storage.write(
    key: hiveMasterKeyStorageId,
    value: base64UrlEncode(key),
  );
  return key;
}
