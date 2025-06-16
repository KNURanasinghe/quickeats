import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shop_app/services/dialog_service.dart';

class ImageService {
  Future<void> pickImage(ImageSource source, Function(File?) setImage) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();
      final fileExtension = path.extension(file.path).toLowerCase();

      if (fileSize > 5 * 1024 * 1024) {
        showMessageDialog('Maximum file size is 5 MB');
        return;
      }

      if (fileExtension == '.jpg' ||
          fileExtension == '.jpeg' ||
          fileExtension == '.png') {
        setImage(file);
      } else {
        showMessageDialog('Only JPEG and PNG files are allowed');
      }
    }
  }
}
