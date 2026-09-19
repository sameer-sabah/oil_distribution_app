import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/commercial_service.dart';
import '../services/commercial_payment_settings_service.dart';
import '../services/advertiser_account_service.dart';
import 'map_picker_screen.dart';

import '../services/ai_ad_image_service.dart';
import '../models/ad_image_generation_request.dart';

class CommercialAdFormScreen extends StatefulWidget {
  const CommercialAdFormScreen({super.key});

  @override
  State<CommercialAdFormScreen> createState() =>
      _CommercialAdFormScreenState();
}

class _CommercialAdFormScreenState extends State<CommercialAdFormScreen> {
  int _pricePerDay = 2000;

  bool _settingsLoading = true;
  bool _adsEnabled = true;

  final _formKey = GlobalKey<FormState>();

  final _business = TextEditingController();
  final _description = TextEditingController();

  final _whatsapp = TextEditingController();
  final _website = TextEditingController();
  final _masterCard = TextEditingController();

  final _governorate = TextEditingController();
  final _district = TextEditingController();
  final _address = TextEditingController();

  final _price = TextEditingController();
  final _duration = TextEditingController(text: '7');

  final _start = TextEditingController();
  final _end = TextEditingController();

  String _selectedCategory = 'خدمات وأعمال';

  static const List<String> _adCategories = [
    'مطاعم وأطعمة',
    'سيارات ومعارض',
    'عقارات',
    'عيادات ومراكز طبية',
    'صيدليات',
    'ملابس وأزياء',
    'إلكترونيات',
    'صالونات وتجميل',
    'خدمات وأعمال',
    'أخرى',
  ];

  static const List<String> _iraqiGovernorates = [
    'بغداد',
    'البصرة',
    'نينوى',
    'أربيل',
    'النجف',
    'كربلاء',
    'السليمانية',
    'الأنبار',
    'ديالى',
    'بابل',
    'كركوك',
    'ميسان',
    'ذي قار',
    'المثنى',
    'القادسية',
    'صلاح الدين',
    'واسط',
    'دهوك',
    'حلبجة',
  ];

  // ============================================================
  // الذكاء الاصطناعي
  // ============================================================

  bool _isGeneratingAiImage = false;

  String _generatedImageUrl = '';
  String _generatedPrompt = '';

  String _selectedAiStyle = 'احترافي';
  String _selectedImageSize = 'مربع 1:1';

  static const List<String> _aiStyles = [
    'احترافي',
    'واقعي',
    'حديث',
    'فخم',
    'بسيط',
    'إعلاني',
  ];

  static const List<String> _imageSizes = [
    'مربع 1:1',
    'طولي 4:5',
    'أفقي 16:9',
  ];

  // ============================================================

  final List<String> _placements = ['home'];

  double _lat = 0;
  double _lng = 0;

  bool _featured = false;
  bool _notificationPromotion = false;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    if (_governorate.text.isEmpty) {
      _governorate.text = 'بغداد';
    }

    if (_start.text.isEmpty) {
      _start.text = DateTime.now().toIso8601String().substring(0, 10);
    }

    _duration.addListener(() {
      _syncCalculatedPrice();
      _syncEndDate();
    });

    _syncEndDate();

