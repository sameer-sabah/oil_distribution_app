import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../core/constants/user_roles.dart';

class InternalMessageService {
  InternalMessageService._();

  static final InternalMessageService instance =
  InternalMessageService._();

  final FirebaseDatabase database =
      FirebaseDatabase.instance;

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  DatabaseReference get messagesRef =>
      database.ref('internalMessages');

  DatabaseReference get usersRef =>
      database.ref('users');

  Map<String, dynamic>? _cachedCurrentUser;
  String? _cachedCurrentUserUid;

  // =====================================================
  // المستخدم الحالي
  // =====================================================

  Future<Map<String, dynamic>?> getCurrentUser({
    bool forceRefresh = false,
  }) async {
    final User? firebaseUser =
        auth.currentUser;

    if (firebaseUser == null) {
      _cachedCurrentUser = null;
      _cachedCurrentUserUid = null;
      return null;
    }

    if (!forceRefresh &&
        _cachedCurrentUser != null &&
        _cachedCurrentUserUid ==
            firebaseUser.uid) {
      return _cachedCurrentUser;
    }

    final DataSnapshot snapshot =
    await usersRef
        .child(firebaseUser.uid)
        .get();

    if (!snapshot.exists ||
        snapshot.value == null ||
        snapshot.value is! Map) {
      return null;
    }

    final Map<dynamic, dynamic> raw =
    Map<dynamic, dynamic>.from(
      snapshot.value as Map,
    );

    final user = raw.map(
          (key, value) => MapEntry(
        key.toString(),
        value,
      ),
    );

    _cachedCurrentUser =
        user;

    _cachedCurrentUserUid =
        firebaseUser.uid;

    return user;
  }

  // =====================================================
  // جلب الأشخاص المسموح بمراسلتهم
  // =====================================================

