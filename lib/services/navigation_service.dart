import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  const NavigationService();

  ///=========================================
  /// فتح الملاحة إلى المحطة
  ///=========================================
  Future<void> navigateToStation(
      double latitude,
      double longitude,
      ) async {
    final Uri googleMapsUri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1"
          "&destination=$latitude,$longitude"
          "&travelmode=driving",
    );

    try {
      final bool canLaunch = await canLaunchUrl(
        googleMapsUri,
      );

      if (!canLaunch) {
        throw Exception(
          "تعذر فتح تطبيق Google Maps.",
        );
      }

      final bool launched = await launchUrl(
        googleMapsUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception(
          "فشل تشغيل تطبيق الملاحة.",
        );
      }
    } catch (e) {
      throw Exception(
        "حدث خطأ أثناء فتح الملاحة:\n$e",
      );
    }
  }

  ///=========================================
  /// فتح موقع المحطة فقط (بدون ملاحة)
  ///=========================================
  Future<void> openLocation(
      double latitude,
      double longitude,
      ) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1"
          "&query=$latitude,$longitude",
    );

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception(
          "تعذر فتح موقع المحطة.",
        );
      }
    } catch (e) {
      throw Exception(
        "حدث خطأ أثناء فتح الموقع:\n$e",
      );
    }
  }

  ///=========================================
  /// فتح الموقع داخل المتصفح
  ///=========================================
  Future<void> openInBrowser(
      double latitude,
      double longitude,
      ) async {
    final Uri uri = Uri.parse(
      "https://maps.google.com/?q=$latitude,$longitude",
    );

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched) {
        throw Exception(
          "تعذر فتح المتصفح.",
        );
      }
    } catch (e) {
      throw Exception(
        "حدث خطأ:\n$e",
      );
    }
  }
  ///=========================================
  /// فتح Google Maps (متوافق مع جميع الشاشات)
  ///=========================================
  Future<void> openGoogleMaps(
      double latitude,
      double longitude,
      ) async {
    await navigateToStation(
      latitude,
      longitude,
    );
  }
}