    _loadPaymentSettings();
    _loadAdvertiserProfile();
  }

  void _syncEndDate() {
    final startStr = _start.text.trim();
    final days = int.tryParse(_duration.text.trim()) ?? 7;
    DateTime startDate = DateTime.tryParse(startStr) ?? DateTime.now();
    final endDate = startDate.add(Duration(days: days > 0 ? days : 1));
    setState(() {
      _end.text = endDate.toIso8601String().substring(0, 10);
    });
  }

  Future<void> _loadAdvertiserProfile() async {
    try {
      final account =
      await AdvertiserAccountService.instance.getCurrentAccount();
      if (!mounted || account == null) return;

      if (_business.text.trim().isEmpty) {
        _business.text = account.businessName;
      }
      if (_whatsapp.text.trim().isEmpty) {
        _whatsapp.text = account.whatsapp;
      }
      if (_masterCard.text.trim().isEmpty) {
        _masterCard.text = account.masterCardNumber;
      }
      if (_masterCard.text.trim().isEmpty) {
        _masterCard.text = account.masterCardNumber;
      }
    } catch (_) {
      // التحقق النهائي من الحساب يتم داخل CommercialService عند الحفظ.
    }
  }

  Future<void> _loadPaymentSettings() async {
    try {
      final settings =
      await CommercialPaymentSettingsService.instance.getSettings();

      if (!mounted) return;

      setState(() {
        _pricePerDay = settings.pricePerDay;
        _adsEnabled = settings.adsEnabled;
        _settingsLoading = false;
      });

      _syncCalculatedPrice();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _settingsLoading = false;
      });

      _syncCalculatedPrice();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تحميل إعدادات سعر الإعلان: $e',
          ),
        ),
      );
    }
  }

  void _syncCalculatedPrice() {
    final days = int.tryParse(
      _duration.text.trim(),
    ) ??
        0;

    final total = days > 0 ? days * _pricePerDay : 0;

    final newValue = total.toString();

    if (_price.text != newValue) {
      _price.text = newValue;
    }

    if (mounted) {
      setState(() {});
    }
  }

  int get _selectedDays =>
      int.tryParse(
        _duration.text.trim(),
      ) ??
          0;

  int get _calculatedPrice =>
      _selectedDays > 0 ? _selectedDays * _pricePerDay : 0;

  @override
  void dispose() {
    _duration.removeListener(
      _syncCalculatedPrice,
    );

    for (final c in [
      _business,
      _description,
      _whatsapp,
      _website,
      _masterCard,
      _governorate,
      _district,
      _address,
      _price,
      _duration,
      _start,
      _end,
    ]) {
      c.dispose();
    }

    super.dispose();
  }

  Future<void> _pickDate(
      TextEditingController controller,
      ) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 730),
      ),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      controller.text = date.toIso8601String();
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => const MapPickerScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
      });
    }
  }

  // ============================================================
  // توليد Prompt حسب نوع الإعلان
  // ============================================================

  String _buildAiPrompt() {
    final businessName = _business.text.trim();
    final description = _description.text.trim();

    final locationParts = <String>[
      if (_governorate.text.trim().isNotEmpty)
        _governorate.text.trim(),
      if (_district.text.trim().isNotEmpty)
        _district.text.trim(),
      if (_address.text.trim().isNotEmpty)
        _address.text.trim(),
    ];

    final location = locationParts.join(' - ');

    switch (_selectedCategory) {
      case 'مطاعم وأطعمة':
        return '''
صمم صورة إعلان تجاري احترافية لمطعم أو نشاط أطعمة باسم "$businessName".
وصف النشاط: "$description".
الموقع: "$location".
الستايل المطلوب: "$_selectedAiStyle".
مقاس التصميم: "$_selectedImageSize".
أظهر أطعمة شهية بجودة عالية وإضاءة احترافية وأجواء جذابة مناسبة لإعلان تجاري داخل تطبيق موبايل.
اترك مساحة مناسبة لاسم النشاط والنص الإعلاني.
لا تضف معلومات أو أرقام هاتف غير موجودة في الطلب.
''';

      case 'سيارات ومعارض':
        return '''
صمم صورة إعلان تجاري احترافية لمعرض سيارات باسم "$businessName".
الوصف: "$description".
الموقع: "$location".
الستايل المطلوب: "$_selectedAiStyle".
مقاس التصميم: "$_selectedImageSize".
استخدم سيارات حديثة وإضاءة احترافية ومظهر راقٍ مناسب للإعلانات التجارية.
''';

      case 'عقارات':
        return '''
صمم صورة إعلان عقاري احترافية لنشاط باسم "$businessName".
الوصف: "$description".
الموقع: "$location".
الستايل المطلوب: "$_selectedAiStyle".
مقاس التصميم: "$_selectedImageSize".
أظهر مبنى أو منزل أو عقار حديث بطريقة واقعية وجذابة ومناسبة للإعلان.
''';

      case 'عيادات ومراكز طبية':
        return '''
صمم صورة إعلان احترافية لعيادة أو مركز طبي باسم "$businessName".
الوصف: "$description".
الموقع: "$location".
الستايل المطلوب: "$_selectedAiStyle".
مقاس التصميم: "$_selectedImageSize".
استخدم تصميم طبي نظيف وحديث ومريح بصرياً ومناسب لإعلان رسمي.
''';

      case 'صيدليات':
        return '''
صمم صورة إعلان احترافية لصيدلية باسم "$businessName".
الوصف: "$description".
الموقع: "$location".
الستايل المطلوب: "$_selectedAiStyle".
مقاس التصميم: "$_selectedImageSize".
استخدم بيئة صيدلية حديثة ونظيفة وعناصر بصرية مناسبة للصيدلية.
''';

      case 'ملابس وأزياء':
        return '''
صمم صورة إعلان احترافية لمحل ملابس وأزياء باسم "$businessName".
الوصف: "$description".
الموقع: "$location".
الستايل المطلوب: "$_selectedAiStyle".
مقاس التصميم: "$_selectedImageSize".
اجعل التصميم عصرياً وجذاباً ومناسباً للإعلانات التجارية.
''';

      case 'إلكترونيات':
        return '''
صمم صورة إعلان احترافية لمحل إلكترونيات باسم "$businessName".
الوصف: "$description".
الموقع: "$location".
الستايل المطلوب: "$_selectedAiStyle".
مقاس التصميم: "$_selectedImageSize".
أظهر أجهزة إلكترونية حديثة بتصميم تقني جذاب.
''';

      case 'صالونات وتجميل':
        return '''
صمم صورة إعلان احترافية لصالون أو مركز تجميل باسم "$businessName".
الوصف: "$description".
الموقع: "$location".
الستايل المطلوب: "$_selectedAiStyle".
مقاس التصميم: "$_selectedImageSize".
اجعل التصميم أنيقاً وحديثاً ومناسباً لنشاط التجميل.
''';

      default:
        return '''
صمم صورة إعلان تجاري احترافية لنشاط باسم "$businessName".
نوع النشاط: "$_selectedCategory".
الوصف: "$description".
الموقع: "$location".
الستايل المطلوب: "$_selectedAiStyle".
مقاس التصميم: "$_selectedImageSize".
اجعل التصميم حديثاً وجذاباً ومناسباً للإعلانات التجارية داخل تطبيق موبايل.
''';
    }
  }

  // ============================================================
  // توليد الصورة
  // ============================================================

  Future<void> _generateAiImage() async {
    if (_business.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'اكتب اسم النشاط أولاً',
          ),
        ),
      );

      return;
    }

    if (_description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'اكتب وصف الإعلان أولاً',
          ),
        ),
      );

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isGeneratingAiImage = true;
    });

    try {
      final prompt = _buildAiPrompt();

      final request = AdImageGenerationRequest(
        category: _selectedCategory,
        businessName: _business.text.trim(),
        description: _description.text.trim(),
        location: [
          _governorate.text.trim(),
          _district.text.trim(),
          _address.text.trim(),
        ].where((e) => e.isNotEmpty).join(' - '),
        style: _selectedAiStyle,
        aspectRatio: _selectedImageSize,
      );

      final result =
      await AiAdImageService.instance.generateImage(
        request,
      );

      if (!mounted) return;

      if (result.success &&
          result.imageUrl.trim().isNotEmpty) {
        setState(() {
          _generatedPrompt = prompt;

          _generatedImageUrl =
              result.imageUrl.trim();
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'تم توليد صورة الإعلان بنجاح',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              result.message.isNotEmpty
                  ? result.message
                  : 'تعذر توليد الصورة',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'تعذر توليد الصورة: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingAiImage = false;
        });
      }
    }
  }

  void _removeGeneratedImage() {
    setState(() {
      _generatedImageUrl = '';
      _generatedPrompt = '';
    });
  }

  // ============================================================
  // الحفظ الأصلي
  // ============================================================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة كافة الحقول الإجبارية ورقم الماستر (12 رقماً) بشكل صحيح')),
      );
      return;
    }

    final masterCardClean = _masterCard.text.trim().replaceAll(RegExp(r'\s+'), '');
    if (_business.text.trim().isEmpty ||
        _description.text.trim().isEmpty ||
        masterCardClean.length != 12 ||
        _address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عذراً، لا يمكن إرسال طلب فارغ أو رقم ماستر غير مطابق (12 رقماً)')),
      );
      return;
    }

    if (!_adsEnabled) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'استقبال الإعلانات المدفوعة متوقف حالياً من الإدارة',
          ),
        ),
      );

      return;
    }

    if (_selectedDays <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'مدة الإعلان يجب أن تكون يوماً واحداً على الأقل',
          ),
        ),
      );

      return;
    }

    setState(() => _saving = true);

    try {
      await CommercialService.instance.createAd(
        data: {
          'title': _business.text.trim().isNotEmpty ? _business.text.trim() : _selectedCategory,

          'businessName':
          _business.text.trim(),

          'description':
          _description.text.trim(),

          'category':
          _selectedCategory,

          'whatsapp':
          _whatsapp.text.trim(),

          'website':
          _website.text.trim(),

          'masterCardNumber':
          _masterCard.text.trim(),

          'governorate':
          _governorate.text.trim(),

          'district':
          _district.text.trim(),

          'address':
          _address.text.trim(),

          'latitude':
          _lat,

          'longitude':
          _lng,

          'placements':
          _placements,

          'featured':
          _featured,

          'notificationPromotion':
          _notificationPromotion,

          'startAt':
          _start.text.trim(),

          'endAt':
          _end.text.trim(),

          'durationDays':
          _selectedDays,

          'pricePerDay':
          _pricePerDay,

          'requestedPrice':
          _calculatedPrice.toDouble(),

          'priceCurrency':
          'IQD',

          'pricingSource':
          'adminSettings',

          'requestedPaymentMethod':
          'wallet',

          'zainCashGatewayReady':
          false,

          'paymentDestination':
          'adminWallet',

          // بيانات الذكاء الاصطناعي
          'aiGenerated':
          _generatedImageUrl.isNotEmpty,

          'aiImageUrl':
          _generatedImageUrl,

          'aiImagePrompt':
          _generatedPrompt,

          'aiImageStyle':
          _selectedAiStyle,

          'aiImageSize':
          _selectedImageSize,
        },

        // أبقينا رفع الصور الأصلي كما هو
        imageFiles: const [],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'تم إرسال الإعلان للمراجعة',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'تعذر إرسال الإعلان: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(
              () => _saving = false,
        );
      }
    }
  }

  Widget _field(
      TextEditingController c,
      String label, {
        int maxLines = 1,
        TextInputType? type,
        bool required = false,
        bool readOnly = false,
      }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: type,
        readOnly: readOnly,
        validator: required
            ? (v) =>
        v == null ||
            v.trim().isEmpty
            ? 'هذا الحقل مطلوب'
            : null
            : null,
        decoration:
        InputDecoration(
          labelText: label,
          border:
          const OutlineInputBorder(),
          filled: true,
        ),
      ),
    );
  }

  // ============================================================
  // واجهة الذكاء الاصطناعي
  // ============================================================

  Widget _buildAiImageSection() {
    return Container(
      margin:
      const EdgeInsets.only(
        top: 4,
        bottom: 18,
      ),
      padding:
      const EdgeInsets.all(16),
      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(
            alpha: 0.35,
          ),
        ),
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(
          alpha: 0.12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration:
                BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                  color:
                  Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(
                    alpha: 0.12,
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color:
                  Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      'إنشاء صورة بالذكاء الاصطناعي',
                      style:
                      TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      'اختَر نوع النشاط واكتب التفاصيل ثم دع الذكاء الاصطناعي يصمم صورة الإعلان.',
                      style:
                      TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedAiStyle,
                  decoration: const InputDecoration(
                    labelText: 'ستايل الصورة',
                    prefixIcon: Icon(Icons.palette_outlined),
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  items: _aiStyles.map((style) {
                    return DropdownMenuItem<String>(
                      value: style,
                      child: Text(style),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedAiStyle = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedImageSize,
                  decoration: const InputDecoration(
                    labelText: 'مقاس الصورة',
                    prefixIcon: Icon(Icons.aspect_ratio),
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  items: _imageSizes.map((size) {
                    return DropdownMenuItem<String>(
                      value: size,
                      child: Text(size),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedImageSize = value;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          SizedBox(
            width: double.infinity,
            height: 52,
            child:
            ElevatedButton.icon(
              onPressed:
              _isGeneratingAiImage
                  ? null
                  : _generateAiImage,
              icon:
              _isGeneratingAiImage
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth:
                  2,
                ),
              )
                  : const Icon(
                Icons
                    .auto_awesome,
              ),
              label:
              Text(
                _isGeneratingAiImage
                    ? 'جاري إنشاء الصورة...'
                    : _generatedImageUrl
                    .isEmpty
                    ? 'إنشاء صورة الإعلان'
                    : 'إنشاء صورة أخرى',
              ),
            ),
          ),

          if (_isGeneratingAiImage) ...[
            const SizedBox(
              height: 12,
            ),
            const LinearProgressIndicator(),
            const SizedBox(
              height: 8,
            ),
            const Center(
              child: Text(
                'الذكاء الاصطناعي يصمم الصورة...',
              ),
            ),
          ],

          if (_generatedImageUrl
              .isNotEmpty) ...[
            const SizedBox(
              height: 18,
            ),

            const Text(
              'الصورة المقترحة',
              style:
              TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            ClipRRect(
              borderRadius:
              BorderRadius.circular(
                16,
              ),
              child:
              AspectRatio(
                aspectRatio:
                _selectedImageSize ==
                    'أفقي 16:9'
                    ? 16 / 9
                    : _selectedImageSize ==
                    'طولي 4:5'
                    ? 4 / 5
                    : 1,
                child:
                Image.network(
                  _generatedImageUrl,
                  fit:
                  BoxFit.cover,
                  loadingBuilder:
                      (
                      context,
                      child,
                      loadingProgress,
                      ) {
                    if (loadingProgress ==
                        null) {
                      return child;
                    }

                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  },
                  errorBuilder:
                      (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return Container(
                      alignment:
                      Alignment
                          .center,
                      color:
                      Colors.grey
                          .shade200,
                      child:
                      const Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Icon(
                            Icons
                                .broken_image_outlined,
                            size: 42,
                          ),
                          SizedBox(
                            height:
                            8,
                          ),
                          Text(
                            'تعذر عرض الصورة',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                Expanded(
                  child:
                  OutlinedButton.icon(
                    onPressed:
                    _isGeneratingAiImage
                        ? null
                        : _generateAiImage,
                    icon:
                    const Icon(
                      Icons.refresh,
                    ),
                    label:
                    const Text(
                      'إعادة التوليد',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child:
                  OutlinedButton.icon(
                    onPressed:
                    _removeGeneratedImage,
                    icon:
                    const Icon(
                      Icons.delete_outline,
                    ),
                    label:
                    const Text(
                      'حذف الصورة',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets.all(
                10,
              ),
              decoration:
              BoxDecoration(
                color:
                Colors.green
                    .withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
              child:
              const Row(
                children: [
                  Icon(
                    Icons
                        .check_circle_outline,
                    color:
                    Colors.green,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child:
                    Text(
                      'سيتم إرفاق هذه الصورة مع بيانات الإعلان.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text(
          'إضافة إعلان مدفوع',
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
          const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            64,
          ),
          children: [
            _field(
              _business,
              'اسم النشاط / الشركة',
              required: true,
            ),

            _field(
              _description,
              'وصف الإعلان',
              maxLines: 4,
              required: true,
            ),

            Padding(
              padding:
              const EdgeInsets.only(
                bottom: 12,
              ),
              child:
              DropdownButtonFormField<
                  String>(
                initialValue:
                _selectedCategory,
                decoration:
                const InputDecoration(
                  labelText:
                  'نوع النشاط',
                  border:
                  OutlineInputBorder(),
                  filled: true,
                ),
                items:
                _adCategories
                    .map(
                      (category) =>
                      DropdownMenuItem<
                          String>(
                        value:
                        category,
                        child:
                        Text(
                          category,
                        ),
                      ),
                )
                    .toList(),
                onChanged:
                    (value) {
                  if (value ==
                      null) {
                    return;
                  }

                  setState(() {
                    _selectedCategory =
                        value;

                    // عند تغيير نوع النشاط
                    // نحذف الصورة القديمة حتى لا تبقى
                    // صورة مطعم مثلاً بعد اختيار صيدلية.
                    _generatedImageUrl =
                    '';

                    _generatedPrompt =
                    '';
                  });
                },
              ),
            ),

            // ==================================================
            // الذكاء الاصطناعي
            // ==================================================

            _buildAiImageSection(),

            // ==================================================

            _field(
              _whatsapp,
              'WhatsApp',
              type:
              TextInputType.phone,
            ),

            _field(
              _website,
              'الرابط / الموقع الإلكتروني',
              type:
              TextInputType.url,
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _masterCard,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'رقم ماستر كارد صاحب الإعلان (للدفع الآلي والاستقطاع)',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'حقل رقم الماستر كارد مطلوب ولا يمكن إرساله فارغاً';
                  }
                  final cleaned = v.trim().replaceAll(RegExp(r'\s+'), '');
                  if (cleaned.length != 12 || double.tryParse(cleaned) == null) {
                    return 'رقم الماستر كارد يجب أن يتكون من 12 رقماً بالضبط';
                  }
                  return null;
                },
              ),
            ),

            Row(
              children: [
                Expanded(
                  child:
                  DropdownButtonFormField<String>(
                    initialValue: _iraqiGovernorates.contains(_governorate.text) ? _governorate.text : _iraqiGovernorates.first,
                    decoration: const InputDecoration(
                      labelText: 'المحافظة',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    items: _iraqiGovernorates.map((g) {
                      return DropdownMenuItem(
                        value: g,
                        child: Text(g),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _governorate.text = val ?? 'بغداد';
                      });
                    },
                    validator: (v) => v == null || v.trim().isEmpty ? 'يرجى اختيار المحافظة' : null,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child:
                  _field(
                    _district,
                    'القضاء',
                  ),
                ),
              ],
            ),

            _field(
              _address,
              'العنوان',
              required: true,
            ),

            OutlinedButton.icon(
              onPressed:
              _pickLocation,
              icon:
              const Icon(
                Icons.location_on,
              ),
              label:
              Text(
                _lat == 0 &&
                    _lng == 0
                    ? 'تحديد موقع الإعلان على الخريطة'
                    : 'تم تحديد الموقع: $_lat, $_lng',
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            const SizedBox(
              height: 14,
            ),

            const Text(
              'أماكن ظهور الإعلان',
              style:
              TextStyle(
                fontWeight:
                FontWeight.bold,
                fontSize: 16,
              ),
            ),

            ..._placementTile(
              'home',
              'الرئيسية',
              Icons.home,
            ),

            ..._placementTile(
              'citizen',
              'شاشة المواطن',
              Icons.public,
            ),

            ..._placementTile(
              'stations',
              'بين المحطات',
              Icons
                  .local_gas_station,
            ),

            ..._placementTile(
              'stationDetails',
              'تفاصيل المحطة',
              Icons.info_outline,
            ),

            SwitchListTile(
              value:
              _featured,
              onChanged:
                  (v) =>
                  setState(
                        () =>
                    _featured =
                        v,
                  ),
              title:
              const Text(
                'إعلان مميز',
              ),
              subtitle:
              const Text(
                'يظهر في مقدمة الإعلانات',
              ),
            ),

            SwitchListTile(
              value:
              _notificationPromotion,
              onChanged:
                  (v) =>
                  setState(
                        () =>
                    _notificationPromotion =
                        v,
                  ),
              title:
              const Text(
                'طلب ترويج عبر الإشعارات',
              ),
              subtitle:
              const Text(
                'يحتاج موافقة الإدارة',
              ),
            ),

            _field(
              _duration,
              'مدة الإعلان بالأيام',
              type:
              TextInputType.number,
              required: true,
            ),

            _field(
              _price,
              'المبلغ الكلي (دينار عراقي)',
              type:
              TextInputType.number,
              readOnly: true,
            ),

            Container(
              margin:
              const EdgeInsets.only(
                bottom: 14,
              ),
              padding:
              const EdgeInsets.all(
                14,
              ),
              decoration:
              BoxDecoration(
                border:
                Border.all(
                  color:
                  Theme.of(context)
                      .dividerColor,
                ),
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons
                            .payments_outlined,
                      ),
                      SizedBox(
                        width:
                        8,
                      ),
                      Text(
                        'تفاصيل سعر الإعلان',
                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight
                              .bold,
                          fontSize:
                          16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    'سعر اليوم الواحد: ${_pricePerDay.toString()} د.ع',
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    'عدد الأيام: $_selectedDays',
                  ),

                  const Divider(
                    height: 22,
                  ),

                  Text(
                    'المبلغ المطلوب: $_calculatedPrice د.ع',
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      fontSize:
                      17,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'طريقة الدفع : عن طريق الدفع الالكتروني البوابة الامنة',
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                Expanded(
                  child:
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _pickDate(_start);
                      setState(() {
                        _syncEndDate();
                      });
                    },
                    icon:
                    const Icon(
                      Icons.date_range,
                    ),
                    label:
                    Text(
                      _start.text
                          .isEmpty
                          ? 'بداية الإعلان'
                          : 'البداية: ${_start.text}',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          _end.text.isEmpty ? 'النهاية (تلقائي)' : 'النهاية: ${_end.text}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            if (_settingsLoading)
              const Padding(
                padding:
                EdgeInsets.only(
                  bottom: 12,
                ),
                child:
                LinearProgressIndicator(),
              ),

            if (!_adsEnabled &&
                !_settingsLoading)
              const Padding(
                padding:
                EdgeInsets.only(
                  bottom: 12,
                ),
                child:
                Text(
                  'استقبال طلبات الإعلانات المدفوعة متوقف حالياً.',
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
              ),

            ElevatedButton.icon(
              onPressed:
              (_saving ||
                  _settingsLoading ||
                  !_adsEnabled)
                  ? null
                  : _save,
              icon:
              const Icon(
                Icons.send,
              ),
              label:
              Text(
                _saving
                    ? 'جارٍ الإرسال...'
                    : 'إرسال الإعلان للمراجعة',
              ),
            ),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _placementTile(
      String value,
      String title,
      IconData icon,
      ) {
    final selected =
    _placements.contains(
      value,
    );

    return [
      CheckboxListTile(
        value: selected,
        onChanged:
            (v) =>
            setState(
                  () {
                if (v == true) {
                  if (!_placements
                      .contains(value)) {
                    _placements.add(
                      value,
                    );
                  }
                } else {
                  _placements.remove(
                    value,
                  );
                }
              },
            ),
        secondary:
        Icon(icon),
        title:
        Text(title),
      ),
    ];
  }
}