  Future<List<Map<String, dynamic>>>
  getAvailableRecipients() async {

    final currentUser =
    await getCurrentUser();

    if (currentUser == null) {
      return [];
    }

    final String role =
        currentUser['role']
            ?.toString()
            .trim() ??
            '';

    final String branchId =
        currentUser['branchId']
            ?.toString()
            .trim() ??
            '';

    final String currentUid =
        auth.currentUser?.uid ?? '';

    final List<Map<String, dynamic>> result =
    [];

    // ===================================================
    // مدير النظام
    //
    // يستطيع مراسلة مدراء الفروع
    // ===================================================

    if (role == 'admin') {
      final DataSnapshot snapshot =
      await usersRef
          .orderByChild('role')
          .equalTo('branchManager')
          .get();

      if (snapshot.exists &&
          snapshot.value != null &&
          snapshot.value is Map) {

        final Map<dynamic, dynamic> raw =
        Map<dynamic, dynamic>.from(
          snapshot.value as Map,
        );

        for (final entry in raw.entries) {

          if (entry.value is! Map) {
            continue;
          }

          final Map<dynamic, dynamic> user =
          Map<dynamic, dynamic>.from(
            entry.value as Map,
          );

          final String uid =
          entry.key.toString();

          if (uid == currentUid) {
            continue;
          }

          result.add({
            'uid': uid,
            'fullName':
            user['fullName']?.toString() ??
                user['name']?.toString() ??
                user['username']?.toString() ??
                'مدير الفرع',
            'role':
            user['role']?.toString() ??
                'branchManager',
            'branchId':
            user['branchId']?.toString() ??
                '',
            'branchName':
            user['branchName']?.toString() ??
                '',
            'stationId':
            user['stationId']?.toString() ??
                '',
            'stationName':
            user['stationName']?.toString() ??
                '',
          });
        }
      }

      result.sort((a, b) {
        final String aName =
            a['fullName']?.toString() ?? '';

        final String bName =
            b['fullName']?.toString() ?? '';

        return aName.compareTo(bName);
      });

      return result;
    }

    // ===================================================
    // مدير الفرع
    //
    // يستطيع مراسلة:
    //
    // 1- مدير النظام
    // 2- مدراء محطات نفس الفرع
    // ===================================================

    if (role == 'branchManager') {

      // =================================================
      // جلب مدير النظام مباشرة باستخدام معرّف المستخدم الحقيقي
      //
      // لا نستخدم:
      // orderByChild('role').equalTo('admin')
      //
      // لأن Rules مدير الفرع لا تسمح بهذا الاستعلام.
      // =================================================

      const String systemAdminUid =
          'TzeL8wJ37kVsYFqiQel9rHxsOS33';

      final DataSnapshot adminSnapshot =
      await usersRef
          .child(systemAdminUid)
          .get();

      if (adminSnapshot.exists &&
          adminSnapshot.value != null &&
          adminSnapshot.value is Map) {

        final Map<dynamic, dynamic> adminUser =
        Map<dynamic, dynamic>.from(
          adminSnapshot.value as Map,
        );

        final String adminRole =
            adminUser['role']
                ?.toString()
                .trim() ??
                '';

        if (systemAdminUid != currentUid &&
            adminRole == 'admin') {

          result.add({
            'uid': systemAdminUid,
            'fullName':
            adminUser['fullName']
                ?.toString() ??
                adminUser['name']
                    ?.toString() ??
                adminUser['username']
                    ?.toString() ??
                'مدير النظام',
            'role': 'admin',
            'branchId':
            adminUser['branchId']
                ?.toString() ??
                '',
            'branchName':
            adminUser['branchName']
                ?.toString() ??
                '',
            'stationId':
            adminUser['stationId']
                ?.toString() ??
                '',
            'stationName':
            adminUser['stationName']
                ?.toString() ??
                '',
          });
        }
      }

      // =================================================
      // جلب مستخدمي نفس الفرع
      //
      // ثم نأخذ stationManager فقط
      // =================================================

      if (branchId.isNotEmpty) {

        final DataSnapshot branchSnapshot =
        await usersRef
            .orderByChild('branchId')
            .equalTo(branchId)
            .get();

        if (branchSnapshot.exists &&
            branchSnapshot.value != null &&
            branchSnapshot.value is Map) {

          final Map<dynamic, dynamic> raw =
          Map<dynamic, dynamic>.from(
            branchSnapshot.value as Map,
          );

          for (final entry in raw.entries) {

            if (entry.value is! Map) {
              continue;
            }

            final Map<dynamic, dynamic> user =
            Map<dynamic, dynamic>.from(
              entry.value as Map,
            );

            final String uid =
            entry.key.toString();

            final String userRole =
                user['role']
                    ?.toString()
                    .trim() ??
                    '';

            final String userBranchId =
                user['branchId']
                    ?.toString()
                    .trim() ??
                    '';

            if (uid == currentUid) {
              continue;
            }

            if (UserRoles.isStationManager(userRole) &&
                userBranchId == branchId) {

              result.add({
                'uid': uid,
                'fullName':
                user['fullName']
                    ?.toString() ??
                    user['name']
                        ?.toString() ??
                    user['username']
                        ?.toString() ??
                    'مدير محطة',
                'role':
                'stationManager',
                'branchId':
                userBranchId,
                'branchName':
                user['branchName']
                    ?.toString() ??
                    '',
                'stationId':
                user['stationId']
                    ?.toString() ??
                    '',
                'stationName':
                user['stationName']
                    ?.toString() ??
                    '',
              });
            }
          }
        }
      }

      // =================================================
      // ترتيب النتائج
      //
      // مدير النظام أولاً
      // ثم مدراء المحطات
      // =================================================

      result.sort((a, b) {

        final String roleA =
            a['role']?.toString() ?? '';

        final String roleB =
            b['role']?.toString() ?? '';

        if (roleA == 'admin' &&
            roleB != 'admin') {
          return -1;
        }

        if (roleA != 'admin' &&
            roleB == 'admin') {
          return 1;
        }

        final String stationNameA =
            a['stationName']?.toString().trim() ?? '';

        final String stationNameB =
            b['stationName']?.toString().trim() ?? '';

        final String nameA = stationNameA.isNotEmpty
            ? stationNameA
            : a['fullName']?.toString() ?? '';

        final String nameB = stationNameB.isNotEmpty
            ? stationNameB
            : b['fullName']?.toString() ?? '';

        return nameA.compareTo(nameB);
      });

      return result;
    }

    // ===================================================
    // مدير المحطة
    //
    // يستطيع مراسلة مدير الفرع الخاص به
    // ===================================================

    if (UserRoles.isStationManager(role)) {

      if (branchId.isEmpty) {
        return [];
      }

      final DataSnapshot snapshot =
      await usersRef
          .orderByChild('branchId')
          .equalTo(branchId)
          .get();

      if (!snapshot.exists ||
          snapshot.value == null ||
          snapshot.value is! Map) {
        return [];
      }

      final Map<dynamic, dynamic> raw =
      Map<dynamic, dynamic>.from(
        snapshot.value as Map,
      );

      for (final entry in raw.entries) {

        if (entry.value is! Map) {
          continue;
        }

        final Map<dynamic, dynamic> user =
        Map<dynamic, dynamic>.from(
          entry.value as Map,
        );

        final String uid =
        entry.key.toString();

        final String userRole =
            user['role']
                ?.toString()
                .trim() ??
                '';

        final String userBranchId =
            user['branchId']
                ?.toString()
                .trim() ??
                '';

        if (uid == currentUid) {
          continue;
        }

        if (userRole == 'branchManager' &&
            userBranchId == branchId) {

          result.add({
            'uid': uid,
            'fullName':
            user['fullName']
                ?.toString() ??
                user['name']
                    ?.toString() ??
                user['username']
                    ?.toString() ??
                'مدير الفرع',
            'role':
            'branchManager',
            'branchId':
            userBranchId,
            'branchName':
            user['branchName']
                ?.toString() ??
                '',
            'stationId':
            user['stationId']
                ?.toString() ??
                '',
            'stationName':
            user['stationName']
                ?.toString() ??
                '',
          });
        }
      }

      result.sort((a, b) {

        final String aName =
            a['fullName']?.toString() ?? '';

        final String bName =
            b['fullName']?.toString() ?? '';

        return aName.compareTo(bName);
      });

      return result;
    }

    return [];
  }

