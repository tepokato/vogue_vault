import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'avatar_image_stub.dart'
    if (dart.library.io) 'avatar_image_io.dart';

/// Returns an [ImageProvider] for the given [path].
///
/// On mobile platforms a [FileImage] is used.
/// On web, [NetworkImage] is used for URLs while base64-encoded data URLs
/// are decoded into a [MemoryImage].
ImageProvider? avatarImage(String? path) {
  if (path == null || path.isEmpty) return null;

  if (kIsWeb) {
    if (path.startsWith('data:')) {
      final base64Data = path.split(',').last;
      return MemoryImage(base64Decode(base64Data));
    }
    return NetworkImage(path);
  }
  return fileImage(path);
}
