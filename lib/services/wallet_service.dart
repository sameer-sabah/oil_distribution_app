import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/wallet_model.dart';

class WalletService {
  WalletService._();

  static final WalletService instance = WalletService._();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  DatabaseReference get paymentMethodsRef => _database.ref('paymentMethods');
  DatabaseReference get walletTopUpRequestsRef => _database.ref('walletTopUpRequests');
  DatabaseReference get advertiserAccountsRef => _database.ref('advertiserAccounts');

  // Payment Methods
  Stream<List<PaymentMethod>> paymentMethodsStream() {
    return paymentMethodsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <PaymentMethod>[];
      final raw = Map<dynamic, dynamic>.from(value);
      final list = raw.entries
          .where((e) => e.value is Map)
          .map((e) => PaymentMethod.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }).asBroadcastStream();
  }

  Future<void> savePaymentMethod({
    String? id,
    required String name,
    required String accountNumber,
    required String description,
    double? balance,
  }) async {
    final key = id?.trim().isNotEmpty == true ? id! : paymentMethodsRef.push().key!;
    final now = DateTime.now().toIso8601String();

    double finalBalance = balance ?? 0.0;
    if (id != null && balance == null) {
      final existingSnap = await paymentMethodsRef.child(id).get();
      if (existingSnap.exists && existingSnap.value is Map) {
        final exMap = Map<dynamic, dynamic>.from(existingSnap.value as Map);
        finalBalance = double.tryParse(exMap['balance']?.toString() ?? '0') ?? 0.0;
      }
    }

    final method = PaymentMethod(
      id: key,
      name: name.trim(),
      accountNumber: accountNumber.trim(),
      description: description.trim(),
      balance: finalBalance,
      createdAt: now,
    );
    await paymentMethodsRef.child(key).set(method.toMap());
  }

  Future<void> updatePaymentMethodBalance(String methodId, double newBalance) async {
    await paymentMethodsRef.child(methodId).update({
      'balance': newBalance,
    });
  }

  Future<void> deletePaymentMethod(String id) async {
    await paymentMethodsRef.child(id).remove();
  }

  // Wallet Top Up Requests
  Future<void> submitTopUpRequest({
    required String userId,
    required String userName,
    required String userPhone,
    required double amount,
    required String method,
    required String referenceNumber,
    required String receiptImageUrl,
  }) async {
    final key = walletTopUpRequestsRef.push().key!;
    final now = DateTime.now().toIso8601String();
    final request = WalletTopUpRequest(
      id: key,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      amount: amount,
      method: method,
      referenceNumber: referenceNumber,
      receiptImageUrl: receiptImageUrl,
      status: 'pending',
      createdAt: now,
      confirmedAt: '',
      adminNote: '',
    );
    await walletTopUpRequestsRef.child(key).set(request.toMap());
  }

  Stream<List<WalletTopUpRequest>> userTopUpRequestsStream(String userId) {
    return walletTopUpRequestsRef
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <WalletTopUpRequest>[];
      final raw = Map<dynamic, dynamic>.from(value);
      final list = raw.entries
          .where((e) => e.value is Map)
          .map((e) => WalletTopUpRequest.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }).asBroadcastStream();
  }

  Stream<List<WalletTopUpRequest>> allTopUpRequestsStream() {
    return walletTopUpRequestsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <WalletTopUpRequest>[];
      final raw = Map<dynamic, dynamic>.from(value);
      final list = raw.entries
          .where((e) => e.value is Map)
          .map((e) => WalletTopUpRequest.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }).asBroadcastStream();
  }

  Future<void> adminReviewRequest({
    required String requestId,
    required bool approved,
    String adminNote = '',
  }) async {
    final reqSnap = await walletTopUpRequestsRef.child(requestId).get();
    if (!reqSnap.exists || reqSnap.value is! Map) {
      throw Exception('طلب الشحن غير موجود');
    }
    final reqMap = Map<dynamic, dynamic>.from(reqSnap.value as Map);
    final request = WalletTopUpRequest.fromMap(requestId, reqMap);

    if (request.status != 'pending') {
      throw Exception('تم مراجعة هذا الطلب مسبقاً');
    }

    final now = DateTime.now().toIso8601String();
    final newStatus = approved ? 'approved' : 'rejected';

    final updates = <String, Object?>{
      'walletTopUpRequests/$requestId/status': newStatus,
      'walletTopUpRequests/$requestId/confirmedAt': now,
      'walletTopUpRequests/$requestId/adminNote': adminNote.trim(),
    };

    if (approved) {
      // Get current balance of advertiser account
      final accSnap = await advertiserAccountsRef.child(request.userId).get();
      double currentBalance = 0.0;
      if (accSnap.exists && accSnap.value is Map) {
        final accMap = Map<dynamic, dynamic>.from(accSnap.value as Map);
        currentBalance = double.tryParse(accMap['balance']?.toString() ?? '0') ?? 0.0;
      }
      final newBalance = currentBalance + request.amount;
      updates['advertiserAccounts/${request.userId}/balance'] = newBalance;
      updates['advertiserAccounts/${request.userId}/updatedAt'] = now;

      // Find matching payment method and increase its actual balance
      try {
        final methodsSnap = await paymentMethodsRef.get();
        if (methodsSnap.exists && methodsSnap.value is Map) {
          final mMap = Map<dynamic, dynamic>.from(methodsSnap.value as Map);
          for (final entry in mMap.entries) {
            final mVal = Map<dynamic, dynamic>.from(entry.value as Map);
            final mName = mVal['name']?.toString().trim().toLowerCase() ?? '';
            if (mName == request.method.trim().toLowerCase()) {
              final methodId = entry.key.toString();
              double currentMethodBalance = double.tryParse(mVal['balance']?.toString() ?? '0') ?? 0.0;
              updates['paymentMethods/$methodId/balance'] = currentMethodBalance + request.amount;
              break;
            }
          }
        }
      } catch (e) {
        debugPrint('تعذر تحديث رصيد وسيلة الدفع: $e');
      }
    }

    await _database.ref().update(updates);
  }

  Future<void> payFromWallet({
    required String userId,
    required double amount,
    required String entityType,
    required String entityId,
  }) async {
    final accSnap = await advertiserAccountsRef.child(userId).get();
    if (!accSnap.exists || accSnap.value is! Map) {
      throw Exception('حساب المعلن غير موجود');
    }
    final accMap = Map<dynamic, dynamic>.from(accSnap.value as Map);
    double currentBalance = double.tryParse(accMap['balance']?.toString() ?? '0') ?? 0.0;

    if (currentBalance < amount) {
      throw Exception('رصيد المحفظة غير كافٍ (${currentBalance.toStringAsFixed(0)} د.ع). يرجى شحن المحفظة أولاً.');
    }

    final newBalance = currentBalance - amount;
    final now = DateTime.now().toIso8601String();

    final paymentsSnap = await _database.ref('commercialPayments')
        .orderByChild('entityId')
        .equalTo(entityId)
        .get();

    String paymentKey = '';
    if (paymentsSnap.exists && paymentsSnap.value is Map) {
      final pMap = Map<dynamic, dynamic>.from(paymentsSnap.value as Map);
      for (final entry in pMap.entries) {
        final val = Map<dynamic, dynamic>.from(entry.value as Map);
        if (val['entityType']?.toString() == entityType) {
          paymentKey = entry.key.toString();
          break;
        }
      }
    }

    final updates = <String, Object?>{
      'advertiserAccounts/$userId/balance': newBalance,
      'advertiserAccounts/$userId/updatedAt': now,
    };

    if (paymentKey.isNotEmpty) {
      updates['commercialPayments/$paymentKey/status'] = 'paid';
      updates['commercialPayments/$paymentKey/method'] = 'رصيد المحفظة';
      updates['commercialPayments/$paymentKey/paidAt'] = now;
      updates['commercialPayments/$paymentKey/confirmedAt'] = now;
    }

    if (entityType == 'ad') {
      updates['commercialAds/$entityId/paymentStatus'] = 'paid';
      updates['commercialAds/$entityId/status'] = 'pending_approval';
      updates['commercialAds/$entityId/paidAt'] = now;
    } else {
      updates['commercialServices/$entityId/paymentStatus'] = 'paid';
      updates['commercialServices/$entityId/status'] = 'active';
      updates['commercialServices/$entityId/paidAt'] = now;
    }

    await _database.ref().update(updates);
  }
}