  // =====================================================
  // إرسال رسالة
  // =====================================================

  Future<void> sendMessage({
    required Map<String, dynamic> recipient,
    required String subject,
    required String message,
  }) async {

    final User? firebaseUser =
        auth.currentUser;

    if (firebaseUser == null) {
      throw Exception(
        'يجب تسجيل الدخول أولاً',
      );
    }

    final currentUser =
    await getCurrentUser();

    if (currentUser == null) {
      throw Exception(
        'تعذر قراءة بيانات المستخدم الحالي',
      );
    }

    final String senderRole =
        currentUser['role']?.toString() ?? '';

    final String receiverUid =
        recipient['uid']?.toString() ?? '';

    if (receiverUid.isEmpty) {
      throw Exception(
        'المستلم غير موجود',
      );
    }

    final String cleanSubject =
    subject.trim();

    final String cleanMessage =
    message.trim();

    if (cleanMessage.isEmpty) {
      throw Exception(
        'اكتب نص الرسالة أولاً',
      );
    }

    if (cleanMessage.length > 5000) {
      throw Exception(
        'الرسالة يجب ألا تتجاوز 5000 حرف',
      );
    }

    // =================================================
    // التحقق من الصلاحية مرة ثانية
    // قبل الكتابة
    // =================================================

    final bool allowed =
    await _canCommunicate(
      sender: currentUser,
      recipient: recipient,
    );

    if (!allowed) {
      throw Exception(
        'لا توجد صلاحية لإرسال رسالة إلى هذا المستخدم',
      );
    }

    final DatabaseReference ref =
    messagesRef.push();

    final String id =
        ref.key ?? '';

    if (id.isEmpty) {
      throw Exception(
        'تعذر إنشاء معرف الرسالة',
      );
    }

    await ref.set({

      'id':
      id,

      'senderUid':
      firebaseUser.uid,

      'senderName':
      currentUser['fullName']
          ?.toString() ??
          '',

      'senderRole':
      senderRole,

      'receiverUid':
      receiverUid,

      'receiverName':
      recipient['fullName']
          ?.toString() ??
          '',

      'receiverRole':
      recipient['role']
          ?.toString() ??
          '',

      'branchId':
      currentUser['branchId']
          ?.toString() ??
          '',

      'stationId':
      currentUser['stationId']
          ?.toString() ??
          '',

      'subject':
      cleanSubject,

      'message':
      cleanMessage,

      'read':
      false,

      'createdAt':
      DateTime.now()
          .toIso8601String(),
    });
  }

  // =====================================================
  // التحقق من صلاحية المراسلة
  // =====================================================

