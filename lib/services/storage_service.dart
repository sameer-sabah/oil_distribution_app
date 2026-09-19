import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  final FirebaseStorage storage = FirebaseStorage.instance;

  // =====================================================
  // رفع صورة عامة
  // =====================================================

  Future<String> uploadImage({
    required File file,
    required String folder,
  }) async {
    // ---------------------------------------------------
    // 1. التأكد من وجود الملف
    // ---------------------------------------------------

    if (!await file.exists()) {
      throw Exception('ملف الصورة غير موجود');
    }

    final int fileSize = await file.length();

    if (fileSize == 0) {
      throw Exception('ملف الصورة فارغ');
    }

    // ---------------------------------------------------
    // 2. تحديد الامتداد
    // ---------------------------------------------------

    final String extension = _getExtension(file.path);

    // ---------------------------------------------------
    // 3. إنشاء اسم فريد
    // ---------------------------------------------------

    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().hashCode}.$extension';

    // ---------------------------------------------------
    // 4. تنظيف اسم المجلد
    // ---------------------------------------------------

    final String cleanFolder = folder
        .trim()
        .replaceAll(RegExp(r'^/+|/+$'), '');

    final String path = '$cleanFolder/$fileName';

    // ---------------------------------------------------
    // 5. إنشاء Reference
    // ---------------------------------------------------

    final Reference ref = storage.ref().child(path);

    final SettableMetadata metadata = SettableMetadata(
      contentType: _getContentType(extension),
      cacheControl: 'public,max-age=31536000',
    );

    debugPrint('========================================');
    debugPrint('FIREBASE STORAGE');
    debugPrint('Bucket: ${storage.bucket}');
    debugPrint('Path: ${ref.fullPath}');
    debugPrint('Name: ${ref.name}');
    debugPrint('File: ${file.path}');
    debugPrint('Size: $fileSize bytes');
    debugPrint('Content-Type: ${metadata.contentType}');
    debugPrint('========================================');

    try {
      // =================================================
      // 6. بدء الرفع
      // =================================================

      final UploadTask uploadTask = ref.putFile(
        file,
        metadata,
      );

      // -------------------------------------------------
      // مراقبة الرفع
      // -------------------------------------------------

      uploadTask.snapshotEvents.listen(
            (TaskSnapshot snapshot) {
          final int total = snapshot.totalBytes;

          if (total > 0) {
            final double progress =
                (snapshot.bytesTransferred / total) * 100;

            debugPrint(
              'Upload progress: ${progress.toStringAsFixed(1)}%',
            );
          }

          debugPrint(
            'Upload state: ${snapshot.state}',
          );
        },
        onError: (Object error) {
          debugPrint(
            'Upload stream error: $error',
          );
        },
      );

      // =================================================
      // 7. انتظار انتهاء الرفع
      // =================================================

      final TaskSnapshot snapshot = await uploadTask;

      debugPrint(
        'Upload completed with state: ${snapshot.state}',
      );

      // -------------------------------------------------
      // 8. التأكد أن الرفع نجح فعلاً
      // -------------------------------------------------

      if (snapshot.state != TaskState.success) {
        throw Exception(
          'رفع الصورة لم يكتمل.\n'
              'الحالة: ${snapshot.state}',
        );
      }

      debugPrint('✅ تم رفع الملف بنجاح');
      debugPrint('Full path: ${snapshot.ref.fullPath}');

      // =================================================
      // 9. الحصول على رابط التحميل
      // =================================================

      String downloadUrl;

      try {
        debugPrint('محاولة الحصول على Download URL...');

        downloadUrl = await ref.getDownloadURL();

        debugPrint('✅ تم الحصول على Download URL');
        debugPrint(downloadUrl);
      } on FirebaseException catch (e) {
        debugPrint('========================================');
        debugPrint('GET DOWNLOAD URL ERROR');
        debugPrint('Code: ${e.code}');
        debugPrint('Message: ${e.message}');
        debugPrint('Path: ${ref.fullPath}');
        debugPrint('Bucket: ${storage.bucket}');
        debugPrint('========================================');
        throw Exception(
          'تم رفع الصورة إلى Storage، '
              'لكن فشل الحصول على رابط الصورة.\n'
              'Code: ${e.code}\n'
              '${e.message ?? ''}',
        );
      }
      // =================================================
      // 10. إرجاع الرابط
      // =================================================
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('========================================');
      debugPrint('FIREBASE STORAGE ERROR');
      debugPrint('Code: ${e.code}');
      debugPrint('Message: ${e.message}');
      debugPrint('Bucket: ${storage.bucket}');
      debugPrint('Path: ${ref.fullPath}');
      debugPrint('========================================');
      throw Exception(
        'خطأ Firebase Storage\n'
            'Code: ${e.code}\n'
            '${e.message ?? ''}',
      );
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('STORAGE GENERAL ERROR');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('========================================');
      throw Exception(
        'حدث خطأ أثناء رفع الصورة:\n${e.toString()}',
      );
    }
  }
  // =====================================================
  // صورة مدير المحطة
  // =====================================================

  Future<String> uploadManagerPhoto(File file) {
    return uploadImage(
      file: file,
      folder: 'station_managers',
    );
  }
  // =====================================================
  // صورة المحطة
  // =====================================================

  Future<String> uploadStationPhoto(File file) {
    return uploadImage(
      file: file,
      folder: 'stations',
    );
  }

  // =====================================================
  // صورة طلب تغيير كلمة المرور
  // =====================================================

  Future<String> uploadPasswordResetPhoto(File file) {
    return uploadImage(
      file: file,
      folder: 'password_reset_requests',
    );
  }

  // =====================================================
  // حذف صورة
  // =====================================================

  Future<void> deleteImage(String url) async {
    if (url.trim().isEmpty) {
      return;
    }

    try {
      final Reference ref = storage.refFromURL(url);

      debugPrint('حذف الصورة: ${ref.fullPath}');

      await ref.delete();

      debugPrint('✅ تم حذف الصورة');
    } on FirebaseException catch (e) {
      debugPrint(
        'خطأ حذف الصورة: ${e.code} - ${e.message}',
      );
    } catch (e) {
      debugPrint(
        'Delete image error: $e',
      );
    }
  }

  // =====================================================
  // الامتداد
  // =====================================================

  String _getExtension(String path) {
    final String name =
        path.split(Platform.pathSeparator).last;

    if (!name.contains('.')) {
      return 'jpg';
    }

    final String extension =
    name.split('.').last.toLowerCase();

    switch (extension) {
      case 'png':
        return 'png';

      case 'webp':
        return 'webp';

      case 'heic':
        return 'heic';

      case 'jpeg':
        return 'jpeg';

      case 'jpg':
        return 'jpg';

      default:
        return 'jpg';
    }
  }

  // =====================================================
  // Content Type
  // =====================================================

  String _getContentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'heic':
        return 'image/heic';

      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}