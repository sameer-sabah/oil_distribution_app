import 'package:flutter/material.dart';

import '../../services/commercial_payment_settings_service.dart';

class CommercialPaymentSettingsScreen
    extends StatefulWidget {
  const CommercialPaymentSettingsScreen({
    super.key,
  });

  @override
  State<CommercialPaymentSettingsScreen>
  createState() =>
      _CommercialPaymentSettingsScreenState();
}

class _CommercialPaymentSettingsScreenState
    extends State<CommercialPaymentSettingsScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _pricePerDay =
  TextEditingController();

  final _businessName =
  TextEditingController();

  final _walletNumber =
  TextEditingController();

  final _merchantId =
  TextEditingController();

  final _clientId =
  TextEditingController();

  final _serviceType =
  TextEditingController();

  bool _adsEnabled = true;
  bool _zainCashEnabled = false;
  bool _gatewayReady = false;
  String _environment = 'test';
  bool _loading = true;
  bool _saving = false;

  final CommercialPaymentSettingsService
  _settingsService =
      CommercialPaymentSettingsService.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pricePerDay.dispose();
    _businessName.dispose();
    _walletNumber.dispose();
    _merchantId.dispose();
    _clientId.dispose();
    _serviceType.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final settings =
      await _settingsService.getSettings();

      if (!mounted) return;

      _pricePerDay.text =
          settings.pricePerDay.toString();
      _businessName.text =
          settings.merchantBusinessName;
      _walletNumber.text =
          settings.merchantWalletNumber;
      _merchantId.text =
          settings.merchantId;
      _clientId.text =
          settings.clientId;
      _serviceType.text =
          settings.serviceType;

      setState(() {
        _adsEnabled =
            settings.adsEnabled;
        _zainCashEnabled =
            settings.zainCashEnabled;
        _gatewayReady =
            settings.gatewayReady;
        _environment =
            settings.environment;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تحميل الإعدادات: $e',
          ),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final int pricePerDay =
        int.tryParse(
          _pricePerDay.text.trim(),
        ) ??
            0;

    if (pricePerDay <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'سعر اليوم يجب أن يكون أكبر من صفر',
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _settingsService
          .saveAdminSettings(
        adsEnabled:
        _adsEnabled,
        pricePerDay:
        pricePerDay,
        zainCashEnabled:
        _zainCashEnabled,
        environment:
        _environment,
        merchantBusinessName:
        _businessName.text,
        merchantWalletNumber:
        _walletNumber.text,
        merchantId:
        _merchantId.text,
        clientId:
        _clientId.text,
        serviceType:
        _serviceType.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'تم حفظ إعدادات الإعلان وزين كاش',
          ),
        ),
      );

      await _load();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'تعذر حفظ الإعدادات: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child:
      TextFormField(
        controller:
        controller,
        keyboardType:
        keyboardType,
        validator:
        required
            ? (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        }
            : null,
        decoration:
        InputDecoration(
          labelText:
          label,
          hintText:
          hint,
          border:
          const OutlineInputBorder(),
          filled:
          true,
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context
      ) {
    return Scaffold(
      appBar:
      AppBar(
        title:
        const Text(
          'إعدادات الإعلانات وزين كاش',
        ),
        centerTitle:
        true,
      ),
      body:
      _loading
          ?
      const Center(
        child:
        CircularProgressIndicator(),
      )
          :
      Form(
        key:
        _formKey,
        child:
        ListView(
          padding:
          const EdgeInsets.all(
            16,
          ),
          children: [
            Card(
              child:
              Padding(
                padding:
                const EdgeInsets.all(
                  16,
                ),
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إعدادات سعر الإعلان',
                      style:
                      TextStyle(
                        fontSize:
                        18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height:
                      12,
                    ),
                    SwitchListTile(
                      contentPadding:
                      EdgeInsets.zero,
                      value:
                      _adsEnabled,
                      onChanged:
                          (value) {
                        setState(() {
                          _adsEnabled =
                              value;
                        });
                      },
                      title:
                      const Text(
                        'تفعيل الإعلانات المدفوعة',
                      ),
                      subtitle:
                      const Text(
                        'عند الإيقاف لا يتم استقبال طلبات إعلانات جديدة',
                      ),
                    ),
                    _field(
                      controller:
                      _pricePerDay,
                      label:
                      'سعر اليوم الواحد (دينار عراقي)',
                      keyboardType:
                      TextInputType.number,
                      required:
                      true,
                    ),
                    const Text(
                      'شاشة إضافة الإعلان تقرأ هذا السعر تلقائياً وتحسب: عدد الأيام × سعر اليوم.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height:
              12,
            ),
            Card(
              child:
              Padding(
                padding:
                const EdgeInsets.all(
                  16,
                ),
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إعدادات Zain Cash Business',
                      style:
                      TextStyle(
                        fontSize:
                        18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height:
                      12,
                    ),
                    Container(
                      padding:
                      const EdgeInsets.all(
                        12,
                      ),
                      decoration:
                      BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                        color:
                        Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      child:
                      Row(
                        children: [
                          Icon(
                            _gatewayReady
                                ?
                            Icons.verified
                                :
                            Icons.hourglass_top,
                          ),
                          const SizedBox(
                            width:
                            10,
                          ),
                          Expanded(
                            child:
                            Text(
                              _gatewayReady
                                  ?
                              'بوابة الدفع مرتبطة وجاهزة'
                                  :
                              'احفظ بيانات حساب رجال الأعمال هنا. الدفع الإلكتروني الفعلي يتفعل بعد وصول بيانات البوابة وربطها بشكل آمن.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height:
                      12,
                    ),
                    SwitchListTile(
                      contentPadding:
                      EdgeInsets.zero,
                      value:
                      _zainCashEnabled,
                      onChanged:
                          (value) {
                        setState(() {
                          _zainCashEnabled =
                              value;
                        });
                      },
                      title:
                      const Text(
                        'استخدام زين كاش للدفع',
                      ),
                      subtitle:
                      const Text(
                        'يمكن حفظ بيانات الحساب الآن، لكن الدفع لن يعتبر فعالاً حتى يكتمل الربط الآمن.',
                      ),
                    ),
                    _field(
                      controller:
                      _businessName,
                      label:
                      'اسم حساب رجال الأعمال / اسم الشركة',
                    ),
                    _field(
                      controller:
                      _walletNumber,
                      label:
                      'رقم محفظة / حساب زين كاش',
                      keyboardType:
                      TextInputType.phone,
                    ),
                    _field(
                      controller:
                      _merchantId,
                      label:
                      'Merchant ID',
                      hint:
                      'يُملأ إذا زين كاش زودتك به',
                    ),
                    _field(
                      controller:
                      _clientId,
                      label:
                      'Client ID',
                      hint:
                      'يُملأ إذا زين كاش زودتك به',
                    ),
                    _field(
                      controller:
                      _serviceType,
                      label:
                      'Service Type',
                      hint:
                      'يُملأ حسب بيانات زين كاش',
                    ),
                    DropdownButtonFormField<String>(
                      initialValue:
                      _environment,
                      decoration:
                      const InputDecoration(
                        labelText:
                        'بيئة الربط',
                        border:
                        OutlineInputBorder(),
                        filled:
                        true,
                      ),
                      items:
                      const [
                        DropdownMenuItem(
                          value:
                          'test',
                          child:
                          Text(
                            'Test / تجريبية',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                          'production',
                          child:
                          Text(
                            'Production / فعلية',
                          ),
                        ),
                      ],
                      onChanged:
                          (value) {
                        if (value == null) return;
                        setState(() {
                          _environment =
                              value;
                        });
                      },
                    ),
                    const SizedBox(
                      height:
                      14,
                    ),
                    Container(
                      padding:
                      const EdgeInsets.all(
                        12,
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
                          10,
                        ),
                      ),
                      child:
                      const Text(
                        'مهم: Client Secret / Access Token / API Secret لا يتم حفظها داخل Realtime Database ولا داخل تطبيق Flutter. عند وصولها من زين كاش نربطها من Backend آمن.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height:
              20,
            ),
            FilledButton.icon(
              onPressed:
              _saving
                  ?
              null
                  :
              _save,
              icon:
              const Icon(
                Icons.save,
              ),
              label:
              Text(
                _saving
                    ?
                'جارٍ الحفظ...'
                    :
                'حفظ الإعدادات',
              ),
            ),
            const SizedBox(
              height:
              30,
            ),
          ],
        ),
      ),
    );
  }
}
