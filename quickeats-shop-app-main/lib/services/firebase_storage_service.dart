import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String fileName, String folderName) async {
    try {
      Reference ref = _storage.ref().child(
          '$folderName/${fileName.contains('.') ? fileName : '$fileName${extension(file.path)}'}');
      // Upload the file to Firebase Storage
      UploadTask uploadTask = ref.putFile(file);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }
}
