class StationRequestModel {
  final String id;

  // بيانات الطلب
  final String requestNumber;

  // مقدم الطلب
  final String requesterId;
  final String requesterName;

  // المحافظة
  final String governorateId;
  final String governorateName;

  // الفرع
  final String branchId;
  final String branchName;

  // بيانات المحطة
  final String stationName;
  final String stationType;

  final String phone;
  final String address;

  final double latitude;
  final double longitude;

  // المدير المقترح للمحطة
  final String managerName;
  final String managerPhone;
  final String managerEmail;

  // سبب إنشاء المحطة
  final String reason;

  // حالة الطلب
  final String status;

  // المراجعة
  final String reviewedBy;
  final String reviewerName;
  final String reviewNote;

  // التواريخ
  final DateTime createdAt;
  final DateTime reviewedAt;

  const StationRequestModel({
    required this.id,
    required this.requestNumber,
    required this.requesterId,
    required this.requesterName,
    required this.governorateId,
    required this.governorateName,
    required this.branchId,
    required this.branchName,
    required this.stationName,
    required this.stationType,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.managerName,
    required this.managerPhone,
    required this.managerEmail,
    required this.reason,
    required this.status,
    required this.reviewedBy,
    required this.reviewerName,
    required this.reviewNote,
    required this.createdAt,
    required this.reviewedAt,
  });

  factory StationRequestModel.fromMap(
      String id,
      Map<String, dynamic> map,
      )
  {
    return StationRequestModel(
      id: id,

      requestNumber:
      map["requestNumber"] ?? "",

      requesterId:
      map["requesterId"] ?? "",

      requesterName:
      map["requesterName"] ?? "",

      governorateId:
      map["governorateId"] ?? "",

      governorateName:
      map["station.governorateName"] ?? "",

      branchId:
      map["branchId"] ?? "",

      branchName:
      map["branchName"] ?? "",

      stationName:
      map["stationName"] ?? "",

      stationType:
      map["stationType"] ?? "",

      phone:
      map["phone"] ?? "",

      address:
      map["address"] ?? "",

      latitude:
      (map["latitude"] ?? 0).toDouble(),

      longitude:
      (map["longitude"] ?? 0).toDouble(),

      managerName:
      map["managerName"] ?? "",

      managerPhone:
      map["managerPhone"] ?? "",

      managerEmail:
      map["managerEmail"] ?? "",

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
    "requestNumber": requestNumber,

    "requesterId": requesterId,
    "requesterName": requesterName,

    "governorateId": governorateId,
    "station.governorateName": governorateName,

    "branchId": branchId,
    "branchName": branchName,

    "stationName": stationName,
    "stationType": stationType,

    "phone": phone,
    "address": address,

    "latitude": latitude,
    "longitude": longitude,

    "managerName": managerName,
    "managerPhone": managerPhone,
    "managerEmail": managerEmail,

    "reason": reason,

    "status": status,

    "reviewedBy": reviewedBy,
    "reviewerName": reviewerName,
    "reviewNote": reviewNote,

    "createdAt": createdAt.toIso8601String(),
    "reviewedAt": reviewedAt.toIso8601String(),
  };
}

StationRequestModel copyWith({
  String? id,
  String? requestNumber,
  String? requesterId,
  String? requesterName,
  String? governorateId,
  String? governorateName,
  String? branchId,
  String? branchName,
  String? stationName,
  String? stationType,
  String? phone,
  String? address,
  double? latitude,
  double? longitude,
  String? managerName,
  String? managerPhone,
  String? managerEmail,
  String? reason,
  String? status,
  String? reviewedBy,
  String? reviewerName,
  String? reviewNote,
  DateTime? createdAt,
  DateTime? reviewedAt,
}) {
  return StationRequestModel(
    id: id ?? this.id,

    requestNumber:
    requestNumber ?? this.requestNumber,

    requesterId:
    requesterId ?? this.requesterId,

    requesterName:
    requesterName ?? this.requesterName,

    governorateId:
    governorateId ?? this.governorateId,

    governorateName:
    governorateName ??
        this.governorateName,

    branchId:
    branchId ?? this.branchId,

    branchName:
    branchName ?? this.branchName,

    stationName:
    stationName ?? this.stationName,

    stationType:
    stationType ?? this.stationType,

    phone:
    phone ?? this.phone,

    address:
    address ?? this.address,

    latitude:
    latitude ?? this.latitude,

    longitude:
    longitude ?? this.longitude,

    managerName:
    managerName ?? this.managerName,

    managerPhone:
    managerPhone ?? this.managerPhone,

    managerEmail:
    managerEmail ?? this.managerEmail,

    reason:
    reason ?? this.reason,

    status:
    status ?? this.status,

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