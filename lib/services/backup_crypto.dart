import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Encrypts UTF-8 text for cloud backup using the same 32-byte key as Hive AES.
Future<String> encryptBackupUtf8(String plaintext, List<int> keyBytes) async {
  if (keyBytes.length != 32) {
    throw ArgumentError.value(keyBytes.length, 'keyBytes', 'expected 32 bytes');
  }
  final algorithm = AesGcm.with256bits();
  final secretKey = SecretKey(keyBytes);
  final box = await algorithm.encrypt(
    utf8.encode(plaintext),
    secretKey: secretKey,
  );
  return jsonEncode({
    'vv': 1,
    'alg': 'aes256gcm',
    'nonce': base64Encode(box.nonce),
    'ct': base64Encode(box.cipherText),
    'mac': base64Encode(box.mac.bytes),
  });
}
