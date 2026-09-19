import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/commercial_ad.dart';
import '../models/commercial_service_model.dart';
import 'advertiser_account_service.dart';
import 'commercial_conversation_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';

class CommercialService {
  CommercialService._();
  static final CommercialService instance = CommercialService._();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  DatabaseReference get adsRef => _database.ref('commercialAds');
  DatabaseReference get servicesRef => _database.ref('commercialServices');
  DatabaseReference get requestsRef => _database.ref('commercialRequests');
  DatabaseReference get paymentsRef => _database.ref('commercialPayments');
  DatabaseReference get contactsRef => _database.ref('contactMessages');
  DatabaseReference get ratingsRef => _database.ref('appRatings');

  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  Future<String> createAd({
    required Map<String, dynamic> data,
    required List<File> imageFiles,
  }) async {
    final account =
    await AdvertiserAccountService.instance.requireCurrentAccount();
    final id = adsRef.push().key!;
    final urls = <String>[];
    for (final file in imageFiles) {
      urls.add(await StorageService.instance.uploadImage(
        file: file,
        folder: 'commercial_ads/$id',
      ));
    }
    final now = DateTime.now().toIso8601String();
    final payload = <String, dynamic>{
      ...data,
      'id': id,
      'ownerUid': account.id,
      'ownerName': account.fullName,
      'ownerEmail': account.email,
      'ownerPhone': account.phone,
      'ownerWhatsapp': account.whatsapp,
      'imageUrls': urls,
      'status': 'pending',
      'paymentStatus': 'pending',
      'approvedPrice': 0,
      'views': 0,
      'clicks': 0,
      'calls': 0,
      'whatsappClicks': 0,
      'mapClicks': 0,
      'createdAt': now,
      'approvedAt': '',
      'publishedAt': '',
    };
    await adsRef.child(id).set(payload);
    await _createRequest(
      entityType: 'ad',
      entityId: id,
      title: data['title']?.toString() ?? 'إعلان جديد',
      durationDays: int.tryParse(data['durationDays']?.toString() ?? '') ?? 7,
      ownerUid: account.id,
      ownerName: account.fullName,
      ownerPhone: account.phone,
      ownerWhatsapp: account.whatsapp,
    );
    try {
      await CommercialConversationService.instance.ensureConversation(
        entityType: 'ad',
        entityId: id,
        ownerUid: account.id,
        title: data['title']?.toString() ?? 'إعلان جديد',
        ownerName: account.fullName,
        ownerPhone: account.phone,
        ownerWhatsapp: account.whatsapp,
      );
    } catch (error) {
      debugPrint('تعذر إنشاء محادثة الإعلان: $error');
    }
    return id;
  }

  Future<String> createService({
    required Map<String, dynamic> data,
    required List<File> imageFiles,
  }) async {
    final id = servicesRef.push().key!;
    final urls = <String>[];
    for (final file in imageFiles) {
      urls.add(await StorageService.instance.uploadImage(
        file: file,
        folder: 'commercial_services/$id',
      ));
    }
    final now = DateTime.now().toIso8601String();
    final payload = <String, dynamic>{
      ...data,
      'id': id,
      'ownerUid': currentUid,
      'imageUrls': urls,
      'status': 'pending',
      'paymentStatus': 'pending',
      'approvedPrice': 0,
      'views': 0,
      'clicks': 0,
      'calls': 0,
      'whatsappClicks': 0,
      'mapClicks': 0,
      'createdAt': now,
    };
    await servicesRef.child(id).set(payload);
    await _createRequest(
      entityType: 'service',
      entityId: id,
      title: data['name']?.toString() ?? 'خدمة جديدة',
      durationDays: int.tryParse(data['durationDays']?.toString() ?? '') ?? 30,
    );
    return id;
  }

  Future<void> _createRequest({
    required String entityType,
    required String entityId,
    required String title,
    int durationDays = 7,
    String? ownerUid,
    String ownerName = '',
    String ownerPhone = '',
    String ownerWhatsapp = '',
  }) async {
    final id = requestsRef.push().key!;
    await requestsRef.child(id).set({
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'ownerUid': ownerUid ?? currentUid,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'ownerWhatsapp': ownerWhatsapp,
      'title': title,
      'durationDays': durationDays,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
      'rejectionReason': '',
    });
  }