  Future<bool> _canCommunicate({
    required Map<String, dynamic> sender,
    required Map<String, dynamic> recipient,
  }) async {

    final String senderRole =
        sender['role']?.toString() ?? '';

    final String recipientRole =
        recipient['role']?.toString() ?? '';

    final String senderBranchId =
        sender['branchId']?.toString() ?? '';

    final String recipientBranchId =
        recipient['branchId']?.toString() ?? '';

    // =================================================
    // مدير النظام ↔ مدير الفرع
    // =================================================

    if (senderRole == 'admin' &&
        recipientRole == 'branchManager') {
      return true;
    }

    if (senderRole == 'branchManager' &&
        recipientRole == 'admin') {
      return true;
    }

    // =================================================
    // مدير الفرع ↔ مدير المحطة
    // داخل نفس الفرع
    // =================================================

    if (UserRoles.isBranchManager(senderRole) &&
        UserRoles.isStationManager(recipientRole)) {

      return senderBranchId ==
          recipientBranchId;
    }

    if (UserRoles.isStationManager(senderRole) &&
        UserRoles.isBranchManager(recipientRole)) {

      return senderBranchId ==
          recipientBranchId;
    }

    return false;
  }

  // =====================================================
  // رسائل المستخدم الحالي
  // =====================================================

  Stream<DatabaseEvent> _firebaseEvents(Query query) {
    return Stream<DatabaseEvent>.multi((controller) {
      final subscription = query.onValue.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );

      controller.onCancel = subscription.cancel;
    }, isBroadcast: true);
  }

  Stream<DatabaseEvent> messagesStream() {

    final User? user =
        auth.currentUser;

    if (user == null) {
      return const Stream<
          DatabaseEvent>.empty();
    }

    final Query query = messagesRef
        .orderByChild('receiverUid')
        .equalTo(user.uid);

    return _firebaseEvents(query);
  }

  // =====================================================
  // الرسائل الصادرة من المستخدم الحالي
  // =====================================================

  Stream<DatabaseEvent> sentMessagesStream() {

    final User? user =
        auth.currentUser;

    if (user == null) {
      return const Stream<
          DatabaseEvent>.empty();
    }

    final Query query = messagesRef
        .orderByChild('senderUid')
        .equalTo(user.uid);

    return _firebaseEvents(query);
  }

  // =====================================================
  // عدد الرسائل الجديدة
  // =====================================================

  Stream<int> unreadCountStream() {

    final User? user =
        auth.currentUser;

    if (user == null) {
      return Stream<int>.value(0);
    }

    final Query query = messagesRef
        .orderByChild('receiverUid')
        .equalTo(user.uid);

    return _firebaseEvents(query)
        .map((event) {

      final Object? value =
          event.snapshot.value;

      if (value == null ||
          value is! Map) {
        return 0;
      }

      final Map<dynamic, dynamic> data =
      Map<dynamic, dynamic>.from(
        value,
      );

      int count = 0;

      for (final entry in data.entries) {

        if (entry.value is! Map) {
          continue;
        }

        final Map<dynamic, dynamic> item =
        Map<dynamic, dynamic>.from(
          entry.value as Map,
        );

        final bool read =
            item['read'] == true;

        if (!read) {
          count++;
        }
      }

      return count;
    });
  }

  // =====================================================
  // وضع الرسالة كمقروءة
  // =====================================================

  Future<void> markAsRead(
      String messageId) async {

    if (messageId.trim().isEmpty) {
      return;
    }

    final User? user =
        auth.currentUser;

    if (user == null) {
      return;
    }

    final DatabaseReference ref =
    messagesRef.child(messageId);

    final DataSnapshot snapshot =
    await ref.get();

    if (!snapshot.exists ||
        snapshot.value == null ||
        snapshot.value is! Map) {
      return;
    }

    final Map<dynamic, dynamic> data =
    Map<dynamic, dynamic>.from(
      snapshot.value as Map,
    );

    final String receiverUid =
        data['receiverUid']
            ?.toString() ??
            '';

    // لا يستطيع المستخدم وضع رسالة
    // ليست له كمقروءة
    if (receiverUid != user.uid) {
      return;
    }

    await ref.update({
      'read': true,
    });
  }

  // =====================================================
  // حذف رسالة أو مجموعة من الرسائل الواردة أو الصادرة
  // =====================================================

  Future<void> deleteMessages(
      Iterable<String> messageIds) async {

    final User? user =
        auth.currentUser;

    if (user == null) {
      throw Exception(
        'يجب تسجيل الدخول أولاً',
      );
    }

    final Set<String> cleanIds = messageIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    if (cleanIds.isEmpty) {
      return;
    }

    final Map<String, Object?> updates = {
      for (final String id in cleanIds)
        id: null,
    };

    // قواعد Firebase تسمح بالحذف فقط عندما يكون
    // المستخدم الحالي مرسل الرسالة أو مستلمها.
    await messagesRef.update(updates);
  }
}
