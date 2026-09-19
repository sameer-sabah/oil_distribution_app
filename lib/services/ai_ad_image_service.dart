import 'dart:convert';

import 'package:http/http.dart'
as http;

import '../models/ad_image_generation_request.dart';
import '../models/ad_image_generation_result.dart';

class AiAdImageService {
  AiAdImageService._();

  static final AiAdImageService instance =
  AiAdImageService._();

  static const String _baseUrl =
  String.fromEnvironment(
    'AI_AD_BACKEND_URL',
  );

  Future<AdImageGenerationResult>
  generateImage(
      AdImageGenerationRequest request,
      ) async {
    if (_baseUrl.trim().isEmpty) {
      return const AdImageGenerationResult(
        success: false,
        imageUrl: '',
        message:
        'خدمة إنشاء الصور بالذكاء الاصطناعي غير مربوطة بعد.',
      );
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl/generate-ad-image',
      );

      final response =
      await http
          .post(
        uri,
        headers: const {
          'Content-Type':
          'application/json',
        },
        body: jsonEncode(
          request.toJson(),
        ),
      )
          .timeout(
        const Duration(
          seconds: 90,
        ),
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return AdImageGenerationResult(
          success: false,
          imageUrl: '',
          message:
          'فشل توليد الصورة. رمز الخطأ: ${response.statusCode}',
        );
      }

      final decoded =
      jsonDecode(
        response.body,
      );

      if (decoded
      is! Map<String, dynamic>) {
        return const AdImageGenerationResult(
          success: false,
          imageUrl: '',
          message:
          'استجابة خدمة الذكاء الاصطناعي غير صحيحة.',
        );
      }

      return AdImageGenerationResult
          .fromJson(
        decoded,
      );
    } catch (e) {
      return AdImageGenerationResult(
        success: false,
        imageUrl: '',
        message:
        'تعذر الاتصال بخدمة الذكاء الاصطناعي: $e',
      );
    }
  }
}