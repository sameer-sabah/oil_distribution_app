import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/vehicle_coupon.dart';
import '../models/fueling_log.dart';

class OilCouponService {
  OilCouponService._();
  static final OilCouponService instance = OilCouponService._();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  DatabaseReference get vehiclesRef => _database.ref('vehicles');
  DatabaseReference get fuelingLogsRef => _database.ref('fuelingLogs');
  DatabaseReference get branchRulesRef => _database.ref('branchCouponRules');

  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  // Get branch manager rules
  Future<Map<String, dynamic>> getBranchRules() async {
    final snap = await branchRulesRef.get();
    if (snap.exists && snap.value is Map) {
      final map = Map<String, dynamic>.from(snap.value as Map);
      return {
        'privateQty': double.tryParse(map['privateQty']?.toString() ?? '40') ?? 40.0,
        'privateIntervalDays': int.tryParse(map['privateIntervalDays']?.toString() ?? '2') ?? 2,
        'govMonthlyQuota': double.tryParse(map['govMonthlyQuota']?.toString() ?? '500') ?? 500.0,
      };
    }
    return {
      'privateQty': 40.0,
      'privateIntervalDays': 2,
      'govMonthlyQuota': 500.0,
    };
  }

  // Branch manager updates rules
  Future<void> setBranchRules({
    required double privateQty,
    required int privateIntervalDays,
    required double govMonthlyQuota,
  }) async {
    await branchRulesRef.set({
      'privateQty': privateQty,
      'privateIntervalDays': privateIntervalDays,
      'govMonthlyQuota': govMonthlyQuota,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Register vehicle coupon
  Future<void> registerVehicle({
    required String ownerName,
    required String plateGovernorate,
    required String plateNumberCode,
    required String plateLetter,
    required String governmentEntity,
    required String vehicleType,
    required String vehicleModelName,
    required String vehicleColor,
    required String phone,
    required String password,
    required String category, // 'government' or 'private'
    required String nfcChipId,
  }) async {
    // Check for duplicate plate number
    final snap = await vehiclesRef.get();
    if (snap.exists && snap.value is Map) {
      final raw = Map<dynamic, dynamic>.from(snap.value as Map);
      for (final entry in raw.entries) {
        if (entry.value is Map) {
          final existing = VehicleCoupon.fromMap(entry.key.toString(), Map<dynamic, dynamic>.from(entry.value as Map));
          if (category == 'government' && existing.isGovernment) {
            if (existing.governmentEntity.trim().toLowerCase() == governmentEntity.trim().toLowerCase() &&
                existing.plateNumberCode.trim() == plateNumberCode.trim()) {
              throw Exception('رقم المركبة الحكومية لهذه الجهة مسجل مسبقاً في النظام');
            }
          } else if (category == 'private' && !existing.isGovernment) {
            if (existing.plateGovernorate.trim() == plateGovernorate.trim() &&
                existing.plateNumberCode.trim() == plateNumberCode.trim() &&
                existing.plateLetter.trim().toLowerCase() == plateLetter.trim().toLowerCase()) {
              throw Exception('رقم اللوحة هذه مسجل مسبقاً في النظام، لا يمكن تكرار التسجيل');
            }
          }
        }
      }
    }

    final uid = currentUid;
    final key = vehiclesRef.push().key!;
    final now = DateTime.now().toIso8601String();

    final rules = await getBranchRules();
    final isGov = category == 'government';
    final allowedQty = isGov ? (rules['govMonthlyQuota'] as double) : (rules['privateQty'] as double);
    final interval = isGov ? 30 : (rules['privateIntervalDays'] as int);

    final coupon = VehicleCoupon(
      id: key,
      ownerUid: uid,
      ownerName: ownerName.trim(),
      plateGovernorate: plateGovernorate.trim(),
      plateNumberCode: plateNumberCode.trim(),
      plateLetter: plateLetter.trim(),
      governmentEntity: governmentEntity.trim(),
      vehicleType: vehicleType.trim(),
      vehicleModelName: vehicleModelName.trim(),
      vehicleColor: vehicleColor.trim(),
      phone: phone.trim(),
      password: password.trim(),
      fuelType: 'بنزين',
      allowedQuantity: allowedQty,
      intervalDays: interval,
      category: category,
      consumedMonthlyQuota: 0.0,
      lastResetMonth: '',
      nfcChipId: nfcChipId.trim().isEmpty ? key : nfcChipId.trim(),
      lastFuelingAt: '',
      createdAt: now,
    );

    await vehiclesRef.child(key).set(coupon.toMap());
  }

  // Login with plate number and password (Private)
  Future<VehicleCoupon?> loginWithPlateAndPin({
    required String governorate,
    required String numberCode,
    required String password,
  }) async {
    final snap = await vehiclesRef.get();
    if (!snap.exists || snap.value is! Map) return null;

    final raw = Map<dynamic, dynamic>.from(snap.value as Map);
    for (final entry in raw.entries) {
      if (entry.value is Map) {
        final vehicle = VehicleCoupon.fromMap(entry.key.toString(), Map<dynamic, dynamic>.from(entry.value as Map));
        if (!vehicle.isGovernment &&
            vehicle.plateGovernorate.trim() == governorate.trim() &&
            vehicle.plateNumberCode.trim() == numberCode.trim() &&
            vehicle.password.trim() == password.trim()) {
          return vehicle;
        }
      }
    }
    return null;
  }

  // Login government vehicle with entity name, plate number, and password
  Future<VehicleCoupon?> loginGovernmentVehicle({
    required String governmentEntity,
    required String numberCode,
    required String password,
  }) async {
    final snap = await vehiclesRef.get();
    if (!snap.exists || snap.value is! Map) return null;

    final raw = Map<dynamic, dynamic>.from(snap.value as Map);
    for (final entry in raw.entries) {
      if (entry.value is Map) {
        final vehicle = VehicleCoupon.fromMap(entry.key.toString(), Map<dynamic, dynamic>.from(entry.value as Map));
        if (vehicle.isGovernment &&
            vehicle.governmentEntity.trim().toLowerCase() == governmentEntity.trim().toLowerCase() &&
            vehicle.plateNumberCode.trim() == numberCode.trim() &&
            vehicle.password.trim() == password.trim()) {
          return vehicle;
        }
      }
    }
    return null;
  }

  // Get vehicle by ID
  Future<VehicleCoupon?> getVehicle(String vehicleId) async {
    final snap = await vehiclesRef.child(vehicleId).get();
    if (!snap.exists || snap.value is! Map) return null;
    return VehicleCoupon.fromMap(vehicleId, Map<dynamic, dynamic>.from(snap.value as Map));
  }

  // Search vehicle by ID or plate number or phone
  Future<VehicleCoupon?> searchVehicle(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return null;

    final snap = await vehiclesRef.get();
    if (!snap.exists || snap.value is! Map) return null;

    final raw = Map<dynamic, dynamic>.from(snap.value as Map);
    for (final entry in raw.entries) {
      if (entry.value is Map) {
        final vehicle = VehicleCoupon.fromMap(entry.key.toString(), Map<dynamic, dynamic>.from(entry.value as Map));
        final vId = vehicle.id.trim().toLowerCase();
        final pFull = vehicle.plateFull.trim().toLowerCase();
        final pCode = vehicle.plateNumberCode.trim().toLowerCase();
        final phoneNum = vehicle.phone.trim().toLowerCase();

        if (vId == q || pFull.contains(q) || pCode == q || phoneNum == q || q.contains(vId)) {
          return vehicle;
        }
      }
    }
    return null;
  }

  // Confirm fueling
  Future<void> confirmFueling({
    required String vehicleId,
    required String stationId,
    required String stationName,
    required String outletNumber,
    required String employeeUid,
    required String employeeName,
    double? customQuantity,
  }) async {
    final vehicle = await getVehicle(vehicleId);
    if (vehicle == null) {
      throw Exception('المركبة أو الكوبون غير موجود');
    }

    if (!vehicle.isEligible) {
      throw Exception('المركبة غير مستحقة للتزويد حالياً (نفذت الحصة أو لم يحن موعد الاستحقاق)');
    }

    final now = DateTime.now();
    final nowIso = now.toIso8601String();
    final currentMonth = nowIso.substring(0, 7);

    double qtyToConsume = vehicle.allowedQuantity;
    if (vehicle.isGovernment && customQuantity != null && customQuantity > 0) {
      final remaining = vehicle.remainingGovernmentQuota;
      if (customQuantity > remaining) {
        throw Exception('الكمية المطلوبة ($customQuantity لتر) تتجاوز الرصيد المتبقي من الحصة الشهرية ($remaining لتر)');
      }
      qtyToConsume = customQuantity;
    }

    final logKey = fuelingLogsRef.push().key!;

    final log = FuelingLog(
      id: logKey,
      vehicleId: vehicleId,
      plateNumber: vehicle.plateFull,
      stationId: stationId,
      stationName: stationName,
      outletNumber: outletNumber,
      employeeUid: employeeUid,
      employeeName: employeeName,
      fuelType: vehicle.fuelType,
      quantity: qtyToConsume,
      createdAt: nowIso,
    );

    final updates = <String, Object?>{
      'fuelingLogs/$logKey': log.toMap(),
    };

    if (vehicle.isGovernment) {
      final activeConsumed = vehicle.lastResetMonth == currentMonth ? vehicle.consumedMonthlyQuota : 0.0;
      final newConsumed = activeConsumed + qtyToConsume;
      updates['vehicles/$vehicleId/consumedMonthlyQuota'] = newConsumed;
      updates['vehicles/$vehicleId/lastResetMonth'] = currentMonth;
    } else {
      updates['vehicles/$vehicleId/lastFuelingAt'] = nowIso;
    }

    await _database.ref().update(updates);
  }

  // Stream fueling logs for vehicle
  Stream<List<FuelingLog>> vehicleLogsStream(String vehicleId) {
    return fuelingLogsRef
        .orderByChild('vehicleId')
        .equalTo(vehicleId)
        .onValue
        .map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <FuelingLog>[];
      final raw = Map<dynamic, dynamic>.from(value);
      final list = raw.entries
          .where((e) => e.value is Map)
          .map((e) => FuelingLog.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
