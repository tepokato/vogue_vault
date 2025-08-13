

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

// Returns whether image picking is supported on the current platform.
bool get isImagePickerSupported =>
    kIsWeb ||
    const {
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    }.contains(defaultTargetPlatform);

/// Picks an image and returns its bytes, or null if the user cancels or
/// the platform is unsupported.
Future<Uint8List?> pickImageBytes() async {
  if (!isImagePickerSupported) return null;

  XFile? file;
  if (kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    file = await ImagePicker().pickImage(source: ImageSource.gallery);
  } else {
    file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'images',
          extensions: ['jpg', 'jpeg', 'png', 'gif'],
        ),
      ],
    );
  }

  return file?.readAsBytes();
}
