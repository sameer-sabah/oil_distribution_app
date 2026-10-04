import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/station.dart';
import '../services/station_service.dart';
import '../services/navigation_service.dart';
import '../services/auth_service.dart';
import 'notifications_screen.dart';
import 'oil_coupon/vehicle_login_screen.dart';
import '../widgets/commercial_ad_banner.dart';
import '../widgets/commercial_ad_inline_card.dart';
import '../l10n/app_localizations.dart';

class _StationIllustration extends StatelessWidget {
  const _StationIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 12,
          left: 14,
          right: 14,
          child: Container(
            height: 9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Positioned(
          top: 21,
          left: 20,
          right: 20,
          bottom: 17,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .95),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 13,
                  height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFF087F3D),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_gas_station_rounded,
                      color: Color(0xFF087F3D),
                      size: 25,
                    ),
                    Container(
                      width: 25,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF087F3D),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 13,
                  height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFF087F3D),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 25,
          bottom: 6,
          child: Icon(
            Icons.directions_car_filled_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const Positioned(
          right: 23,
          bottom: 6,
          child: Icon(
            Icons.directions_car_filled_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class CitizenScreen extends StatefulWidget {
  const CitizenScreen({
    super.key,
  });

  @override
  State<CitizenScreen> createState() =>
      _CitizenScreenState();
}

class _CitizenScreenState
    extends State<CitizenScreen> {
  String productName(String key) {
    if (key == 'all') {
      return _tr('allProducts');
    }
    final l10n = AppLocalizations.of(context)!;

    switch (key) {
      case 'regular95':
        return l10n.regular95;

      case 'improved95':
        return l10n.improved95;

      case 'super95':
        return l10n.super95;

      case 'diesel':
        return l10n.diesel;

      case 'whiteOil':
        return l10n.whiteOil;

      case 'lpg':
        return l10n.lpg;

      default:
        return key;
    }
  }
  String _tr(String key) {
    final lang = Localizations.localeOf(context).languageCode;

    const translations = <String, Map<String, String>>{
      'ar': {
        'notifications': 'الإشعارات',
        'refresh': 'تحديث',
        'currentLocation': 'موقعك الحالي',
        'enableLocation': 'فعّل الموقع لمعرفة الأقرب',
        'chooseProduct': 'اختر نوع المنتوج',
        'allProducts': 'جميع المنتجات',
        'emergency911': 'الطوارئ 911',
        'importantAlert': 'تنبيه مهم للمواطن',
        'availableNearby': 'المحطات المتوفرة والقريبة منك',
        'nearestFirst': 'مرتبة من الأقرب إلى الأبعد',
        'tryAgain': 'جرّب تغيير نوع المنتوج أو البحث عن منطقة أخرى',
        'notSpecified': 'غير محددة',
        'liters': 'لتر',
        'details': 'التفاصيل',
        'startNavigation': 'المسار',
        'stationOpen': 'المحطة مفتوحة',
        'stationClosed': 'المحطة مغلقة',
        'stationDuty': 'محطة خافرة',
        'dutyStations': 'المحطات الخافرة',
        'allStations': 'جميع المحطات',
        'openStations': 'المفتوحة',
        'lastUpdate': 'آخر تحديث',
        'governorate': 'المحافظة',
        'district': 'القضاء',
        'stationType': 'نوع المحطة',
        'noProducts': 'لا توجد منتجات متاحة حاليًا',
        'stationStatus': 'حالة المحطة',
        'lastQuantityUpdate': 'آخر تحديث للكميات',
        'noUpdate': 'لا يوجد تحديث',
        'address': 'العنوان',
        'phone': 'الهاتف',
        'close': 'إغلاق',
        'call911': 'اتصال 911',
        'emergencyMessage': 'عند حدوث حالة طارئة أو خطر، اتصل بالرقم 911 فوراً.',
        'searchStation': 'البحث عن محطة أو منطقة...',
        'noStations': 'لا توجد محطات متوفرة حالياً',
        'available': 'متوفر',
        'unavailable': 'غير متوفر',
        'locationError': 'تعذر تحميل المحطات',
        'updateError': 'تعذر تحديث البيانات',
        'emergencyCallError': 'تعذر فتح الاتصال بالطوارئ',
        'emergencyConnectionError': 'تعذر الاتصال بالطوارئ',
        'coordinatesMissing': 'إحداثيات المحطة غير موجودة',
        'navigationError': 'تعذر فتح الملاحة',
      },
      'en': {
        'notifications': 'Notifications',
        'refresh': 'Refresh',
        'currentLocation': 'Your current location',
        'enableLocation': 'Enable location to find the nearest',
        'chooseProduct': 'Choose product',
        'allProducts': 'All Products',
        'emergency911': 'Emergency 911',
        'importantAlert': 'Important citizen alert',
        'searchStation': 'Search for a station or area...',
        'availableNearby': 'Available stations near you',
        'nearestFirst': 'Sorted from nearest to farthest',
        'noStations': 'No stations are currently available',
        'tryAgain': 'Try changing the product or searching another area',
        'available': 'Available',
        'unavailable': 'Unavailable',
        'notSpecified': 'Not specified',
        'liters': 'liters',
        'details': 'Details',
        'startNavigation': 'Start navigation',
        'stationOpen': 'Station is open',
        'stationClosed': 'Station is closed',
        'stationDuty': 'On-Duty Station',
        'dutyStations': 'Duty Stations',
        'allStations': 'All Stations',
        'openStations': 'Open Stations',
        'lastUpdate': 'Last update',
        'governorate': 'Governorate',
        'district': 'District',
        'stationType': 'Station type',
        'noProducts': 'No products are currently available',
        'stationStatus': 'Station status',
        'lastQuantityUpdate': 'Last quantity update',
        'noUpdate': 'No update',
        'address': 'Address',
        'phone': 'Phone',
        'close': 'Close',
        'call911': 'Call 911',
        'emergencyMessage': 'In an emergency or danger, call 911 immediately.',
        'locationError': 'Unable to load stations',
        'updateError': 'Unable to update data',
        'emergencyCallError': 'Unable to open emergency call',
        'emergencyConnectionError': 'Unable to connect to emergency services',
        'coordinatesMissing': 'Station coordinates are unavailable',
        'navigationError': 'Unable to open navigation',
      },
      'ku': {
        'notifications': 'ئاگادارکردنەوەکان',
        'refresh': 'نوێکردنەوە',
        'currentLocation': 'شوێنی ئێستات',
        'enableLocation': 'شوێن چالاک بکە بۆ دۆزینەوەی نزیکترین',
        'chooseProduct': 'جۆری بەرهەم هەڵبژێرە',
        'allProducts': 'هەموو بەرهەمەکان',
        'emergency911': 'فریاکەوتن 911',
        'importantAlert': 'ئاگادارییەکی گرنگ بۆ هاووڵاتی',
        'searchStation': 'بگەڕێ بۆ بەنزینخانە یان ناوچە...',
        'availableNearby': 'بەنزینخانە بەردەستە نزیکەکانت',
        'nearestFirst': 'لە نزیکترینەوە بۆ دوورترین',
        'noStations': 'لە ئێستادا هیچ بەنزینخانەیەک بەردەست نییە',
        'tryAgain': 'جۆری بەرهەم بگۆڕە یان ناوچەیەکی تر بگەڕێ',
        'available': 'بەردەستە',
        'unavailable': 'بەردەست نییە',
        'notSpecified': 'دیارینەکراوە',
        'liters': 'لیتر',
        'details': 'وردەکاری',
        'startNavigation': 'دەستپێکردنی ڕێنیشاندان',
        'stationOpen': 'بەنزینخانە کراوەیە',
        'stationClosed': 'بەنزینخانە داخراوە',
        'stationDuty': 'بەنزینخانەی خافڕ',
        'dutyStations': 'بەنزینخانە خافڕەکان',
        'allStations': 'هەموو بەنزینخانەکان',
        'openStations': 'کراوەکان',
        'lastUpdate': 'دوایین نوێکردنەوە',
        'governorate': 'پارێزگا',
        'district': 'قەزا',
        'stationType': 'جۆری بەنزینخانە',
        'noProducts': 'هیچ بەرهەمێک لە ئێستادا بەردەست نییە',
        'stationStatus': 'دۆخی بەنزینخانە',
        'lastQuantityUpdate': 'دوایین نوێکردنەوەی بڕەکان',
        'noUpdate': 'هیچ نوێکردنەوەیەک نییە',
        'address': 'ناونیشان',
        'phone': 'تەلەفۆن',
        'close': 'داخستن',
        'call911': 'پەیوەندی بە 911',
        'emergencyMessage': 'لە کاتی دۆخی فریاکەوتن یان مەترسیدا، دەستبەجێ پەیوەندی بە 911 بکە.',
        'locationError': 'نەتوانرا بەنزینخانەکان باربکرێن',
        'updateError': 'نەتوانرا داتا نوێ بکرێتەوە',
        'emergencyCallError': 'نەتوانرا پەیوەندی فریاکەوتن بکرێتەوە',
        'emergencyConnectionError': 'نەتوانرا پەیوەندی بە فریاکەوتنەکانەوە بکرێت',
        'coordinatesMissing': 'ئیکۆردیناتەکانی بەنزینخانە بەردەست نین',
        'navigationError': 'نەتوانرا ڕێنیشاندان بکرێتەوە',
      },
      'fa': {
        'notifications': 'اعلان‌ها',
        'refresh': 'به‌روزرسانی',
        'currentLocation': 'موقعیت فعلی شما',
        'enableLocation': 'موقعیت را فعال کنید تا نزدیک‌ترین را پیدا کنید',
        'chooseProduct': 'نوع محصول را انتخاب کنید',
        'allProducts': 'همه محصولات',
        'emergency911': 'اورژانس ۹۱۱',
        'importantAlert': 'هشدار مهم برای شهروند',
        'searchStation': 'جستجوی جایگاه یا منطقه...',
        'availableNearby': 'جایگاه‌های موجود و نزدیک شما',
        'nearestFirst': 'مرتب‌شده از نزدیک‌ترین تا دورترین',
        'noStations': 'در حال حاضر جایگاهی موجود نیست',
        'tryAgain': 'نوع محصول را تغییر دهید یا منطقه دیگری را جستجو کنید',
        'available': 'موجود',
        'unavailable': 'ناموجود',
        'notSpecified': 'نامشخص',
        'liters': 'لیتر',
        'details': 'جزئیات',
        'startNavigation': 'شروع مسیریابی',
        'stationOpen': 'جایگاه باز است',
        'stationClosed': 'جایگاه بسته است',
        'stationDuty': 'جایگاه کشیک',
        'dutyStations': 'جایگاه‌های کشیک',
        'allStations': 'همه جایگاه‌ها',
        'openStations': 'باز',
        'lastUpdate': 'آخرین به‌روزرسانی',
        'governorate': 'استان',
        'district': 'شهرستان',
        'stationType': 'نوع جایگاه',
        'noProducts': 'در حال حاضر محصولی موجود نیست',
        'stationStatus': 'وضعیت جایگاه',
        'lastQuantityUpdate': 'آخرین به‌روزرسانی مقدارها',
        'noUpdate': 'بدون به‌روزرسانی',
        'address': 'آدرس',
        'phone': 'تلفن',
        'close': 'بستن',
        'call911': 'تماس با ۹۱۱',
        'emergencyMessage': 'در صورت بروز وضعیت اضطراری یا خطر، فوراً با ۹۱۱ تماس بگیرید.',
        'locationError': 'بارگذاری جایگاه‌ها امکان‌پذیر نیست',
        'updateError': 'به‌روزرسانی اطلاعات امکان‌پذیر نیست',
        'emergencyCallError': 'باز کردن تماس اضطراری امکان‌پذیر نیست',
        'emergencyConnectionError': 'اتصال به خدمات اضطراری امکان‌پذیر نیست',
        'coordinatesMissing': 'مختصات جایگاه موجود نیست',
        'navigationError': 'باز کردن مسیریابی امکان‌پذیر نیست',
      },
    };

    return translations[lang]?[key] ?? translations['ar']![key] ?? key;
  }

  final StationService stationService =
      StationService.instance;

  final AuthService auth =
      AuthService.instance;

  List<Station> stations = [];

  List<Station> filteredStations = [];

  StreamSubscription? stationSubscription;

  bool loading = true;

  bool locationLoading = false;

  double? userLatitude;

  double? userLongitude;

  String search = "";

  String selectedStatusFilter = "all";

  String selectedProduct = "all";

  final products = const [
    'all',
    'regular95',
    'improved95',
    'super95',
    'diesel',
    'whiteOil',
    'lpg',
  ];

  @override
  void initState() {
    super.initState();

    getLocation();

    listenStations();
  }

  // =========================================================
  // البث المباشر للمحطات
  // =========================================================

  void listenStations() {
    stationSubscription =
        stationService.citizenStationsStream().listen(
              (data) {

            stations = data.where((station) {
              return station.active &&
                  station.approved &&
                  station.status != "deleted";
            }).toList();

            filterStations();

            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          },
          onError: (error) {
            if (!mounted) return;

            setState(() {
              loading = false;
            });

            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  "تعذر تحميل المحطات: $error",
                ),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
  }

  // =========================================================
  // تحديث البيانات
  // =========================================================

  Future<void> loadData() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      await getLocation();

      final data =
      await stationService.getCitizenStations();

      stations = data.where((station) {
        return station.active &&
            station.approved &&
            station.status != "deleted";
      }).toList();

      filterStations();

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "${_tr('updateError')}: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // تحديد موقع المواطن
  // =========================================================

  Future<void> getLocation() async {
    if (mounted) {
      setState(() {
        locationLoading = true;
      });
    }

    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          locationLoading = false;
        });

        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          locationLoading = false;
        });

        return;
      }

      final position =
      await Geolocator.getCurrentPosition();

      userLatitude = position.latitude;

      userLongitude = position.longitude;

      filterStations();

      if (!mounted) return;

      setState(() {
        locationLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        locationLoading = false;
      });
    }
  }

  // =========================================================
  // حساب المسافة
  // =========================================================

  double distanceFromUser(
      Station station,
      ) {
    if (userLatitude == null ||
        userLongitude == null) {
      return 0;
    }

    if (station.latitude == 0 ||
        station.longitude == 0) {
      return 0;
    }

    return Geolocator.distanceBetween(
      userLatitude!,
      userLongitude!,
      station.latitude,
      station.longitude,
    ) /
        1000;
  }

  // =========================================================
  // فلترة المحطات
  // =========================================================

  void filterStations() {
    filteredStations =
        stations.where((station) {

          bool matchSearch = true;

          if (search.trim().isNotEmpty) {
            final value =
            search.toLowerCase().trim();

            matchSearch =
                station.name
                    .toLowerCase()
                    .contains(value) ||
                    station.governorate
                        .toLowerCase()
                        .contains(value) ||
                    station.district
                        .toLowerCase()
                        .contains(value) ||
                    station.workingStatus
                        .toLowerCase()
                        .contains(value);
          }

          final bool available =
          checkProduct(station);

          bool matchStatus = true;
          final status = station.workingStatus.trim().toLowerCase();
          final isDuty = status.contains('خاف') || status.contains('خفار') || status == 'duty';
          final isOpen = status == 'مفتوحة' || status == 'open' || status == 'opened';

          if (selectedStatusFilter == 'duty') {
            matchStatus = isDuty;
          } else if (selectedStatusFilter == 'open') {
            matchStatus = isOpen || isDuty;
          }

          return matchSearch &&
              available &&
              matchStatus;
        }).toList();

    filteredStations.sort(
          (a, b) {
        return distanceFromUser(a)
            .compareTo(
          distanceFromUser(b),
        );
      },
    );
  }

  // =========================================================
  // فحص توفر المنتج
  // =========================================================

  bool checkProduct(Station station) {
    if (selectedProduct == 'all') {
      return true;
    }
    return station.supportedProducts[selectedProduct] == true;
  }
  // =========================================================
  // كمية المنتج
  // =========================================================

  int productQuantity(Station station) {
    if (selectedProduct == 'all') {
      return station.regular95 +
          station.improved95 +
          station.super95 +
          station.diesel +
          station.whiteOil +
          station.lpg;
    }
    switch (selectedProduct) {
      case "regular95":
        return station.regular95;

      case "improved95":
        return station.improved95;

      case "super95":
        return station.super95;

      case "diesel":
        return station.diesel;

      case "whiteOil":
        return station.whiteOil;

      case "lpg":
        return station.lpg;

      default:
        return 0;
    }
  }

  // =========================================================
  // اسم المنتج
  // =========================================================

  String getProductName() {
    return productName(selectedProduct);
  }

  // =========================================================
  // أقرب محطة
  // =========================================================

  Station? get nearestStation {
    if (filteredStations.isEmpty) {
      return null;
    }

    return filteredStations.first;
  }

  // =========================================================
  // اتصال الطوارئ 911
  // =========================================================

  Future<void> callEmergency() async {
    final uri = Uri(
      scheme: "tel",
      path: "911",
    );

    try {
      final launched =
      await launchUrl(uri);

      if (!launched && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              _tr('emergencyCallError'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _tr('emergencyConnectionError'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // الملاحة إلى محطة
  // =========================================================

  Future<void> navigateToStation(
      Station station,
      ) async {
    if (station.latitude == 0 ||
        station.longitude == 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _tr('coordinatesMissing'),
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    try {
      await NavigationService()
          .navigateToStation(
        station.latitude,
        station.longitude,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "${_tr('navigationError')}: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // الإشعارات
  // =========================================================

  void openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(
          userId: "citizen",
        ),
      ),
    );
  }


  // =========================================================
  // واجهة شاشة المواطن - التصميم فقط
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;

    return Directionality(
      textDirection: language == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0758D8),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.appName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'الكوبون النفطي (خصوصي)',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VehicleLoginScreen(isGovernment: false)),
                );
              },
              icon: const Icon(Icons.confirmation_number_rounded),
            ),
            StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance.ref("notifications").onValue,
              builder: (context, snapshot) {
                bool hasUnread = false;
                if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
                  final val = snapshot.data!.snapshot.value;
                  if (val is Map) {
                    val.forEach((key, item) {
                      if (item is Map) {
                        final map = Map<String, dynamic>.from(item);
                        final read = map["read"] == true;
                        final uId = (map["userId"] ?? "").toString();
                        final type = (map["type"] ?? "").toString().toLowerCase();

                        if (type != 'payment' && !map.toString().contains('إيصال دفع')) {
                          if (!read && (uId == "citizen" || uId == "public" || uId == "all" || uId.isEmpty)) {
                            hasUnread = true;
                          }
                        }
                      }
                    });
                  }
                }
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      tooltip: _tr('notifications'),
                      onPressed: openNotifications,
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                    if (hasUnread)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              tooltip: _tr('refresh'),
              onPressed: loadData,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadData,
            color: const Color(0xFF0758D8),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _welcomeCard(),
                  const SizedBox(height: 12),
                  const CommercialAdBanner(placement: 'citizen'),
                  const SizedBox(height: 12),
                  _mainInfoCard(),
                  const SizedBox(height: 12),
                  _searchCard(),
                  const SizedBox(height: 10),
                  _statusFilterCard(),
                  const SizedBox(height: 16),
                  _stationsTitle(),
                  const SizedBox(height: 10),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filteredStations.isEmpty)
                    _emptyStationsCard()
                  else
                    Column(
                      children: List.generate(
                        filteredStations.length,
                            (index) => Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _stationCard(filteredStations[index]),
                            ),
                            if ((index + 1) % 3 == 0) const CommercialAdInlineCard(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087F3D), Color(0xFF16A85A)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0758D8).withValues(alpha: .16),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.citizenWelcome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)!.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  AppLocalizations.of(context)!.citizenSubtitle,
                  style: const TextStyle(
                    color: Color(0xFFEAF3FF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 112,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const _StationIllustration(),
          ),
        ],
      ),
    );
  }

  // مستطيل واحد يحتوي الموقع يساراً، المنتج في الوسط، و911 يميناً.
  Widget _mainInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE7F4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .045),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _locationBox()),
            _verticalDivider(),
            Expanded(child: _productBox()),
            _verticalDivider(),
            Expanded(child: _emergencyBox()),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      color: const Color(0xFFE1E8F2),
    );
  }

  Widget _locationBox() {
    final l10n = AppLocalizations.of(context)!;

    final locationText = locationLoading
        ? l10n.detectingLocation
        : userLatitude == null
        ? l10n.locationNotDetected
        : l10n.locationDetected;
    return SizedBox(
      height: 190,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          children: [
            _circleIcon(
              Icons.location_on_rounded,
              const Color(0xFF1769E0),
              const Color(0xFFE8F0FF),
            ),
            const SizedBox(height: 7),
            Text(
              _tr('currentLocation'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF14264A),
                height: 1.15,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              locationText,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: userLatitude == null
                    ? Colors.grey.shade700
                    : const Color(0xFF249447),
                height: 1.15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userLatitude != null && userLongitude != null
                  ? '${userLatitude!.toStringAsFixed(3)}, ${userLongitude!.toStringAsFixed(3)}'
                  : _tr('enableLocation'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                color: Colors.grey.shade600,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            _circularActionButton(
              onTap: locationLoading ? null : getLocation,
              backgroundColor: const Color(0xFF1769E0),
              icon: locationLoading
                  ? Icons.hourglass_top_rounded
                  : Icons.my_location_rounded,
              label: _tr('refresh'),
              loading: locationLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _productBox() {
    final safeProduct =
    products.contains(selectedProduct) ? selectedProduct : products.first;

    return SizedBox(
      height: 190,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          children: [
            _circleIcon(
              Icons.local_gas_station_rounded,
              const Color(0xFFF08A00),
              const Color(0xFFFFF0D9),
            ),
            const SizedBox(height: 7),
            SizedBox(
              height: 34,
              child: Center(
                child: Text(
                  _tr('chooseProduct'),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14264A),
                    height: 1.15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFA62B)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: safeProduct,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Color(0xFFF08A00),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF253451),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                  items: products
                      .map(
                        (product) => DropdownMenuItem<String>(
                      value: product,
                      child: Text(
                        productName(product),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    if (value == null || !mounted) return;

                    setState(() {
                      selectedProduct = value;
                      filterStations();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _emergencyBox() {
    return SizedBox(
      height: 190,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          children: [
            _circleIcon(
              Icons.warning_rounded,
              const Color(0xFFE52B2B),
              const Color(0xFFFFE7E7),
            ),
            const SizedBox(height: 7),
            Text(
              _tr('emergency911'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFFD92727),
                height: 1.15,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              _tr('importantAlert'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                color: Colors.grey.shade700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            _circular911Button(),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon, Color color, Color background) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }

  Widget _circular911Button() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showEmergencyDialog,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFD92727),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD92727).withValues(alpha: .22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_in_talk_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(height: 1),
              Text(
                '911',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circularActionButton({
    required VoidCallback? onTap,
    required Color backgroundColor,
    required IconData icon,
    required String label,
    bool loading = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: onTap == null ? .55 : 1,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: .22),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: loading
                      ? const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                      : Icon(
                    icon,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: backgroundColor,
          ),
        ),
      ],
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _tr('importantAlert'),
          textDirection: TextDirection.rtl,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          _tr('emergencyMessage'),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_tr('close')),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              callEmergency();
            },
            icon: const Icon(Icons.phone),
            label: Text(_tr('call911')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD92727),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD6E3F7)),
      ),
      child: TextField(
        textDirection: TextDirection.rtl,
        onChanged: (value) {
          setState(() {
            search = value;
            filterStations();
          });
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: _tr('searchStation'),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF14264A)),
          suffixIcon: search.isEmpty
              ? null
              : IconButton(
            onPressed: () {
              setState(() {
                search = '';
                filterStations();
              });
            },
            icon: const Icon(Icons.clear_rounded),
          ),
        ),
      ),
    );
  }

  Widget _statusFilterCard() {
    final dutyCount = stations.where((s) {
      final st = s.workingStatus.trim().toLowerCase();
      return st.contains('خاف') || st.contains('خفار') || st == 'duty';
    }).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E3F7)),
      ),
      child: Row(
        children: [
          _statusFilterChip(
            filterId: 'all',
            label: _tr('allStations'),
            icon: Icons.local_gas_station_rounded,
            activeColor: const Color(0xFF0758D8),
          ),
          const SizedBox(width: 5),
          _statusFilterChip(
            filterId: 'duty',
            label: _tr('dutyStations'),
            icon: Icons.nights_stay_rounded,
            activeColor: const Color(0xFF7E22CE),
            count: dutyCount,
          ),
          const SizedBox(width: 5),
          _statusFilterChip(
            filterId: 'open',
            label: _tr('openStations'),
            icon: Icons.check_circle_rounded,
            activeColor: const Color(0xFF249447),
          ),
        ],
      ),
    );
  }

  Widget _statusFilterChip({
    required String filterId,
    required String label,
    required IconData icon,
    required Color activeColor,
    int? count,
  }) {
    final isSelected = selectedStatusFilter == filterId;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedStatusFilter = filterId;
            filterStations();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : const Color(0xFFF4F7FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : activeColor,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ),
              if (count != null && count > 0) ...[
                const SizedBox(width: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.3) : activeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : activeColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _stationsTitle() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F0FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.location_on_rounded, color: Color(0xFF0758D8)),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tr('availableNearby'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF14264A)),
              ),
              Text(
                _tr('nearestFirst'),
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            "${filteredStations.length}",
            style: const TextStyle(color: Color(0xFF0758D8), fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _fuelBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F5EA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Text(
        '$name (متوفر)',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF166534),
        ),
      ),
    );
  }

  Widget _emptyStationsCard() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E8F2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_gas_station_outlined, size: 54, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            _tr('noStations'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF4A5870)),
          ),
          const SizedBox(height: 6),
          Text(
            _tr('tryAgain'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _stationCard(Station station) {
    final distance = distanceFromUser(station);
    final available = checkProduct(station);
    final status = station.workingStatus.trim().toLowerCase();
    final isDuty = status.contains('خاف') || status.contains('خفار') || status == 'duty';
    final open = status == 'مفتوحة' ||
        status == 'open' ||
        status == 'opened' ||
        isDuty;

    final crowd = station.crowdStatus.isEmpty ? "هادئة" : station.crowdStatus;
    Color crowdBgColor = const Color(0xFFDCFCE7);
    Color crowdTextColor = const Color(0xFF15803D);
    String crowdText = "🟢 هادئة";

    if (crowd.contains("متوسط")) {
      crowdBgColor = const Color(0xFFFEF9C3);
      crowdTextColor = const Color(0xFFA16207);
      crowdText = "🟡 متوسطة";
    } else if (crowd.contains("مزدحم")) {
      crowdBgColor = const Color(0xFFFEE2E2);
      crowdTextColor = const Color(0xFFB91C1C);
      crowdText = "🔴 مزدحمة";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: isDuty
              ? const Color(0xFFE9D5FF)
              : (available ? const Color(0xFFDCE8E0) : const Color(0xFFFFDDDD)),
        ),
        boxShadow: [
          BoxShadow(
            color: isDuty
                ? const Color(0xFF7E22CE).withValues(alpha: .08)
                : Colors.black.withValues(alpha: .045),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isDuty
                      ? const Color(0xFFF3E8FF)
                      : (available ? const Color(0xFFE7F5EA) : const Color(0xFFFFEAEA)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDuty
                      ? Icons.nights_stay_rounded
                      : Icons.local_gas_station_rounded,
                  color: isDuty
                      ? const Color(0xFF7E22CE)
                      : (available ? const Color(0xFF249447) : const Color(0xFFE12D2D)),
                  size: 29,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            station.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF14264A)),
                          ),
                        ),
                        if (isDuty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFC084FC)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.nights_stay_rounded, size: 11, color: Color(0xFF7E22CE)),
                                SizedBox(width: 2),
                                Text(
                                  'خافرة',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7E22CE),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${station.governorate} - ${station.district}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      available
                          ? '${productName(selectedProduct)} ${_tr('available')}'
                          : '${productName(selectedProduct)} ${_tr('unavailable')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: available ? const Color(0xFF218A41) : const Color(0xFFD82B2B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    distance > 0 ? '${distance.toStringAsFixed(1)} km' : _tr('notSpecified'),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: available ? const Color(0xFF249447) : const Color(0xFFE12D2D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: crowdBgColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      crowdText,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: crowdTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (selectedProduct == 'all') ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                if (station.supportedProducts["regular95"] == true)
                  _fuelBadge(productName("regular95")),
                if (station.supportedProducts["improved95"] == true)
                  _fuelBadge(productName("improved95")),
                if (station.supportedProducts["super95"] == true)
                  _fuelBadge(productName("super95")),
                if (station.supportedProducts["diesel"] == true)
                  _fuelBadge(productName("diesel")),
                if (station.supportedProducts["whiteOil"] == true)
                  _fuelBadge(productName("whiteOil")),
                if (station.supportedProducts["lpg"] == true)
                  _fuelBadge(productName("lpg")),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showStationDetails(station),
                  icon: const Icon(Icons.info_outline_rounded, size: 17),
                  label: Text(_tr('details')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0758D8),
                    side: const BorderSide(color: Color(0xFF6F9FF3)),
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: station.latitude == 0 || station.longitude == 0
                      ? null
                      : () => navigateToStation(station),
                  icon: const Icon(Icons.navigation_rounded, size: 17),
                  label: Text(_tr('startNavigation')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0758D8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isDuty
                    ? Icons.nights_stay_rounded
                    : (open ? Icons.check_circle_rounded : Icons.cancel_rounded),
                size: 15,
                color: isDuty
                    ? const Color(0xFF7E22CE)
                    : (open ? const Color(0xFF249447) : const Color(0xFFD82B2B)),
              ),
              const SizedBox(width: 4),
              Text(
                isDuty
                    ? _tr('stationDuty')
                    : (open ? _tr('stationOpen') : _tr('stationClosed')),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isDuty
                      ? const Color(0xFF7E22CE)
                      : (open ? const Color(0xFF249447) : const Color(0xFFD82B2B)),
                ),
              ),
              const Spacer(),
              if (station.updatedAt.isNotEmpty)
                Flexible(
                  child: Text(
                    '${_tr('lastUpdate')}: ${station.updatedAt}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 8.5, color: Colors.grey.shade500),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // تفاصيل المحطة
  // =========================================================

  void _showStationDetails(
      Station station,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
          Text(
            station.name,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),

          content:
          SingleChildScrollView(
            child:
            Column(
              mainAxisSize:
              MainAxisSize.min,

              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [

                Text(
                  "${_tr('governorate')}: ${station.governorate}",
                ),
                Text(
                  "الفرع: ${station.branchName.isNotEmpty ? station.branchName : 'غير محدد'}",
                ),
                Text(
                  "${_tr('district')}: ${station.district}",
                ),

                Text(
                  "${_tr('stationType')}: ${station.stationType}",
                ),

                const SizedBox(
                  height: 10,
                ),

                const Divider(),

                if (station.supportedProducts["regular95"] == true)
                  Text("• ${productName('regular95')}"),

                if (station.supportedProducts["improved95"] == true)
                  Text("• ${productName('improved95')}"),

                if (station.supportedProducts["super95"] == true)
                  Text("• ${productName('super95')}"),

                if (station.supportedProducts["diesel"] == true)
                  Text("• ${productName('diesel')}"),

                if (station.supportedProducts["whiteOil"] == true)
                  Text("• ${productName('whiteOil')}"),

                if (station.supportedProducts["lpg"] == true)
                  Text("• ${productName('lpg')}"),

                if (!station.supportedProducts.values.any((v) => v))
                  Text(
                    _tr('noProducts'),
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(
                  height: 15,
                ),

                Card(
                  child:
                  ListTile(
                    leading:
                    Icon(
                      station.workingStatus.contains("خاف") || station.workingStatus.contains("خفار") || station.workingStatus == "duty"
                          ? Icons.nights_stay
                          : (station.workingStatus == "مفتوحة" ? Icons.check_circle : Icons.cancel),

                      color:
                      station.workingStatus.contains("خاف") || station.workingStatus.contains("خفار") || station.workingStatus == "duty"
                          ? const Color(0xFF7E22CE)
                          : (station.workingStatus == "مفتوحة" ? Colors.green : Colors.red),
                    ),

                    title:
                    Text(
                      _tr('stationStatus'),
                    ),

                    subtitle:
                    Text(
                      station.workingStatus,
                    ),
                  ),
                ),

                Card(
                  child:
                  ListTile(
                    leading:
                    const Icon(
                      Icons.people_outline_rounded,
                      color: Colors.orange,
                    ),

                    title:
                    const Text(
                      "حالة الازدحام",
                    ),

                    subtitle:
                    Text(
                      station.crowdStatus.isNotEmpty ? station.crowdStatus : "هادئة",
                    ),
                  ),
                ),

                Card(
                  child:
                  ListTile(
                    leading:
                    const Icon(
                      Icons.update,
                      color:
                      Colors.blue,
                    ),

                    title:
                    Text(
                      _tr('lastQuantityUpdate'),
                    ),

                    subtitle:
                    Text(
                      station.updatedAt
                          .isEmpty
                          ? _tr('noUpdate')
                          : station.updatedAt,
                    ),
                  ),
                ),

                if (station.address
                    .isNotEmpty)
                  ListTile(
                    leading:
                    const Icon(
                      Icons
                          .location_on,
                    ),
                    title:
                    Text(
                      _tr('address'),
                    ),
                    subtitle:
                    Text(
                      station.address,
                    ),
                  ),

                if (station.phone
                    .isNotEmpty)
                  ListTile(
                    leading:
                    const Icon(
                      Icons.phone,
                    ),
                    title:
                    Text(
                      _tr('phone'),
                    ),
                    subtitle:
                    Text(
                      station.phone,
                    ),
                  ),

                const SizedBox(
                  height: 10,
                ),

                SizedBox(
                  width:
                  double.infinity,

                  child:
                  ElevatedButton
                      .icon(
                    icon:
                    const Icon(
                      Icons.navigation,
                    ),

                    label:
                    Text(
                      _tr('startNavigation'),
                    ),

                    onPressed:
                        () {
                      Navigator.pop(
                        dialogContext,
                      );

                      navigateToStation(
                        station,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
              Text(
                _tr('close'),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // إنهاء الشاشة
  // =========================================================

  @override
  void dispose() {
    stationSubscription?.cancel();

    super.dispose();
  }
}
