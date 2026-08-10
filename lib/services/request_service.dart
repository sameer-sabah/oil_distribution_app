import 'package:firebase_database/firebase_database.dart';

import '../models/request_model.dart';

class RequestService {
RequestService._();

static final RequestService instance = RequestService._();

final FirebaseDatabase _database = FirebaseDatabase.instance;

DatabaseReference get requestsRef => _database.ref("requests");

//====================================
// إنشاء طلب جديد
//====================================

Future<String> createRequest(RequestModel request) async {
final ref = requestsRef.push();

final id = ref.key!;

final newRequest = request.copyWith(id: id);

await ref.set(newRequest.toMap());

return id;
}

//====================================
// تحديث طلب
//====================================

Future<void> updateRequest(
RequestModel request,
) async {
await requestsRef
.child(request.id)
.update(
request.copyWith(
updatedAt: DateTime.now(),
).toMap(),
);
}

//====================================
// جلب طلب واحد
//====================================

Future<RequestModel?> getRequest(
String id,
) async {
final snapshot =
await requestsRef.child(id).get();

if (!snapshot.exists ||
snapshot.value == null) {
return null;
}

return RequestModel.fromMap(
id,
Map<dynamic, dynamic>.from(
snapshot.value as Map,
),
);
}

//====================================
// جميع الطلبات
//====================================

Future<List<RequestModel>>
getAllRequests() async {
final snapshot =
await requestsRef.get();

if (!snapshot.exists ||
snapshot.value == null) {
return [];
}

final data =
Map<dynamic, dynamic>.from(
snapshot.value as Map,
);

final List<RequestModel> list = [];

data.forEach((key, value) {
list.add(
RequestModel.fromMap(
key.toString(),
Map<dynamic, dynamic>.from(
value,
),
),
);
});

list.sort(
(a, b) => b.createdAt.compareTo(
a.createdAt,
),
);

return list;
}

//====================================
// طلبات محطة معينة
//====================================

Future<List<RequestModel>>
getStationRequests(
String stationId,
) async {
final all =
await getAllRequests();

return all
.where(
(e) =>
e.stationId == stationId,
)
.toList();
}

//====================================
// الطلبات حسب الحالة
//====================================

Future<List<RequestModel>>
getRequestsByStatus(
String status,
) async {
final all =
await getAllRequests();

return all
.where(
(e) => e.status == status,
)
.toList();
}

//====================================
// البحث باسم المحطة
//====================================

Future<List<RequestModel>>
searchRequests(
String keyword,
) async {
final all =
await getAllRequests();

return all
.where(
(e) => e.stationName
.toLowerCase()
.contains(
keyword.toLowerCase(),
),
)
.toList();
}
  //====================================
  // اعتماد الطلب
  //====================================

  Future<void> approveRequest({
    required String requestId,
    required String approvedBy,
    required List<RequestItem> items,
  }) async {
    final request = await getRequest(requestId);

    if (request == null) return;

    await requestsRef.child(requestId).update(
      request.copyWith(
        status: "approved",
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: items,
      ).toMap(),
    );
  }

  //====================================
  // رفض الطلب
  //====================================

  Future<void> rejectRequest({
    required String requestId,
    required String rejectedBy,
    required String reason,
  }) async {
    final request = await getRequest(requestId);

    if (request == null) return;

    await requestsRef.child(requestId).update(
      request.copyWith(
        status: "rejected",
        rejectedBy: rejectedBy,
        rejectReason: reason,
        updatedAt: DateTime.now(),
      ).toMap(),
    );
  }

  //====================================
  // تغيير حالة الطلب
  //====================================

  Future<void> updateStatus({
    required String requestId,
    required String status,
  }) async {
    await requestsRef.child(requestId).update({
      "status": status,
      "updatedAt":
      DateTime.now().toIso8601String(),
    });
  }

  //====================================
  // تأكيد الاستلام
  //====================================

  Future<void> receiveRequest(
      String requestId,
      ) async {
    final request = await getRequest(requestId);

    if (request == null) return;

    await requestsRef.child(requestId).update(
      request.copyWith(
        status: "received",
        received: true,
        deliveredAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).toMap(),
    );
  }

  //====================================
  // حذف الطلب
  //====================================

  Future<void> deleteRequest(
      String requestId,
      ) async {
    await requestsRef
        .child(requestId)
        .remove();
  }

  //====================================
  // متابعة مباشرة لجميع الطلبات
  //====================================

  Stream<List<RequestModel>>
  requestsStream() {
    return requestsRef.onValue.map((event) {
      if (event.snapshot.value == null) {
        return <RequestModel>[];
      }

      final data =
      Map<dynamic, dynamic>.from(
        event.snapshot.value as Map,
      );

      final List<RequestModel> list = [];

      data.forEach((key, value) {
        list.add(
          RequestModel.fromMap(
            key.toString(),
            Map<dynamic, dynamic>.from(
              value,
            ),
          ),
        );
      });

      list.sort(
            (a, b) =>
            b.createdAt.compareTo(
              a.createdAt,
            ),
      );

      return list;
    });
  }

  //====================================
  // متابعة مباشرة لطلبات محطة معينة
  //====================================

  Stream<List<RequestModel>>
  stationRequestsStream(
      String stationId,
      ) {
    return requestsStream().map(
          (list) => list
          .where(
            (e) =>
        e.stationId ==
            stationId,
      )
          .toList(),
    );
  }
}