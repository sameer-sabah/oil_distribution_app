import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_ku.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fa'),
    Locale('ku'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'نافذة المنتوج النفطي'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @username.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get username;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @update.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get update;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @about.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get about;

  /// No description provided for @contact.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا'**
  String get contact;

  /// No description provided for @rating.
  ///
  /// In ar, this message translates to:
  /// **'تقييم التطبيق'**
  String get rating;

  /// No description provided for @privacy.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get terms;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @station.
  ///
  /// In ar, this message translates to:
  /// **'المحطة'**
  String get station;

  /// No description provided for @stations.
  ///
  /// In ar, this message translates to:
  /// **'المحطات'**
  String get stations;

  /// No description provided for @stationManager.
  ///
  /// In ar, this message translates to:
  /// **'مدير المحطة'**
  String get stationManager;

  /// No description provided for @branchManager.
  ///
  /// In ar, this message translates to:
  /// **'مدير الفرع'**
  String get branchManager;

  /// No description provided for @admin.
  ///
  /// In ar, this message translates to:
  /// **'مدير النظام'**
  String get admin;

  /// No description provided for @employee.
  ///
  /// In ar, this message translates to:
  /// **'الموظف'**
  String get employee;

  /// No description provided for @citizen.
  ///
  /// In ar, this message translates to:
  /// **'المواطن'**
  String get citizen;

  /// No description provided for @stationName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المحطة'**
  String get stationName;

  /// No description provided for @stationType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المحطة'**
  String get stationType;

  /// No description provided for @governorate.
  ///
  /// In ar, this message translates to:
  /// **'المحافظة'**
  String get governorate;

  /// No description provided for @district.
  ///
  /// In ar, this message translates to:
  /// **'القضاء'**
  String get district;

  /// No description provided for @branch.
  ///
  /// In ar, this message translates to:
  /// **'الفرع'**
  String get branch;

  /// No description provided for @address.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phone;

  /// No description provided for @managerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المدير'**
  String get managerName;

  /// No description provided for @managerPhone.
  ///
  /// In ar, this message translates to:
  /// **'هاتف المدير'**
  String get managerPhone;

  /// No description provided for @fuelQuantities.
  ///
  /// In ar, this message translates to:
  /// **'كميات الوقود'**
  String get fuelQuantities;

  /// No description provided for @updateFuelQuantities.
  ///
  /// In ar, this message translates to:
  /// **'تحديث كميات الوقود'**
  String get updateFuelQuantities;

  /// No description provided for @regular95.
  ///
  /// In ar, this message translates to:
  /// **'بنزين عادي'**
  String get regular95;

  /// No description provided for @improved95.
  ///
  /// In ar, this message translates to:
  /// **'بنزين محسن'**
  String get improved95;

  /// No description provided for @super95.
  ///
  /// In ar, this message translates to:
  /// **'بنزين سوبر'**
  String get super95;

  /// No description provided for @diesel.
  ///
  /// In ar, this message translates to:
  /// **'زيت الغاز'**
  String get diesel;

  /// No description provided for @whiteOil.
  ///
  /// In ar, this message translates to:
  /// **'النفط الأبيض'**
  String get whiteOil;

  /// No description provided for @lpg.
  ///
  /// In ar, this message translates to:
  /// **'الغاز السائل'**
  String get lpg;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'فعالة'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In ar, this message translates to:
  /// **'غير فعالة'**
  String get inactive;

  /// No description provided for @approved.
  ///
  /// In ar, this message translates to:
  /// **'معتمدة'**
  String get approved;

  /// No description provided for @notApproved.
  ///
  /// In ar, this message translates to:
  /// **'غير معتمدة'**
  String get notApproved;

  /// No description provided for @registerStation.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل محطة'**
  String get registerStation;

  /// No description provided for @pendingStations.
  ///
  /// In ar, this message translates to:
  /// **'طلبات تسجيل المحطات'**
  String get pendingStations;

  /// No description provided for @approve.
  ///
  /// In ar, this message translates to:
  /// **'موافقة'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get reject;

  /// No description provided for @success.
  ///
  /// In ar, this message translates to:
  /// **'تمت العملية بنجاح'**
  String get success;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get error;

  /// No description provided for @saveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ بنجاح'**
  String get saveSuccess;

  /// No description provided for @updateSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم التحديث بنجاح'**
  String get updateSuccess;

  /// No description provided for @deleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم الحذف بنجاح'**
  String get deleteSuccess;

  /// No description provided for @chooseLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغة التطبيق'**
  String get chooseLanguage;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @kurdish.
  ///
  /// In ar, this message translates to:
  /// **'الكردية'**
  String get kurdish;

  /// No description provided for @persian.
  ///
  /// In ar, this message translates to:
  /// **'الفارسية'**
  String get persian;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'الإنكليزية'**
  String get english;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @general.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get general;

  /// No description provided for @ads.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات'**
  String get ads;

  /// No description provided for @services.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات'**
  String get services;

  /// No description provided for @supportAndApp.
  ///
  /// In ar, this message translates to:
  /// **'الدعم والتطبيق'**
  String get supportAndApp;

  /// No description provided for @languageSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'العربية / الكردية / الفارسية / English'**
  String get languageSubtitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات المنتجات والإعلانات'**
  String get notificationsSubtitle;

  /// No description provided for @addPaidAd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إعلان مدفوع'**
  String get addPaidAd;

  /// No description provided for @addPaidAdSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء إعلان وتحديد أماكن الظهور'**
  String get addPaidAdSubtitle;

  /// No description provided for @myAds.
  ///
  /// In ar, this message translates to:
  /// **'إعلاناتي'**
  String get myAds;

  /// No description provided for @myAdsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الحالة والدفع والإحصائيات والتمديد'**
  String get myAdsSubtitle;

  /// No description provided for @viewAds.
  ///
  /// In ar, this message translates to:
  /// **'مشاهدة الإعلانات'**
  String get viewAds;

  /// No description provided for @viewAdsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات المنشورة للمواطنين'**
  String get viewAdsSubtitle;

  /// No description provided for @addPaidService.
  ///
  /// In ar, this message translates to:
  /// **'إضافة خدمة مدفوعة'**
  String get addPaidService;

  /// No description provided for @addPaidServiceSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة خدمة تجارية للمراجعة'**
  String get addPaidServiceSubtitle;

  /// No description provided for @myServices.
  ///
  /// In ar, this message translates to:
  /// **'خدماتي'**
  String get myServices;

  /// No description provided for @myServicesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة خدماتك والدفع والإحصائيات'**
  String get myServicesSubtitle;

  /// No description provided for @viewServices.
  ///
  /// In ar, this message translates to:
  /// **'مشاهدة الخدمات'**
  String get viewServices;

  /// No description provided for @viewServicesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات التجارية المنشورة'**
  String get viewServicesSubtitle;

  /// No description provided for @paymentsInvoices.
  ///
  /// In ar, this message translates to:
  /// **'المدفوعات والفواتير'**
  String get paymentsInvoices;

  /// No description provided for @paymentsInvoicesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض عمليات الدفع والحالات'**
  String get paymentsInvoicesSubtitle;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactUs;

  /// No description provided for @contactUsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رسالة إلى الإدارة'**
  String get contactUsSubtitle;

  /// No description provided for @rateApp.
  ///
  /// In ar, this message translates to:
  /// **'تقييم التطبيق'**
  String get rateApp;

  /// No description provided for @rateAppSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'شاركنا رأيك'**
  String get rateAppSubtitle;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'معلومات التطبيق والمطور'**
  String get aboutAppSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'كيفية التعامل مع البيانات'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsConditions.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get termsConditions;

  /// No description provided for @termsConditionsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'شروط الإعلانات والخدمات'**
  String get termsConditionsSubtitle;

  /// No description provided for @appVersion.
  ///
  /// In ar, this message translates to:
  /// **'رقم إصدار التطبيق'**
  String get appVersion;

  /// No description provided for @developer.
  ///
  /// In ar, this message translates to:
  /// **'المطور المهندس سمير صباح'**
  String get developer;

  /// No description provided for @citizenWelcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك في'**
  String get citizenWelcome;

  /// No description provided for @citizenSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اعرف أقرب محطة وتوفر المنتجات النفطية'**
  String get citizenSubtitle;

  /// No description provided for @commercialServices.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات التجارية'**
  String get commercialServices;

  /// No description provided for @commercialServicesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'خدمات منشورة ومتاحة للمواطنين'**
  String get commercialServicesSubtitle;

  /// No description provided for @currentLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقعك الحالي'**
  String get currentLocation;

  /// No description provided for @detectingLocation.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحديد الموقع...'**
  String get detectingLocation;

  /// No description provided for @locationNotDetected.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد الموقع'**
  String get locationNotDetected;

  /// No description provided for @locationDetected.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديد موقعك'**
  String get locationDetected;

  /// No description provided for @enableLocationForNearest.
  ///
  /// In ar, this message translates to:
  /// **'فعّل الموقع لمعرفة الأقرب'**
  String get enableLocationForNearest;

  /// No description provided for @chooseProduct.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع المنتوج'**
  String get chooseProduct;

  /// No description provided for @emergency911.
  ///
  /// In ar, this message translates to:
  /// **'الطوارئ 911'**
  String get emergency911;

  /// No description provided for @importantCitizenAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه مهم للمواطن'**
  String get importantCitizenAlert;

  /// No description provided for @emergencyMessage.
  ///
  /// In ar, this message translates to:
  /// **'عند حدوث حالة طارئة أو خطر، اتصل بالرقم 911 فوراً.'**
  String get emergencyMessage;

  /// No description provided for @call911.
  ///
  /// In ar, this message translates to:
  /// **'اتصال 911'**
  String get call911;

  /// No description provided for @emergencyConnectionError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بالطوارئ'**
  String get emergencyConnectionError;

  /// No description provided for @emergencyOpenError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح الاتصال بالطوارئ'**
  String get emergencyOpenError;

  /// No description provided for @searchStationOrArea.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن محطة أو منطقة...'**
  String get searchStationOrArea;

  /// No description provided for @availableNearbyStations.
  ///
  /// In ar, this message translates to:
  /// **'المحطات المتوفرة والقريبة منك'**
  String get availableNearbyStations;

  /// No description provided for @nearestToFarthest.
  ///
  /// In ar, this message translates to:
  /// **'مرتبة من الأقرب إلى الأبعد'**
  String get nearestToFarthest;

  /// No description provided for @noStationsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محطات متوفرة حالياً'**
  String get noStationsAvailable;

  /// No description provided for @tryChangeProductOrArea.
  ///
  /// In ar, this message translates to:
  /// **'جرّب تغيير نوع المنتوج أو البحث عن منطقة أخرى'**
  String get tryChangeProductOrArea;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر'**
  String get unavailable;

  /// No description provided for @details.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get details;

  /// No description provided for @startNavigation.
  ///
  /// In ar, this message translates to:
  /// **'المسار'**
  String get startNavigation;

  /// No description provided for @stationOpen.
  ///
  /// In ar, this message translates to:
  /// **'المحطة مفتوحة'**
  String get stationOpen;

  /// No description provided for @stationClosed.
  ///
  /// In ar, this message translates to:
  /// **'المحطة مغلقة'**
  String get stationClosed;

  /// No description provided for @lastUpdate.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث'**
  String get lastUpdate;

  /// No description provided for @liters.
  ///
  /// In ar, this message translates to:
  /// **'لتر'**
  String get liters;

  /// No description provided for @notSpecified.
  ///
  /// In ar, this message translates to:
  /// **'غير محددة'**
  String get notSpecified;

  /// No description provided for @stationCoordinatesMissing.
  ///
  /// In ar, this message translates to:
  /// **'إحداثيات المحطة غير موجودة'**
  String get stationCoordinatesMissing;

  /// No description provided for @navigationOpenError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح الملاحة'**
  String get navigationOpenError;

  /// No description provided for @stationDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المحطة'**
  String get stationDetails;

  /// No description provided for @stationStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة المحطة'**
  String get stationStatus;

  /// No description provided for @lastQuantityUpdate.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث للكميات'**
  String get lastQuantityUpdate;

  /// No description provided for @noUpdate.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تحديث'**
  String get noUpdate;

  /// No description provided for @noProductsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات متاحة حاليًا'**
  String get noProductsAvailable;

  /// No description provided for @quantityRegular95.
  ///
  /// In ar, this message translates to:
  /// **'بنزين عادي: {quantity} لتر'**
  String quantityRegular95(Object quantity);

  /// No description provided for @quantityImproved95.
  ///
  /// In ar, this message translates to:
  /// **'بنزين محسن: {quantity} لتر'**
  String quantityImproved95(Object quantity);

  /// No description provided for @quantitySuper95.
  ///
  /// In ar, this message translates to:
  /// **'بنزين سوبر: {quantity} لتر'**
  String quantitySuper95(Object quantity);

  /// No description provided for @quantityDiesel.
  ///
  /// In ar, this message translates to:
  /// **'ديزل: {quantity} لتر'**
  String quantityDiesel(Object quantity);

  /// No description provided for @quantityWhiteOil.
  ///
  /// In ar, this message translates to:
  /// **'النفط الأبيض: {quantity} لتر'**
  String quantityWhiteOil(Object quantity);

  /// No description provided for @quantityLpg.
  ///
  /// In ar, this message translates to:
  /// **'الغاز السائل: {quantity} لتر'**
  String quantityLpg(Object quantity);

  /// No description provided for @governorateLabel.
  ///
  /// In ar, this message translates to:
  /// **'المحافظة: {governorate}'**
  String governorateLabel(Object governorate);

  /// No description provided for @districtLabel.
  ///
  /// In ar, this message translates to:
  /// **'القضاء: {district}'**
  String districtLabel(Object district);

  /// No description provided for @stationTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع المحطة: {type}'**
  String stationTypeLabel(Object type);

  /// No description provided for @phoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phoneLabel;

  /// No description provided for @addressLabel.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get addressLabel;

  /// No description provided for @loadStationsError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل المحطات: {error}'**
  String loadStationsError(Object error);

  /// No description provided for @updateStationsError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديث البيانات: {error}'**
  String updateStationsError(Object error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fa', 'ku'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'ku':
      return AppLocalizationsKu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
