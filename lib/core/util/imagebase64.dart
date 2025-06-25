import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<String?> pickImageAsBase64() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    final bytes = await File(pickedFile.path).readAsBytes();
    return base64Encode(bytes);
  }
  return null;
}
