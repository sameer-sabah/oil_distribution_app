class Station {
  final String id;

  final String name;

  final String managerUid;
  final String managerName;
  final String managerPhone;

  final String governorate;
  final String district;
  final String address;

  final String phone;

  final String stationType;

// المنتجات
  final int regular95;
  final int improved95;
  final int super95;
  final int diesel;
  final int whiteOil;
  final int lpg;

// الفرع
  final String branchId;
  final String branchName;

// بيانات الإجازة
  final String licenseNumber;
  final String licenseIssuer;
  final String licenseIssueDate;
  final String licenseExpiryDate;

// الصور
  final String stationLicense;
  final String identityFront;
  final String identityBack;
  final String managerPhoto;
  final String stationPhoto;

// الموقع
  final double latitude;
  final double longitude;

// حالة المحطة
  final String workingHours;
  final String workingStatus;

  final bool approved;
  final bool active;

  final String notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Station({
    required this.id,
    required this.name,

    required this.managerUid,
    required this.managerName,
    required this.managerPhone,

    required this.governorate,
    required this.district,
    required this.address,

    required this.phone,

    required this.stationType,

    required this.regular95,
    required this.improved95,
    required this.super95,
    required this.diesel,
    required this.whiteOil,
    required this.lpg,

    required this.branchId,
    required this.branchName,

    required this.licenseNumber,
    required this.licenseIssuer,
    required this.licenseIssueDate,
    required this.licenseExpiryDate,

    required this.stationLicense,
    required this.identityFront,
    required this.identityBack,
    required this.managerPhoto,
    required this.stationPhoto,

    required this.latitude,
    required this.longitude,

    required this.workingHours,
    required this.workingStatus,

    required this.approved,
    required this.active,

    required this.notes,

    required this.createdAt,
    required this.updatedAt,
  });

  factory Station.fromMap(String id,
      Map<dynamic, dynamic> map,) {
    return Station(
      id: id,
      name: map["stationName"] ?? map["name"] ?? "",

      managerUid: map["managerUid"] ?? "",
      managerName: map["managerName"] ?? "",
      managerPhone: map["managerPhone"] ?? "",

      governorate: map["governorate"] ?? "",
      district: map["district"] ?? "",
      address: map["address"] ?? "",

      phone: map["stationPhone"] ?? map["phone"] ?? "",

      stationType: map["stationType"] ?? "",

      regular95: map["regular95"] ?? 0,
      improved95: map["improved95"] ?? 0,
      super95: map["super95"] ?? 0,
      diesel: map["diesel"] ?? 0,
      whiteOil: map["whiteOil"] ?? 0,
      lpg: map["lpg"] ?? 0,

      branchId: map["branchId"] ?? "",
      branchName: map["branchName"] ?? "",

      licenseNumber: map["licenseNumber"] ?? "",
      licenseIssuer: map["licenseIssuer"] ?? "",
      licenseIssueDate: map["licenseIssueDate"] ?? "",
      licenseExpiryDate: map["licenseExpiryDate"] ?? "",

      stationLicense: map["stationLicense"] ?? "",
      identityFront: map["identityFront"] ?? "",
      identityBack: map["identityBack"] ?? "",
      managerPhoto: map["managerPhoto"] ?? "",
      stationPhoto: map["stationPhoto"] ?? "",

      latitude: (map["latitude"] ?? 0).toDouble(),
      longitude: (map["longitude"] ?? 0).toDouble(),

      workingHours: map["workingHours"] ?? "",
      workingStatus: map["workingStatus"] ?? "closed",

      approved: map["approved"] ?? false,
      active: map["active"] ?? true,

      notes: map["notes"] ?? "",

      createdAt: DateTime.tryParse(
        map["createdAt"]?.toString() ?? "",
      ) ??
          DateTime.now(),

      updatedAt: DateTime.tryParse(
        map["updatedAt"]?.toString() ?? "",
      ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,

      "stationName": name,

      "managerUid": managerUid,
      "managerName": managerName,
      "managerPhone": managerPhone,

      "governorate": governorate,
      "district": district,
      "address": address,

      "phone": phone,

      "stationType": stationType,

      "regular95": regular95,
      "improved95": improved95,
      "super95": super95,
      "diesel": diesel,
      "whiteOil": whiteOil,
      "lpg": lpg,

      "branchId": branchId,
      "branchName": branchName,

      "licenseNumber": licenseNumber,
      "licenseIssuer": licenseIssuer,
      "licenseIssueDate": licenseIssueDate,
      "licenseExpiryDate": licenseExpiryDate,

      "stationLicense": stationLicense,
      "identityFront": identityFront,
      "identityBack": identityBack,
      "managerPhoto": managerPhoto,
      "stationPhoto": stationPhoto,

      "latitude": latitude,
      "longitude": longitude,

      "workingHours": workingHours,
      "workingStatus": workingStatus,
      "approved": approved,
      "active": active,

      "notes": notes,

      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  Station copyWith({
    String? name,
    String? managerUid,
    String? managerName,
    String? managerPhone,

    String? governorate,
    String? district,
    String? address,

    String? phone,

    String? stationType,

    int? regular95,
    int? improved95,
    int? super95,
    int? diesel,
    int? whiteOil,
    int? lpg,

    String? branchId,
    String? branchName,

    String? licenseNumber,
    String? licenseIssuer,
    String? licenseIssueDate,
    String? licenseExpiryDate,

    String? stationLicense,
    String? identityFront,
    String? identityBack,
    String? managerPhoto,
    String? stationPhoto,

    double? latitude,
    double? longitude,

    String? workingHours,
    String? workingStatus,

    bool? approved,
    bool? active,

    String? notes,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Station(
      id: id,
      name: name ?? this.name,

      managerUid: managerUid ?? this.managerUid,
      managerName: managerName ?? this.managerName,
      managerPhone: managerPhone ?? this.managerPhone,

      governorate: governorate ?? this.governorate,
      district: district ?? this.district,
      address: address ?? this.address,

      phone: phone ?? this.phone,

      stationType: stationType ?? this.stationType,

      regular95: regular95 ?? this.regular95,
      improved95: improved95 ?? this.improved95,
      super95: super95 ?? this.super95,
      diesel: diesel ?? this.diesel,
      whiteOil: whiteOil ?? this.whiteOil,
      lpg: lpg ?? this.lpg,

      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,

      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseIssuer: licenseIssuer ?? this.licenseIssuer,
      licenseIssueDate: licenseIssueDate ?? this.licenseIssueDate,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,

      stationLicense: stationLicense ?? this.stationLicense,
      identityFront: identityFront ?? this.identityFront,
      identityBack: identityBack ?? this.identityBack,
      managerPhoto: managerPhoto ?? this.managerPhoto,
      stationPhoto: stationPhoto ?? this.stationPhoto,

      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,

      workingHours: workingHours ?? this.workingHours,
      workingStatus: workingStatus ?? this.workingStatus,

      approved: approved ?? this.approved,
      active: active ?? this.active,

      notes: notes ?? this.notes,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}