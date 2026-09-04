import 'dart:io';

import 'package:flutter/material.dart' show ChangeNotifier;

class UploadFileController extends ChangeNotifier {
  File? _image;

  File? getImage() => _image;

  set image(File image) {
    _image = image;
    notifyListeners();
  }
}
