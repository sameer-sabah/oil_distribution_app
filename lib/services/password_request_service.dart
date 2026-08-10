import 'package:firebase_database/firebase_database.dart';

import '../models/password_request_model.dart';

class PasswordRequestService {
PasswordRequestService._();

static final PasswordRequestService instance =
PasswordRequestService._();

final FirebaseDatabase _database =
FirebaseDatabase.instance;

DatabaseReference get requestsRef =>
_database.ref("passwordRequests");

//=========================================
// إرسال طلب تغيير كلمة المرور
//=========================================

Future<void> sendRequest(
PasswordRequestModel request,
) async {

await requestsRef
.child(request.id)
.set(request.toMap());

}

//=========================================
// إنشاء رقم طلب جديد
//=========================================

String generateRequestId() {

return requestsRef.push().key!;

}  //=========================================
// جلب جميع الطلبات
//=========================================

Future<List<PasswordRequestModel>> getRequests() async {
final snapshot = await requestsRef.get();

if (!snapshot.exists || snapshot.value == null) {
return [];
}

final data = Map<dynamic, dynamic>.from(
snapshot.value as Map,
);

return data.entries.map((e) {
return PasswordRequestModel.fromMap(
e.key.toString(),
Map<String, dynamic>.from(
e.value as Map,
),
);
}).toList();
}

//=========================================
// جلب طلب واحد
//=========================================

Future<PasswordRequestModel?> getRequest(
String requestId,
) async {
final snapshot =
await requestsRef.child(requestId).get();

if (!snapshot.exists || snapshot.value == null) {
return null;
}

return PasswordRequestModel.fromMap(
requestId,
Map<String, dynamic>.from(
snapshot.value as Map,
),
);
}

//=========================================
// الطلبات المعلقة
//=========================================

Future<List<PasswordRequestModel>>
getPendingRequests() async {
final requests = await getRequests();

return requests
.where((r) => r.status == "pending")
.toList();
}

//=========================================
// الطلبات الموافق عليها
//=========================================

Future<List<PasswordRequestModel>>
getApprovedRequests() async {
final requests = await getRequests();

return requests
.where((r) => r.status == "approved")
.toList();
}

//=========================================
// الطلبات المرفوضة
//=========================================

Future<List<PasswordRequestModel>>
getRejectedRequests() async {
final requests = await getRequests();

return requests
.where((r) => r.status == "rejected")
.toList();
}
//=========================================
// الموافقة على الطلب
//=========================================

Future<void> approveRequest({
required String requestId,
required String reviewerId,
required String reviewerName,
String reviewNote = "",
}) async {
await requestsRef
.child(requestId)
.update({
"status": "approved",

"reviewedBy": reviewerId,

"reviewerName": reviewerName,

"reviewNote": reviewNote,

"reviewedAt":
DateTime.now().toIso8601String(),
});
}

//=========================================
// رفض الطلب
//=========================================

Future<void> rejectRequest({
required String requestId,
required String reviewerId,
required String reviewerName,
required String reviewNote,
}) async {
await requestsRef
.child(requestId)
.update({
"status": "rejected",

"reviewedBy": reviewerId,

"reviewerName": reviewerName,

"reviewNote": reviewNote,

"reviewedAt":
DateTime.now().toIso8601String(),
});
}

//=========================================
// تحديث حالة الطلب
//=========================================

Future<void> updateStatus({
required String requestId,
required String status,
}) async {
await requestsRef
.child(requestId)
.update({
"status": status,
"reviewedAt":
DateTime.now().toIso8601String(),
});
}

//=========================================
// تحديث ملاحظة المراجعة
//=========================================

Future<void> updateReviewNote({
required String requestId,
required String reviewNote,
}) async {
await requestsRef
.child(requestId)
.update({
"reviewNote": reviewNote,
"reviewedAt":
DateTime.now().toIso8601String(),
});
}
//=========================================
// حذف طلب
//=========================================

Future<void> deleteRequest(
String requestId,
) async {
await requestsRef
.child(requestId)
.remove();
}

//=========================================
// البحث في الطلبات
//=========================================

Future<List<PasswordRequestModel>> searchRequests(
String keyword,
) async {
final requests = await getRequests();

final search = keyword
.trim()
.toLowerCase();

return requests.where((request) {
return request.fullName
.toLowerCase()
.contains(search) ||

request.stationName
.toLowerCase()
.contains(search) ||

request.branchName
.toLowerCase()
.contains(search) ||

request.governorateName
.toLowerCase()
.contains(search);
}).toList();
}

//=========================================
// طلبات مستخدم معين
//=========================================

Future<List<PasswordRequestModel>>
getUserRequests(
String userId,
) async {

final requests =
await getRequests();

return requests.where((request) {
return request.userId == userId;
}).toList();
}

//=========================================
// هل يوجد طلب معلق؟
//=========================================

Future<bool> hasPendingRequest(
String userId,
) async {

final requests =
await getUserRequests(userId);

return requests.any(
(request) =>
request.status == "pending",
);
}

//=========================================
// عدد الطلبات
//=========================================

Future<int> getRequestsCount() async {
final requests =
await getRequests();

return requests.length;
}

//=========================================
// عدد الطلبات المعلقة
//=========================================

Future<int> getPendingRequestsCount() async {
final requests =
await getPendingRequests();

return requests.length;
}
  //=========================================
  // حفظ الطلب بالكامل
  //=========================================

  Future<void> saveRequest(
      PasswordRequestModel request,
      ) async {
    await requestsRef
        .child(request.id)
        .set(request.toMap());
  }

  //=========================================
  // التحقق من وجود الطلب
  //=========================================

  Future<bool> requestExists(
      String requestId,
      ) async {
    final snapshot =
    await requestsRef.child(requestId).get();

    return snapshot.exists;
  }

  //=========================================
  // بث مباشر لجميع الطلبات
  //=========================================

  Stream<List<PasswordRequestModel>> requestsStream() {
    return requestsRef.onValue.map((event) {
      if (event.snapshot.value == null) {
        return <PasswordRequestModel>[];
      }

      final data = Map<dynamic, dynamic>.from(
        event.snapshot.value as Map,
      );

      return data.entries.map((entry) {
        return PasswordRequestModel.fromMap(
          entry.key.toString(),
          Map<String, dynamic>.from(
            entry.value as Map,
          ),
        );
      }).toList();
    });
  }

  //=========================================
  // بث مباشر للطلبات المعلقة
  //=========================================

  Stream<List<PasswordRequestModel>>
  pendingRequestsStream() {
    return requestsStream().map(
          (requests) => requests
          .where(
            (request) =>
        request.status == "pending",
      )
          .toList(),
    );
  }

  //=========================================
  // بث مباشر لطلب واحد
  //=========================================

  Stream<PasswordRequestModel?> requestStream(
      String requestId,
      ) {
    return requestsRef
        .child(requestId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) {
        return null;
      }

      return PasswordRequestModel.fromMap(
        requestId,
        Map<String, dynamic>.from(
          event.snapshot.value as Map,
        ),
      );
    });
  }
}