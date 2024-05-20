import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  StorageService() {}

  Future<String?> uploadUserPfp(
      {required File file, required String uid}) async {
    Reference _fileRef = _firebaseStorage
        .ref('users/pfps')
        .child('$uid${p.extension(file.path)}');
    UploadTask task = _fileRef.putFile(file);
    return task.then((p) {
      if (p.state == TaskState.success) {
        return _fileRef.getDownloadURL();
      }
    });
  }

  Future<String?> uploadImageToChat(
      {required File file, required String chatID}) async {
    Reference _fileRef = _firebaseStorage.ref('chats/$chatID').child(
          '${DateTime.now().toIso8601String()}${p.extension(file.path)}',
        );

    UploadTask task = _fileRef.putFile(file);
    return task.then((p) {
      if (p.state == TaskState.success) {
        return _fileRef.getDownloadURL();
      }
    });
  }
}