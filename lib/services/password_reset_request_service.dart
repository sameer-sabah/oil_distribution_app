import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PasswordResetRequestService {
  PasswordResetRequestService._();

  static final PasswordResetRequestService instance =
  PasswordResetRequestService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  final FirebaseFunctions _functions =
      FirebaseFunctions.instance;

  Future<String?> createRequest({
    required String username,
    required File photo,
  }) async {
    try {
      final String cleanUsername = username.trim();

      // التحقق من اسم المستخدم
      if (cleanUsername.isEmpty) {
        return 'أدخل اسم المستخدم';
      }

      // التحقق من وجود الصورة
      if (!await photo.exists()) {
        return 'الصورة غير موجودة';
      }

      // =====================================================
      // 1. تسجيل دخول مجهول مؤقت
      // =====================================================

      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }

      // =====================================================
      // 2. إنشاء معرف مؤقت للصورة
      // =====================================================

      final String temporaryId =
      DateTime.now().millisecondsSinceEpoch.toString();

      // =====================================================
      // 3. رفع الصورة إلى Firebase Storage
      // =====================================================

      final Reference storageRef = _storage
          .ref()
          .child('password_reset_requests')
          .child(temporaryId)
          .child('verification_photo.jpg');

      await storageRef.putFile(
        photo,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      // =====================================================
      // 4. الحصول على رابط الصورة
      // =====================================================

      final String verificationPhotoUrl =
      await storageRef.getDownloadURL();

      // =====================================================
      // 5. استدعاء Cloud Function
      // =====================================================

      final HttpsCallable callable =
      _functions.httpsCallable(
        'createPasswordResetRequest',
      );

      final HttpsCallableResult result =
      await callable.call(
        <String, dynamic>{
          'username': cleanUsername,
          'verificationPhotoUrl':
          verificationPhotoUrl,
        },
      );

      // =====================================================
      // 6. قراءة نتيجة Cloud Function
      // =====================================================

      if (result.data == null) {
        return 'لم تصل استجابة من الخادم';
      }

      if (result.data is! Map) {
        return 'استجابة الخادم غير صحيحة';
      }

      final Map<dynamic, dynamic> response =
      result.data as Map<dynamic, dynamic>;

      final bool success =
          response['success'] == true;

      if (!success) {
        return 'تعذر إنشاء طلب تغيير كلمة المرور';
      }

      return null;
    }

    // =======================================================
    // أخطاء Firebase بشكل عام
    // لا نستخدم FirebaseFunctionsException هنا
    // =======================================================

    on FirebaseException catch (e) {
      final String code = e.code.toLowerCase();

      if (code == 'permission-denied' ||
          code == 'unauthorized') {
        return 'ليس لديك صلاحية لتنفيذ العملية';
      }

      if (code == 'unauthenticated') {
        return 'تعذر تسجيل الدخول المؤقت';
      }

      if (code == 'not-found') {
        return 'اسم المستخدم غير موجود';
      }

      if (code == 'invalid-argument') {
        return 'بيانات الطلب غير صحيحة';
      }

      if (code == 'internal') {
        return 'حدث خطأ داخل خادم النظام';
      }

      return e.message ??
          'حدث خطأ في Firebase';
    }

    // =======================================================
    // أي خطأ آخر
    // =======================================================

    catch (e) {
      return 'حدث خطأ أثناء إرسال طلب تغيير كلمة المرور';
    }
  }
}