  Stream<List<CommercialAd>> myAds() {
    return adsRef
        .orderByChild('ownerUid')
        .equalTo(currentUid)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <CommercialAd>[];
      final raw = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      final list = raw.entries
          .map((e) => CommercialAd.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
          .where((e) => e.ownerUid == currentUid)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<CommercialServiceModel>> myServices() {
    return servicesRef
        .orderByChild('ownerUid')
        .equalTo(currentUid)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <CommercialServiceModel>[];
      final raw = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      final list = raw.entries
          .map((e) => CommercialServiceModel.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
          .where((e) => e.ownerUid == currentUid)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<CommercialAd>> activeAds({String? placement}) {
    final query = adsRef
        .orderByChild('status')
        .equalTo('published');

    // onValue يرسل البيانات الحالية عند كل اشتراك جديد، ثم يرسل
    // التغييرات مباشرة. الربط المباشر يمنع انقطاع الإعلانات بعد
    // التنقل بين شاشات المدير والرجوع إلى شاشة العرض.
    return query.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) {
        return <CommercialAd>[];
      }

      final raw = Map<dynamic, dynamic>.from(value);
      final now = DateTime.now();
      final list = raw.entries
          .where((entry) => entry.value is Map)
          .map(
            (entry) => CommercialAd.fromMap(
          entry.key.toString(),
          Map<dynamic, dynamic>.from(entry.value as Map),
        ),
      )
          .where((ad) {
        final start = DateTime.tryParse(ad.startAt);
        final end = DateTime.tryParse(ad.endAt);
        final dateOk = start == null ||
            end == null ||
            (!now.isBefore(start) && !now.isAfter(end));
        final placementOk = placement == null ||
            ad.placements.contains(placement);

        return ad.status == 'published' &&
            ad.paymentStatus == 'paid' &&
            dateOk &&
            placementOk;
      })
          .toList();

      list.sort((a, b) {
        if (a.featured != b.featured) {
          return a.featured ? -1 : 1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });

      return list;
    });
  }

  Stream<List<CommercialServiceModel>> activeServices() {
    return servicesRef
        .orderByChild('status')
        .equalTo('published')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <CommercialServiceModel>[];
      final raw = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      final now = DateTime.now();
      final list = raw.entries
          .map((e) => CommercialServiceModel.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map)))
          .where((item) {
        final start = DateTime.tryParse(item.startAt);
        final end = DateTime.tryParse(item.endAt);
        final dateOk = start == null || end == null || (!now.isBefore(start) && !now.isAfter(end));
        return item.status == 'published' && item.paymentStatus == 'paid' && dateOk;
      })
          .toList();
      return list;
    });
  }

  Future<List<CommercialAd>> getAllAds() async {
    final snap = await adsRef.get();
    if (!snap.exists || snap.value == null) return [];
    final raw = Map<dynamic, dynamic>.from(snap.value as Map);
    return raw.entries.map((e) => CommercialAd.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map))).toList();
  }

  Future<List<CommercialServiceModel>> getAllServices() async {
    final snap = await servicesRef.get();
    if (!snap.exists || snap.value == null) return [];
    final raw = Map<dynamic, dynamic>.from(snap.value as Map);
    return raw.entries.map((e) => CommercialServiceModel.fromMap(e.key.toString(), Map<dynamic, dynamic>.from(e.value as Map))).toList();
  }

  Future<List<Map<String, dynamic>>> getRequests() async {
    final snap = await requestsRef.get();
    if (!snap.exists || snap.value == null) return [];
    final raw = Map<dynamic, dynamic>.from(snap.value as Map);
    final list = raw.entries.map((e) {
      final map = Map<String, dynamic>.from(e.value as Map);
      map['id'] = e.key.toString();
      return map;
    }).toList();
    list.sort((a, b) => (b['createdAt'] ?? '').toString().compareTo((a['createdAt'] ?? '').toString()));
    return list;
  }

  String _paymentIdForEntity(String entityType, String entityId) =>
      'payment_${entityType}_$entityId';

  Future<void> approveRequest({
    required Map<String, dynamic> request,
    required double price,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    final entityType = request['entityType'].toString();
    final entityId = request['entityId'].toString();
    final ownerUid = request['ownerUid']?.toString() ?? '';
    final requestId = request['id']?.toString() ?? '';

    if (entityId.isEmpty || requestId.isEmpty || ownerUid.isEmpty) {
      throw Exception('بيانات الطلب التجاري غير مكتملة');
    }
    if (price <= 0) {
      throw Exception('السعر المعتمد يجب أن يكون أكبر من صفر');
    }

    // Check advertiser wallet balance and master card
    final accountSnap = await _database.ref('advertiserAccounts/$ownerUid').get();
    if (!accountSnap.exists || accountSnap.value is! Map) {
      throw Exception('حساب المعلن غير موجود أو غير مكتمل');
    }
    final accountMap = Map<dynamic, dynamic>.from(accountSnap.value as Map);
    double currentBalance = double.tryParse(accountMap['balance']?.toString() ?? '0') ?? 0.0;
    String masterCardNumber = accountMap['masterCardNumber']?.toString() ?? '';
    String ownerPhone = accountMap['phone']?.toString() ?? '';

    if (currentBalance < price) {
      final rejectReason = 'تم رفض الإعلان لعدم توفر مبلغ كافٍ في ماستر كارد / محفظة صاحب الإعلان (${currentBalance.toStringAsFixed(0)} د.ع من أصل ${price.toStringAsFixed(0)} د.ع). يرجى شحن المحفظة.';

      final rejectUpdates = <String, Object?>{
        '${entityType == 'ad' ? 'commercialAds' : 'commercialServices'}/$entityId/status': 'rejected',
        '${entityType == 'ad' ? 'commercialAds' : 'commercialServices'}/$entityId/rejectionReason': rejectReason,
        'commercialRequests/$requestId/status': 'rejected',
        'commercialRequests/$requestId/rejectionReason': rejectReason,
        'commercialRequests/$requestId/reviewedAt': DateTime.now().toIso8601String(),
      };
      await _database.ref().update(rejectUpdates);

      try {
        await NotificationService.instance.addNotification(
          userId: ownerUid,
          title: 'رفض نشر الإعلان',
          message: rejectReason,
          type: 'payment',
        );
      } catch (_) {}

      throw Exception(rejectReason);
    }

    final newBalance = currentBalance - price;

    // Increase admin master card balance
    try {
      final methodsSnap = await _database.ref('paymentMethods').get();
      if (methodsSnap.exists && methodsSnap.value is Map) {
        final mMap = Map<dynamic, dynamic>.from(methodsSnap.value as Map);
        final firstKey = mMap.keys.first.toString();
        final firstVal = Map<dynamic, dynamic>.from(mMap[firstKey] as Map);
        double curMethodBal = double.tryParse(firstVal['balance']?.toString() ?? '0') ?? 0.0;
        await _database.ref('paymentMethods/$firstKey/balance').set(curMethodBal + price);
      }
    } catch (e) {
      debugPrint('تعذر تحديث رصيد ماستر المشرف: $e');
    }

    final entityRef = entityType == 'ad'
        ? adsRef.child(entityId)
        : servicesRef.child(entityId);

    Map<String, dynamic> entity = <String, dynamic>{};
    final entitySnapshot = await entityRef.get();
    if (entitySnapshot.value is Map) {
      entity = Map<String, dynamic>.from(
        entitySnapshot.value as Map,
      );
    }

    int durationDays = int.tryParse(
      request['durationDays']?.toString() ?? '',
    ) ??
        0;
    if (durationDays <= 0) {
      durationDays = int.tryParse(
        entity['durationDays']?.toString() ?? '',
      ) ??
          0;
    }
    if (durationDays <= 0) {
      durationDays = endAt.difference(startAt).inDays;
    }
    if (durationDays <= 0) {
      durationDays = 1;
    }

    String ownerName = request['ownerName']?.toString().trim() ?? '';
    if (ownerName.isEmpty) {
      ownerName = entity['ownerName']?.toString().trim() ?? '';
    }

    String businessName = entity['businessName']?.toString().trim() ?? '';
    if (businessName.isEmpty) {
      businessName = entityType == 'ad'
          ? entity['title']?.toString().trim() ?? ''
          : entity['name']?.toString().trim() ?? '';
    }

    final double pricePerDay = price / durationDays;
    final now = DateTime.now().toIso8601String();
    final paymentId = _paymentIdForEntity(entityType, entityId);

    final updates = <String, Object?>{
      'advertiserAccounts/$ownerUid/balance': newBalance,
      'advertiserAccounts/$ownerUid/updatedAt': now,
      '${entityType == 'ad' ? 'commercialAds' : 'commercialServices'}/$entityId/approvedPrice': price,
      '${entityType == 'ad' ? 'commercialAds' : 'commercialServices'}/$entityId/startAt': startAt.toIso8601String(),
      '${entityType == 'ad' ? 'commercialAds' : 'commercialServices'}/$entityId/endAt': endAt.toIso8601String(),
      '${entityType == 'ad' ? 'commercialAds' : 'commercialServices'}/$entityId/status': 'published',
      '${entityType == 'ad' ? 'commercialAds' : 'commercialServices'}/$entityId/paymentStatus': 'paid',
      '${entityType == 'ad' ? 'commercialAds' : 'commercialServices'}/$entityId/approvedAt': now,
      '${entityType == 'ad' ? 'commercialAds' : 'commercialServices'}/$entityId/publishedAt': now,
      '${entityType == 'ad' ? 'commercialAds' : 'commercialServices'}/$entityId/paidAt': now,
      'commercialRequests/$requestId/status': 'approved',
      'commercialRequests/$requestId/approvedPrice': price,
      'commercialRequests/$requestId/reviewedAt': now,
      'commercialPayments/$paymentId/id': paymentId,
      'commercialPayments/$paymentId/ownerUid': ownerUid,
      'commercialPayments/$paymentId/entityType': entityType,
      'commercialPayments/$paymentId/entityId': entityId,
      'commercialPayments/$paymentId/amount': price,
      'commercialPayments/$paymentId/method': 'رصيد المحفظة / الماستر (${masterCardNumber.isNotEmpty ? masterCardNumber : ownerPhone})',
      'commercialPayments/$paymentId/status': 'paid',
      'commercialPayments/$paymentId/createdAt': now,
      'commercialPayments/$paymentId/paidAt': now,
      'commercialPayments/$paymentId/confirmedAt': now,
      'commercialPayments/$paymentId/durationDays': durationDays,
      'commercialPayments/$paymentId/pricePerDay': pricePerDay,
      'commercialPayments/$paymentId/entityTitle': businessName,
      'commercialPayments/$paymentId/ownerName': ownerName,
    };

    await _database.ref().update(updates);

    try {
      final receiptMsg = 'إيصال قبض - تم بنجاح استقطاع مبلغ ${price.toStringAsFixed(0)} د.ع مقابل نشر ${entityType == 'ad' ? 'الإعلان' : 'الخدمة'} "$businessName" لمدة $durationDays أيام من حسابكم / رقم الماستر (${masterCardNumber.isNotEmpty ? masterCardNumber : ownerPhone}). الرصيد المتبقي: ${newBalance.toStringAsFixed(0)} د.ع. رقم المرجع: $paymentId';
      await NotificationService.instance.addNotification(
        userId: ownerUid,
        title: 'إيصال دفع ونشر تجاري',
        message: receiptMsg,
        type: 'payment',
      );
    } catch (e) {
      debugPrint('تعذر إرسال إشعار الإيصال: $e');
    }

    await _sendConversationUpdate(
      entityType: entityType,
      entityId: entityId,
      ownerUid: ownerUid,
      request: request,
      message:
      'تمت الموافقة على الطلب واستقطاع المبلغ ${price.toStringAsFixed(0)} د.ع من المحفظة/الماستر ونشر الإعلان بنجاح. الرصيد المتبقي: ${newBalance.toStringAsFixed(0)} د.ع.',
      isAdmin: true,
    );
  }

  Future<void> rejectRequest({required Map<String, dynamic> request, required String reason}) async {
    final entityType = request['entityType'].toString();
    final entityId = request['entityId'].toString();
    final path = entityType == 'ad' ? adsRef.child(entityId) : servicesRef.child(entityId);
    await path.update({'status': 'rejected', 'rejectionReason': reason});
    await requestsRef.child(request['id'].toString()).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'reviewedAt': DateTime.now().toIso8601String(),
    });
    await _sendConversationUpdate(
      entityType: entityType,
      entityId: entityId,
      ownerUid: request['ownerUid']?.toString() ?? '',
      request: request,
      message: 'تم رفض الطلب. السبب: $reason',
      isAdmin: true,
    );
  }

  Future<void> submitPayment({
    required String entityType,
    required String entityId,
    required double amount,
    required String method,
    String note = '',
  }) async {
    final uid = currentUid;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      throw Exception('يجب تسجيل الدخول لإتمام الدفع');
    }

    final id = _paymentIdForEntity(entityType, entityId);
    final ref = paymentsRef.child(id);
    final snapshot = await ref.get();
    final now = DateTime.now().toIso8601String();

    if (snapshot.exists && snapshot.value != null) {
      final existing = Map<dynamic, dynamic>.from(snapshot.value as Map);
      if (existing['ownerUid']?.toString() != uid) {
        throw Exception('عملية الدفع لا تخص هذا المستخدم');
      }

      final approvedAmount =
          double.tryParse(existing['amount']?.toString() ?? '') ?? 0;
      if (approvedAmount <= 0) {
        throw Exception('المبلغ المعتمد غير صالح');
      }

      final status = existing['status']?.toString() ?? '';
      if (status == 'paid') {
        throw Exception('تم دفع هذه العملية مسبقاً');
      }
      if (status == 'submitted') {
        throw Exception('تم إرسال هذه العملية مسبقاً وهي بانتظار تأكيد الإدارة');
      }
      if (status != 'awaiting_payment') {
        throw Exception('حالة عملية الدفع غير صالحة للإرسال');
      }

      await ref.update({
        'method': method,
        'note': note,
        'status': 'submitted',
        'submittedAt': now,
      });
    } else {
      await ref.set({
        'id': id,
        'ownerUid': uid,
        'entityType': entityType,
        'entityId': entityId,
        'amount': amount,
        'method': method,
        'note': note,
        'status': 'submitted',
        'createdAt': now,
        'submittedAt': now,
        'confirmedAt': '',
      });
    }

    final path =
    entityType == 'ad' ? adsRef.child(entityId) : servicesRef.child(entityId);
    await path.update({'paymentStatus': 'submitted'});

    if (entityType == 'ad') {
      final entitySnapshot = await adsRef.child(entityId).get();
      if (entitySnapshot.value is Map) {
        final entity = Map<String, dynamic>.from(
          entitySnapshot.value as Map,
        );
        try {
          await CommercialConversationService.instance.sendMessage(
            entityType: entityType,
            entityId: entityId,
            ownerUid: uid,
            title: entity['title']?.toString() ?? 'إعلان',
            ownerName: entity['ownerName']?.toString() ?? '',
            ownerPhone: entity['ownerPhone']?.toString() ?? '',
            ownerWhatsapp: entity['ownerWhatsapp']?.toString() ?? '',
            text:
            'تم إرسال بيانات الدفع للإدارة. طريقة الدفع: $method${note.trim().isEmpty ? '' : '، الملاحظة: ${note.trim()}'}',
            isAdmin: false,
          );
        } catch (error) {
          debugPrint('تعذر إرسال إشعار الدفع في المحادثة: $error');
        }
      }
    }
  }

  Future<void> confirmPaymentAndPublish({
    required String entityType,
    required String entityId,
  }) async {
    final path = entityType == 'ad' ? adsRef.child(entityId) : servicesRef.child(entityId);
    await path.update({
      'paymentStatus': 'paid',
      'status': 'published',
      'publishedAt': DateTime.now().toIso8601String(),
    });

    if (entityType == 'ad') {
      final entitySnapshot = await adsRef.child(entityId).get();
      if (entitySnapshot.value is Map) {
        final entity = Map<String, dynamic>.from(
          entitySnapshot.value as Map,
        );
        try {
          await CommercialConversationService.instance.sendMessage(
            entityType: entityType,
            entityId: entityId,
            ownerUid: entity['ownerUid']?.toString() ?? '',
            title: entity['title']?.toString() ?? 'إعلان',
            ownerName: entity['ownerName']?.toString() ?? '',
            ownerPhone: entity['ownerPhone']?.toString() ?? '',
            ownerWhatsapp: entity['ownerWhatsapp']?.toString() ?? '',
            text: 'تم تأكيد الدفع ونشر الإعلان بنجاح.',
            isAdmin: true,
          );
        } catch (error) {
          debugPrint('تعذر إرسال تأكيد النشر في المحادثة: $error');
        }
      }
    }
  }

  Future<void> _sendConversationUpdate({
    required String entityType,
    required String entityId,
    required String ownerUid,
    required Map<String, dynamic> request,
    required String message,
    required bool isAdmin,
  }) async {
    if (entityType != 'ad' || ownerUid.isEmpty) return;

    try {
      await CommercialConversationService.instance.sendMessage(
        entityType: entityType,
        entityId: entityId,
        ownerUid: ownerUid,
        title: request['title']?.toString() ?? 'إعلان',
        ownerName: request['ownerName']?.toString() ?? '',
        ownerPhone: request['ownerPhone']?.toString() ?? '',
        ownerWhatsapp: request['ownerWhatsapp']?.toString() ?? '',
        text: message,
        isAdmin: isAdmin,
      );
    } catch (error) {
      debugPrint('تعذر إرسال تحديث الطلب في المحادثة: $error');
    }
  }

  Future<void> stopPublication({required String entityType, required String entityId}) async {
    final path = entityType == 'ad' ? adsRef.child(entityId) : servicesRef.child(entityId);
    await path.update({'status': 'stopped'});
  }

  Future<void> incrementAdMetric(String id, String metric) async {
    final ref = adsRef.child(id).child(metric);
    await ref.runTransaction((value) {
      final current = int.tryParse(value?.toString() ?? '') ?? 0;
      return Transaction.success(current + 1);
    });
  }

  Future<void> incrementServiceMetric(String id, String metric) async {
    final ref = servicesRef.child(id).child(metric);
    await ref.runTransaction((value) {
      final current = int.tryParse(value?.toString() ?? '') ?? 0;
      return Transaction.success(current + 1);
    });
  }

  Future<void> submitContact({
    required String subject,
    required String message,
    String phone = '',
  }) async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'يجب تسجيل الدخول أولاً لإرسال رسالة التواصل',
      );
    }

    final String id =
    contactsRef.push().key!;

    await contactsRef.child(id).set({
      'id': id,
      'userId': user.uid,
      'subject': subject,
      'message': message,
      'phone': phone,
      'status': 'new',
      'createdAt':
      DateTime.now().toIso8601String(),
    });
  }

  Future<void> submitRating({required int rating, String comment = ''}) async {
    final id = ratingsRef.push().key!;
    await ratingsRef.child(id).set({
      'id': id,
      'userId': currentUid,
      'rating': rating,
      'comment': comment,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
  Future<void> sendCommercialNotification({
    required String title,
    required String message,
    required String entityType,
    required String entityId,
  }) async {
    final ref = _database.ref('notifications/public').push();
    await ref.set({
      'id': ref.key,
      'title': title,
      'message': message,
      'type': 'commercial',
      'entityType': entityType,
      'entityId': entityId,
      'read': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> requestExtension({
    required String entityType,
    required String entityId,
    required String requestedEndAt,
  }) async {
    final path = entityType == 'ad' ? adsRef.child(entityId) : servicesRef.child(entityId);
    Map<String, dynamic> entity = const {};
    final entitySnapshot = await path.get();
    if (entitySnapshot.value is Map) {
      entity = Map<String, dynamic>.from(entitySnapshot.value as Map);
    }
    await path.update({
      'requestedEndAt': requestedEndAt,
      'status': 'extension_pending',
    });
    final id = requestsRef.push().key!;
    await requestsRef.child(id).set({
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'ownerUid': currentUid,
      'ownerName': entity['ownerName']?.toString() ?? '',
      'ownerPhone': entity['ownerPhone']?.toString() ?? '',
      'ownerWhatsapp': entity['ownerWhatsapp']?.toString() ?? '',
      'title': entity['title']?.toString() ?? 'طلب تمديد',
      'status': 'extension_pending',
      'requestedEndAt': requestedEndAt,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

}
