class PasswordRequestModel {
final String id;

// المستخدم
final String userId;
final String fullName;
final String role;

// المحافظة والفرع والمحطة
final String governorateId;
final String governorateName;

final String branchId;
final String branchName;

final String stationId;
final String stationName;

// كلمة المرور الجديدة
final String newPassword;

// سبب التغيير
final String reason;

// حالة الطلب
final String status;
// pending
// approved
// rejected

// بيانات المراجعة
final String reviewedBy;
final String reviewerName;

final String reviewNote;

// التواريخ
final DateTime createdAt;
final DateTime reviewedAt;

const PasswordRequestModel({
required this.id,
required this.userId,
required this.fullName,
required this.role,
required this.governorateId,
required this.governorateName,
required this.branchId,
required this.branchName,
required this.stationId,
required this.stationName,
required this.newPassword,
required this.reason,
required this.status,
required this.reviewedBy,
required this.reviewerName,
required this.reviewNote,
required this.createdAt,
required this.reviewedAt,
});

factory PasswordRequestModel.fromMap(
String id,
Map<String, dynamic> map,
) {
return PasswordRequestModel(
id: id,

userId: map["userId"] ?? "",

fullName: map["fullName"] ?? "",

role: map["role"] ?? "",

governorateId:
map["governorateId"] ?? "",

governorateName:
map["station.governorateName"] ?? "",

branchId:
map["branchId"] ?? "",

branchName:
map["branchName"] ?? "",

stationId:
map["stationId"] ?? "",

stationName:
map["stationName"] ?? "",

newPassword:
map["newPassword"] ?? "",

reason:
map["reason"] ?? "",

status:
map["status"] ?? "pending",

reviewedBy:
map["reviewedBy"] ?? "",

reviewerName:
map["reviewerName"] ?? "",

reviewNote:
map["reviewNote"] ?? "",

createdAt:
DateTime.tryParse(
map["createdAt"] ?? "",
) ??
DateTime.now(),

reviewedAt:
DateTime.tryParse(
map["reviewedAt"] ?? "",
) ??
DateTime.now(),
);
}
  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "fullName": fullName,
      "role": role,

      "governorateId": governorateId,
      "station.governorateName": governorateName,

      "branchId": branchId,
      "branchName": branchName,

      "stationId": stationId,
      "stationName": stationName,

      "newPassword": newPassword,

      "reason": reason,

      "status": status,

      "reviewedBy": reviewedBy,
      "reviewerName": reviewerName,

      "reviewNote": reviewNote,

      "createdAt": createdAt.toIso8601String(),

      "reviewedAt": reviewedAt.toIso8601String(),
    };
  }

  PasswordRequestModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? role,
    String? governorateId,
    String? governorateName,
    String? branchId,
    String? branchName,
    String? stationId,
    String? stationName,
    String? newPassword,
    String? reason,
    String? status,
    String? reviewedBy,
    String? reviewerName,
    String? reviewNote,
    DateTime? createdAt,
    DateTime? reviewedAt,
  }) {
    return PasswordRequestModel(
      id: id ?? this.id,

      userId: userId ?? this.userId,

      fullName: fullName ?? this.fullName,

      role: role ?? this.role,

      governorateId:
      governorateId ?? this.governorateId,

      governorateName:
      governorateName ??
          this.governorateName,

      branchId: branchId ?? this.branchId,

      branchName:
      branchName ?? this.branchName,

      stationId:
      stationId ?? this.stationId,

      stationName:
      stationName ?? this.stationName,

      newPassword:
      newPassword ?? this.newPassword,

      reason: reason ?? this.reason,

      status: status ?? this.status,

      reviewedBy:
      reviewedBy ?? this.reviewedBy,

      reviewerName:
      reviewerName ?? this.reviewerName,

      reviewNote:
      reviewNote ?? this.reviewNote,

      createdAt:
      createdAt ?? this.createdAt,

      reviewedAt:
      reviewedAt ?? this.reviewedAt,
    );
  }
}