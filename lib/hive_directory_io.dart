import 'dart:io';

Future<void> ensureHiveDirectoryExists(String path) async {
  await Directory(path).create(recursive: true);
}
