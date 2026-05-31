import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'hive_directory_stub.dart'
    if (dart.library.io) 'hive_directory_io.dart';

/// Hive boxes live under `<application_documents>/vogue_vault/hive/` so the
/// user’s Documents directory is not littered with `.hive` files at the root.
const String kHiveStorageSubDir = 'vogue_vault/hive';

Future<void> initHiveStorage() async {
  if (kIsWeb) return;

  final appDir = await getApplicationDocumentsDirectory();
  final hivePath = p.join(appDir.path, kHiveStorageSubDir);
  await ensureHiveDirectoryExists(hivePath);
  Hive.init(hivePath);
}
