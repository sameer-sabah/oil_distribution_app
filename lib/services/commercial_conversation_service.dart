import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/commercial_message.dart';

class CommercialConversationService {
  CommercialConversationService._();

  static final CommercialConversationService instance =
  CommercialConversationService._();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  DatabaseReference get conversationsRef =>
      _database.ref('commercialConversations');

  String conversationId(String entityType, String entityId) {
    final safeType = entityType.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final safeId = entityId.replaceAll(RegExp(r'[.#$\[\]/]'), '_');
    return '${safeType}_$safeId';
  }

  Future<void> ensureConversation({
    required String entityType,
    required String entityId,
    required String ownerUid,
    required String title,
    required String ownerName,
    required String ownerPhone,
    required String ownerWhatsapp,
  }) async {
    if (ownerUid.isEmpty || entityId.isEmpty) return;

    final id = conversationId(entityType, entityId);
    final ref = conversationsRef.child(id);
    final snapshot = await ref.get();
    final now = DateTime.now().toIso8601String();

    if (!snapshot.exists) {
      await ref.set({
        'id': id,
        'entityType': entityType,
        'entityId': entityId,
        'ownerUid': ownerUid,
        'title': title,
        'ownerName': ownerName,
        'ownerPhone': ownerPhone,
        'ownerWhatsapp': ownerWhatsapp,
        'lastMessage': '',
        'lastMessageAt': now,
        'adminUnreadCount': 0,
        'ownerUnreadCount': 0,
        'createdAt': now,
      });
      return;
    }

    final updates = <String, Object?>{
      if (title.trim().isNotEmpty) 'title': title.trim(),
      if (ownerName.trim().isNotEmpty) 'ownerName': ownerName.trim(),
      if (ownerPhone.trim().isNotEmpty) 'ownerPhone': ownerPhone.trim(),
      if (ownerWhatsapp.trim().isNotEmpty)
        'ownerWhatsapp': ownerWhatsapp.trim(),
    };
    if (updates.isNotEmpty) {
      await ref.update(updates);
    }
  }

  Stream<List<CommercialMessage>> messagesStream({
    required String entityType,
    required String entityId,
  }) {
    final id = conversationId(entityType, entityId);
    return conversationsRef.child(id).child('messages').onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <CommercialMessage>[];

      final raw = Map<dynamic, dynamic>.from(value);
      final messages = raw.entries
          .where((entry) => entry.value is Map)
          .map(
            (entry) => CommercialMessage.fromMap(
          entry.key.toString(),
          Map<dynamic, dynamic>.from(entry.value as Map),
        ),
      )
          .toList();

      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return messages;
    });
  }

  Stream<List<Map<String, dynamic>>> allConversationsStream() {
    return conversationsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <Map<String, dynamic>>[];

      final raw = Map<dynamic, dynamic>.from(value);
      final conversations = raw.entries
          .where((entry) => entry.value is Map)
          .map((entry) {
        final map = Map<String, dynamic>.from(entry.value as Map);
        map['id'] = entry.key.toString();
        return map;
      })
          .toList();

      conversations.sort(
            (a, b) => (b['lastMessageAt'] ?? '')
            .toString()
            .compareTo((a['lastMessageAt'] ?? '').toString()),
      );
      return conversations;
    });
  }

  Stream<int> adminUnreadCountStream() {
    return conversationsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return 0;

      var total = 0;
      for (final item in Map<dynamic, dynamic>.from(value).values) {
        if (item is! Map) continue;
        total += int.tryParse(item['adminUnreadCount']?.toString() ?? '') ?? 0;
      }
      return total;
    });
  }

  Stream<int> ownerUnreadCountStream(String ownerUid) {
    if (ownerUid.isEmpty) return Stream<int>.value(0);

    return conversationsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return 0;

      var total = 0;
      for (final item in Map<dynamic, dynamic>.from(value).values) {
        if (item is! Map || item['ownerUid']?.toString() != ownerUid) {
          continue;
        }
        total += int.tryParse(item['ownerUnreadCount']?.toString() ?? '') ?? 0;
      }
      return total;
    });
  }

  Future<void> sendMessage({
    required String entityType,
    required String entityId,
    required String ownerUid,
    required String title,
    required String ownerName,
    required String ownerPhone,
    required String ownerWhatsapp,
    required String text,
    required bool isAdmin,
    String senderName = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final cleanText = text.trim();
    if (user == null || user.isAnonymous) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }
    if (cleanText.isEmpty) return;
    if (!isAdmin && user.uid != ownerUid) {
      throw Exception('لا تملك صلاحية إرسال رسالة في هذه المحادثة');
    }

    await ensureConversation(
      entityType: entityType,
      entityId: entityId,
      ownerUid: ownerUid,
      title: title,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      ownerWhatsapp: ownerWhatsapp,
    );

    final conversationKey = conversationId(entityType, entityId);
    final ref = conversationsRef.child(conversationKey);
    final messageRef = ref.child('messages').push();
    final now = DateTime.now().toIso8601String();

    await messageRef.set({
      'id': messageRef.key,
      'senderUid': user.uid,
      'senderRole': isAdmin ? 'admin' : 'advertiser',
      'senderName': senderName.trim().isEmpty
          ? (isAdmin ? 'مدير النظام' : ownerName)
          : senderName.trim(),
      'text': cleanText,
      'createdAt': now,
      'readByAdmin': isAdmin,
      'readByOwner': !isAdmin,
    });

    await ref.update({
      'lastMessage': cleanText,
      'lastMessageAt': now,
    });

    final unreadField = isAdmin ? 'ownerUnreadCount' : 'adminUnreadCount';
    await ref.child(unreadField).runTransaction((value) {
      final current = int.tryParse(value?.toString() ?? '') ?? 0;
      return Transaction.success(current + 1);
    });
  }

  Future<void> markRead({
    required String entityType,
    required String entityId,
    required bool isAdmin,
  }) async {
    final conversationKey = conversationId(entityType, entityId);
    final ref = conversationsRef.child(conversationKey);
    final snapshot = await ref.child('messages').get();
    final updates = <String, Object?>{
      isAdmin ? 'adminUnreadCount' : 'ownerUnreadCount': 0,
    };

    if (snapshot.value is Map) {
      final raw = Map<dynamic, dynamic>.from(snapshot.value as Map);
      for (final entry in raw.entries) {
        if (entry.value is! Map) continue;
        final message = Map<dynamic, dynamic>.from(entry.value as Map);
        final fromAdmin = message['senderRole']?.toString() == 'admin';
        if ((isAdmin && !fromAdmin) || (!isAdmin && fromAdmin)) {
          updates['messages/${entry.key}/${isAdmin ? 'readByAdmin' : 'readByOwner'}'] =
          true;
        }
      }
    }

    await ref.update(updates);
  }

  Future<void> deleteConversation({
    required String entityType,
    required String entityId,
  }) async {
    if (entityId.trim().isEmpty) {
      throw ArgumentError('معرّف المحادثة غير موجود');
    }

    final conversationKey = conversationId(entityType, entityId);
    await conversationsRef.child(conversationKey).remove();
  }
}
