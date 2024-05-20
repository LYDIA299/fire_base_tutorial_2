import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _imagePicker = ImagePicker();

  MediaService() {}

  Future<File?> getImageFromGallery() async {
    final XFile? _xfile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (_xfile != null) {
      return File(_xfile.path);
    }
    return null;
  }
}
