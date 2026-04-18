import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// 📦 Service xử lý Firebase Storage (lưu ảnh)
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload ảnh avatar người dùng
  Future<String> uploadAvatar(String uid, File file) async {
    try {
      final ref = _storage.ref().child('avatars/$uid.jpg');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw 'Lỗi upload avatar: $e';
    }
  }

  /// Upload ảnh từ vựng (cho admin)
  Future<String> uploadVocabImage(String vocabId, File file) async {
    try {
      final ref = _storage.ref().child('vocab_images/$vocabId.jpg');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw 'Lỗi upload ảnh: $e';
    }
  }

  /// Lấy URL ảnh theo path
  Future<String> getImageUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  /// Xóa file
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }
}