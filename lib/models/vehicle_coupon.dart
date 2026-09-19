class VehicleCoupon {
  final String id;
  final String ownerUid;
  final String ownerName;
  final String plateGovernorate; // المحافظة (للخصوصي)
  final String plateNumberCode; // الرقم المروري
  final String plateLetter; // الحرف
  final String governmentEntity; // الجهة التابعة لها المركبة (للحكومي)
  final String vehicleType; // خصوصي، تاكسي، حكومي...
  final String vehicleModelName; // اسم المركبة
  final String vehicleColor; // اللون
  final String phone; // رقم الهاتف
  final String password; // الرقم السري
  final String fuelType; // حصراً بنزين
  final double allowedQuantity; // الكمية المسموحة (شهرية للحكومي، أو لكل دفعة للخصوصي)
  final int intervalDays; // فترة التزويد (للخصوصي)
  final String category; // 'government' أو 'private' (خصوصي)
  final double consumedMonthlyQuota; // ما تم استهلاكه هذا الشهر (للحكومي)
  final String lastResetMonth; // الشهر الذي تم فيه التصفير آخر مرة
  final String nfcChipId; // معرف شريحة NFC (للحكومي)
  final String lastFuelingAt;
  final String createdAt;

  const VehicleCoupon({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.plateGovernorate,
    required this.plateNumberCode,
    required this.plateLetter,
    required this.governmentEntity,
    required this.vehicleType,
    required this.vehicleModelName,
    required this.vehicleColor,
    required this.phone,
    required this.password,
    required this.fuelType,
    required this.allowedQuantity,
    required this.intervalDays,
    required this.category,
    required this.consumedMonthlyQuota,
    required this.lastResetMonth,
    required this.nfcChipId,
    required this.lastFuelingAt,
    required this.createdAt,
  });

  static const Map<String, String> iraqiGovernorateCodes = {
    'بغداد': '11',
    'نينوى': '12',
    'ميسان': '13',
    'البصرة': '14',
    'الأنبار': '15',
    'الانبار': '15',
    'القادسية': '16',
    'المثنى': '17',
    'بابل': '18',
    'كربلاء': '19',
    'كربلاء المقدسة': '19',
    'ديالى': '20',
    'السليمانية': '21',
    'أربيل': '22',
    'اربيل': '22',
    'حلبجة': '23',
    'دهوك': '24',
    'كركوك': '25',
    'صلاح الدين': '26',
    'ذي قار': '27',
    'النجف': '28',
    'النجف الأشرف': '28',
    'النجف الاشرف': '28',
    'واسط': '29',
  };

  String get plateFull {
    if (isGovernment) {
      return 'حكومي - $governmentEntity ($plateNumberCode)'.trim();
    }
    final code = iraqiGovernorateCodes[plateGovernorate] ?? '';
    final govPart = code.isNotEmpty ? '$plateGovernorate -$code' : plateGovernorate;
    return '$govPart $plateNumberCode'.trim();
  }

  bool get isGovernment => category == 'government';

  bool get isEligible {
    final currentMonth = DateTime.now().toIso8601String().substring(0, 7); // "YYYY-MM"
    
    if (isGovernment) {
      final activeConsumed = lastResetMonth == currentMonth ? consumedMonthlyQuota : 0.0;
      return activeConsumed < allowedQuantity;
    } else {
      if (lastFuelingAt.isEmpty) return true;
      final lastDate = DateTime.tryParse(lastFuelingAt);
      if (lastDate == null) return true;
      
      final nextEligibleDate = lastDate.add(Duration(days: intervalDays));
      return DateTime.now().isAfter(nextEligibleDate) || DateTime.now().isAtSameMomentAs(nextEligibleDate);
    }
  }

  double get remainingGovernmentQuota {
    if (!isGovernment) return allowedQuantity;
    final currentMonth = DateTime.now().toIso8601String().substring(0, 7);
    final activeConsumed = lastResetMonth == currentMonth ? consumedMonthlyQuota : 0.0;
    return (allowedQuantity - activeConsumed).clamp(0.0, allowedQuantity);
  }

  DateTime? get nextEligibleDate {
    if (isGovernment) return null;
    if (lastFuelingAt.isEmpty) return null;
    final lastDate = DateTime.tryParse(lastFuelingAt);
    if (lastDate == null) return null;
    return lastDate.add(Duration(days: intervalDays));
  }

  factory VehicleCoupon.fromMap(String id, Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    return VehicleCoupon(
      id: id,
      ownerUid: map['ownerUid']?.toString() ?? '',
      ownerName: map['ownerName']?.toString() ?? '',
      plateGovernorate: map['plateGovernorate']?.toString() ?? 'بغداد',
      plateNumberCode: map['plateNumberCode']?.toString() ?? '',
      plateLetter: map['plateLetter']?.toString() ?? '',
      governmentEntity: map['governmentEntity']?.toString() ?? '',
      vehicleType: map['vehicleType']?.toString() ?? 'خصوصي',
      vehicleModelName: map['vehicleModelName']?.toString() ?? '',
      vehicleColor: map['vehicleColor']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      fuelType: 'بنزين',
      allowedQuantity: double.tryParse(map['allowedQuantity']?.toString() ?? '40') ?? 40.0,
      intervalDays: int.tryParse(map['intervalDays']?.toString() ?? '2') ?? 2,
      category: map['category']?.toString() ?? 'private',
      consumedMonthlyQuota: double.tryParse(map['consumedMonthlyQuota']?.toString() ?? '0') ?? 0.0,
      lastResetMonth: map['lastResetMonth']?.toString() ?? '',
      nfcChipId: map['nfcChipId']?.toString() ?? id,
      lastFuelingAt: map['lastFuelingAt']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'plateGovernorate': plateGovernorate,
      'plateNumberCode': plateNumberCode,
      'plateLetter': plateLetter,
      'governmentEntity': governmentEntity,
      'vehicleType': vehicleType,
      'vehicleModelName': vehicleModelName,
      'vehicleColor': vehicleColor,
      'phone': phone,
      'password': password,
      'fuelType': fuelType,
      'allowedQuantity': allowedQuantity,
      'intervalDays': intervalDays,
      'category': category,
      'consumedMonthlyQuota': consumedMonthlyQuota,
      'lastResetMonth': lastResetMonth,
      'nfcChipId': nfcChipId,
      'lastFuelingAt': lastFuelingAt,
      'createdAt': createdAt,
    };
  }
}
