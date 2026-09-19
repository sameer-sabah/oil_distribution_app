import 'package:firebase_database/firebase_database.dart';

class CommercialPaymentSettings {
  final bool adsEnabled;
  final int pricePerDay;
  final String currency;
  final bool zainCashEnabled;
  final bool gatewayReady;
  final String environment;
  final String merchantBusinessName;
  final String merchantWalletNumber;
  final String merchantId;
  final String clientId;
  final String serviceType;

  const CommercialPaymentSettings({
    required this.adsEnabled,
    required this.pricePerDay,
    required this.currency,
    required this.zainCashEnabled,
    required this.gatewayReady,
    required this.environment,
    required this.merchantBusinessName,
    required this.merchantWalletNumber,
    required this.merchantId,
    required this.clientId,
    required this.serviceType,
  });

  factory CommercialPaymentSettings.defaults() {
    return const CommercialPaymentSettings(
      adsEnabled: true,
      pricePerDay: 2000,
      currency: 'IQD',
      zainCashEnabled: false,
      gatewayReady: false,
      environment: 'test',
      merchantBusinessName: '',
      merchantWalletNumber: '',
      merchantId: '',
      clientId: '',
      serviceType: '',
    );
  }

  factory CommercialPaymentSettings.fromMap(
      Map<String, dynamic> map,
      ) {
    final defaults =
    CommercialPaymentSettings.defaults();

    return CommercialPaymentSettings(
      adsEnabled:
      map['adsEnabled'] is bool
          ? map['adsEnabled'] as bool
          : defaults.adsEnabled,
      pricePerDay:
      int.tryParse(
        map['pricePerDay']?.toString() ?? '',
      ) ??
          defaults.pricePerDay,
      currency:
      map['currency']?.toString().trim().isNotEmpty == true
          ? map['currency'].toString()
          : defaults.currency,
      zainCashEnabled:
      map['zainCashEnabled'] is bool
          ? map['zainCashEnabled'] as bool
          : defaults.zainCashEnabled,
      gatewayReady:
      map['gatewayReady'] is bool
          ? map['gatewayReady'] as bool
          : defaults.gatewayReady,
      environment:
      map['environment']?.toString() == 'production'
          ? 'production'
          : 'test',
      merchantBusinessName:
      map['merchantBusinessName']?.toString() ?? '',
      merchantWalletNumber:
      map['merchantWalletNumber']?.toString() ?? '',
      merchantId:
      map['merchantId']?.toString() ?? '',
      clientId:
      map['clientId']?.toString() ?? '',
      serviceType:
      map['serviceType']?.toString() ?? '',
    );
  }
}

class CommercialPaymentSettingsService {
  CommercialPaymentSettingsService._();

  static final CommercialPaymentSettingsService instance =
  CommercialPaymentSettingsService._();

  final FirebaseDatabase _database =
      FirebaseDatabase.instance;

  DatabaseReference get _settingsRef =>
      _database.ref(
        'systemSettings/commercialAds',
      );

  Future<CommercialPaymentSettings>
  getSettings() async {
    final snapshot =
    await _settingsRef.get();

    if (!snapshot.exists ||
        snapshot.value == null ||
        snapshot.value is! Map) {
      return CommercialPaymentSettings.defaults();
    }

    final raw =
    Map<dynamic, dynamic>.from(
      snapshot.value as Map,
    );

    return CommercialPaymentSettings.fromMap(
      raw.map(
            (key, value) => MapEntry(
          key.toString(),
          value,
        ),
      ),
    );
  }

  Stream<CommercialPaymentSettings>
  settingsStream() {
    return _settingsRef.onValue.map(
          (event) {
        final value =
            event.snapshot.value;

        if (value == null ||
            value is! Map) {
          return CommercialPaymentSettings.defaults();
        }

        final raw =
        Map<dynamic, dynamic>.from(
          value,
        );

        return CommercialPaymentSettings.fromMap(
          raw.map(
                (key, value) => MapEntry(
              key.toString(),
              value,
            ),
          ),
        );
      },
    );
  }

  Future<void> saveAdminSettings({
    required bool adsEnabled,
    required int pricePerDay,
    required bool zainCashEnabled,
    required String environment,
    required String merchantBusinessName,
    required String merchantWalletNumber,
    required String merchantId,
    required String clientId,
    required String serviceType,
  }) async {
    await _settingsRef.update({
      'adsEnabled': adsEnabled,
      'pricePerDay': pricePerDay,
      'currency': 'IQD',
      'zainCashEnabled': zainCashEnabled,
      'environment': environment,
      'merchantBusinessName':
      merchantBusinessName.trim(),
      'merchantWalletNumber':
      merchantWalletNumber.trim(),
      'merchantId':
      merchantId.trim(),
      'clientId':
      clientId.trim(),
      'serviceType':
      serviceType.trim(),
      'gatewayReady': false,
      'updatedAt':
      DateTime.now().toIso8601String(),
    });
  }
}
