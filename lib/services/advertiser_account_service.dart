import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/advertiser_account.dart';

class AdvertiserAccountService {
  AdvertiserAccountService._();

  static final AdvertiserAccountService instance =
  AdvertiserAccountService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  DatabaseReference get accountsRef =>
      _database.ref('advertiserAccounts');

  User? get firebaseUser => _auth.currentUser;

  bool get hasAuthenticatedUser {
    final user = firebaseUser;
    return user != null && !user.isAnonymous;
  }

  Future<AdvertiserAccount?> getCurrentAccount() async {
    final user = firebaseUser;
    if (user == null || user.isAnonymous) return null;

    final snapshot = await accountsRef.child(user.uid).get();
    if (!snapshot.exists || snapshot.value is! Map) return null;

    return AdvertiserAccount.fromMap(
      user.uid,
      Map<dynamic, dynamic>.from(snapshot.value as Map),
    );
  }

  Stream<AdvertiserAccount?> currentAccountStream() {
    final user = firebaseUser;
    if (user == null || user.isAnonymous) {
      return Stream<AdvertiserAccount?>.value(null);
    }

    return accountsRef.child(user.uid).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return null;
      return AdvertiserAccount.fromMap(
        user.uid,
        Map<dynamic, dynamic>.from(value),
      );
    });
  }

  Stream<List<AdvertiserAccount>> allAccountsStream() {
    return accountsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <AdvertiserAccount>[];

      final raw = Map<dynamic, dynamic>.from(value);
      final accounts = raw.entries
          .where((entry) => entry.value is Map)
          .map(
            (entry) => AdvertiserAccount.fromMap(
          entry.key.toString(),
          Map<dynamic, dynamic>.from(entry.value as Map),
        ),
      )
          .toList();

      accounts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return accounts;
    });
  }

  Future<AdvertiserAccount> register({
    required String fullName,
    required String businessName,
    required String email,
    required String phone,
    required String whatsapp,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final currentUser = _auth.currentUser;
    User? user;

    if (currentUser != null && currentUser.isAnonymous) {
      final authCredential = EmailAuthProvider.credential(
        email: normalizedEmail,
        password: password,
      );
      final credential = await currentUser.linkWithCredential(authCredential);
      user = credential.user;
    } else if (currentUser != null &&
        currentUser.email?.toLowerCase() == normalizedEmail) {
      // يسمح بإكمال الملف إذا نجح Authentication وتعذر حفظ البيانات سابقاً.
      user = currentUser;
    } else {
      if (currentUser != null) {
        await _auth.signOut();
      }
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      user = credential.user;
    }

    if (user == null) {
      throw Exception('تعذر إنشاء حساب المعلن');
    }

    await user.getIdToken(true);

    final now = DateTime.now().toIso8601String();
    final account = AdvertiserAccount(
      id: user.uid,
      fullName: fullName.trim(),
      businessName: businessName.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      whatsapp: whatsapp.trim(),
      status: 'active',
      balance: 0.0,
      masterCardNumber: '',
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
    );

    await accountsRef.child(user.uid).set(account.toMap());
    await user.updateDisplayName(fullName.trim());
    return account;
  }

  Future<AdvertiserAccount> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw Exception('تعذر تسجيل الدخول');
    }

    final snapshot = await accountsRef.child(user.uid).get();
    if (!snapshot.exists || snapshot.value is! Map) {
      throw Exception(
        'بيانات حساب المعلن غير مكتملة. اختر إنشاء حساب وأكمل البيانات بنفس البريد.',
      );
    }

    final account = AdvertiserAccount.fromMap(
      user.uid,
      Map<dynamic, dynamic>.from(snapshot.value as Map),
    );
    final now = DateTime.now().toIso8601String();
    await accountsRef.child(user.uid).update({
      'lastLoginAt': now,
      'updatedAt': now,
    });
    return account;
  }

  Future<void> updateProfile({
    required String fullName,
    required String businessName,
    required String phone,
    required String whatsapp,
    required String masterCardNumber,
  }) async {
    final user = firebaseUser;
    if (user == null || user.isAnonymous) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    await accountsRef.child(user.uid).update({
      'fullName': fullName.trim(),
      'businessName': businessName.trim(),
      'phone': phone.trim(),
      'whatsapp': whatsapp.trim(),
      'masterCardNumber': masterCardNumber.trim(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await user.updateDisplayName(fullName.trim());
  }

  Future<void> setAccountStatus(String uid, String status) async {
    if (status != 'active' && status != 'suspended') {
      throw ArgumentError('حالة الحساب غير صحيحة');
    }

    await accountsRef.child(uid).update({
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteAccountProfile(String uid) async {
    final accountUid = uid.trim();
    if (accountUid.isEmpty) {
      throw ArgumentError('معرّف حساب المعلن غير موجود');
    }

    final snapshots = await Future.wait<DataSnapshot>([
      _database
          .ref('commercialConversations')
          .orderByChild('ownerUid')
          .equalTo(accountUid)
          .get(),
      _database
          .ref('commercialAds')
          .orderByChild('ownerUid')
          .equalTo(accountUid)
          .get(),
      _database.ref('commercialRequests').get(),
    ]);

    final conversationsSnapshot = snapshots[0];
    final adsSnapshot = snapshots[1];
    final requestsSnapshot = snapshots[2];
    final now = DateTime.now().toIso8601String();

    final updates = <String, Object?>{
      'advertiserAccounts/$accountUid': null,
    };

    final conversationsValue = conversationsSnapshot.value;
    if (conversationsValue is Map) {
      for (final conversationId in conversationsValue.keys) {
        updates['commercialConversations/$conversationId'] = null;
      }
    }

    final adsValue = adsSnapshot.value;
    if (adsValue is Map) {
      for (final adId in adsValue.keys) {
        updates['commercialAds/$adId/status'] = 'stopped';
        updates['commercialAds/$adId/stoppedAt'] = now;
        updates['commercialAds/$adId/stopReason'] =
        'advertiser_account_deleted';
      }
    }

    final requestsValue = requestsSnapshot.value;
    if (requestsValue is Map) {
      for (final entry in requestsValue.entries) {
        if (entry.value is! Map) continue;
        final request = Map<dynamic, dynamic>.from(entry.value as Map);
        final belongsToAccount =
            request['ownerUid']?.toString() == accountUid;
        final status = request['status']?.toString() ?? '';
        final isPending = status == 'pending' || status == 'extension_pending';
        if (!belongsToAccount || !isPending) continue;

        updates['commercialRequests/${entry.key}/status'] =
        'cancelled_account_deleted';
        updates['commercialRequests/${entry.key}/cancelledAt'] = now;
      }
    }

    await _database.ref().update(updates);
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _auth.signInAnonymously();
  }

  Future<AdvertiserAccount> requireCurrentAccount() async {
    final account = await getCurrentAccount();
    if (account == null) {
      throw Exception('يجب إنشاء حساب معلن أو تسجيل الدخول أولاً');
    }
    if (!account.isActive) {
      throw Exception('حساب المعلن موقوف. تواصل مع مدير النظام');
    }
    return account;
  }

  String authErrorMessage(Object error) {
    if (error is! FirebaseAuthException) return error.toString();

    return switch (error.code) {
      'email-already-in-use' => 'البريد الإلكتروني مستخدم مسبقاً',
      'credential-already-in-use' => 'هذا البريد مرتبط بحساب موجود مسبقاً',
      'invalid-email' => 'البريد الإلكتروني غير صحيح',
      'weak-password' => 'كلمة المرور ضعيفة؛ استخدم 6 أحرف على الأقل',
      'user-not-found' => 'لا يوجد حساب بهذا البريد الإلكتروني',
      'wrong-password' || 'invalid-credential' =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      'too-many-requests' => 'محاولات كثيرة؛ حاول مرة أخرى لاحقاً',
      'network-request-failed' => 'تعذر الاتصال بالإنترنت',
      _ => error.message ?? 'تعذر إكمال العملية',
    };
  }
}
