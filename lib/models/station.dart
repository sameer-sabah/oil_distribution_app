class Station {

  final String id;

  final String name;
  final String stationLicense;
  final String stationType;

  final String governorate;

  final String district;

  final String branchId;

  final String branchName;


  final double latitude;

  final double longitude;


  final String phone;

  final String address;


  final String managerUid;

  final String managerName;

  final String managerPhone;


  final int regular95;

  final int improved95;

  final int super95;

  final int diesel;

  final int whiteOil;

  final int lpg;
  final Map<String, bool> supportedProducts;

  final String workingStatus;
  final String crowdStatus;

  final String status;


  final bool approved;

  final bool active;


  final String workingHours;

  final String notes;


  final String licenseNumber;

  final String licenseIssuer;

  final String licenseIssueDate; // جديد

  final String licenseExpiryDate; // جديد


  final String createdAt;

  final String updatedAt;


  Station({

    required this.id,

    required this.name,

    required this.stationType,

    required this.stationLicense,
    required this.governorate,

    required this.district,

    required this.branchId,

    required this.branchName,


    required this.latitude,

    required this.longitude,


    required this.phone,

    required this.address,


    required this.managerUid,

    required this.managerName,

    required this.managerPhone,


    required this.regular95,

    required this.improved95,

    required this.super95,

    required this.diesel,

    required this.whiteOil,

    required this.lpg,

    Map<String, bool>? supportedProducts,
    required this.workingStatus,
    this.crowdStatus = "هادئة",

    required this.status,


    required this.approved,

    required this.active,


    required this.workingHours,

    required this.notes,


    required this.licenseNumber,

    required this.licenseIssuer,

    required this.licenseIssueDate,

    required this.licenseExpiryDate,


    required this.createdAt,

    required this.updatedAt,

  }) : supportedProducts = supportedProducts ?? {
    "regular95": true,
    "improved95": true,
    "super95": true,
    "diesel": true,
    "whiteOil": true,
    "lpg": true,
  };

  factory Station.fromMap(String id,
      Map<String, dynamic> map){
    return Station(

      id: id,

      name: map["name"] ?? "",

      stationType: map["stationType"] ?? "",

      governorate: map["governorate"] ?? "",

      district: map["district"] ?? "",

      branchId: map["branchId"] ?? "",

      branchName: map["branchName"] ?? "",


      latitude:
      double.tryParse(
          map["latitude"].toString()
      ) ?? 0,


      longitude:
      double.tryParse(
          map["longitude"].toString()
      ) ?? 0,


      phone:
      map["phone"] ?? "",


      address:
      map["address"] ?? "",


      managerUid:
      map["managerUid"] ?? "",


      managerName:
      map["managerName"] ?? "",


      managerPhone:
      map["managerPhone"] ?? "",


      regular95:
      map["regular95"] ?? 0,

      licenseIssueDate:
      map["licenseIssueDate"] ?? "",

      licenseExpiryDate:
      map["licenseExpiryDate"] ?? "",

      stationLicense:
      map["stationLicense"] ?? "",
      improved95:
      map["improved95"] ?? 0,


      super95:
      map["super95"] ?? 0,


      diesel:
      map["diesel"] ?? 0,


      whiteOil:
      map["whiteOil"] ?? 0,


      lpg:
      map["lpg"] ?? 0,
      supportedProducts:
      map["supportedProducts"] != null
          ? Map<String, bool>.from(
        map["supportedProducts"],
      )
          : {
        "regular95": true,
        "improved95": true,
        "super95": true,
        "diesel": true,
        "whiteOil": true,
        "lpg": true,
      },

      workingStatus:
      map["workingStatus"] ?? "مفتوحة",

      crowdStatus:
      map["crowdStatus"] ?? "هادئة",


      status:
      map["status"] ?? "active",


      approved:
      map["approved"] ?? false,


      active:
      map["active"] ?? true,


      workingHours:
      map["workingHours"] ?? "",


      notes:
      map["notes"] ?? "",


      licenseNumber:
      map["licenseNumber"] ?? "",


      licenseIssuer:
      map["licenseIssuer"] ?? "",



      createdAt:
      map["createdAt"] ?? "",


      updatedAt:
      map["updatedAt"] ?? "",


    );
  }


  Map<String, dynamic> toMap() {
    return {


      "name": name,

      "stationType": stationType,

      "licenseIssueDate": licenseIssueDate,

      "licenseExpiryDate": licenseExpiryDate,

      "stationLicense": stationLicense,

      "governorate": governorate,

      "district": district,


      "branchId": branchId,

      "branchName": branchName,


      "latitude": latitude,

      "longitude": longitude,


      "phone": phone,

      "address": address,


      "managerUid": managerUid,

      "managerName": managerName,

      "managerPhone": managerPhone,


      "regular95": regular95,

      "improved95": improved95,

      "super95": super95,

      "diesel": diesel,

      "whiteOil": whiteOil,

      "lpg": lpg,

      "supportedProducts": supportedProducts,
      "workingStatus": workingStatus,
      "crowdStatus": crowdStatus,

      "status": status,


      "approved": approved,

      "active": active,


      "workingHours": workingHours,

      "notes": notes,


      "licenseNumber": licenseNumber,

      "licenseIssuer": licenseIssuer,

      "createdAt": createdAt,

      "updatedAt": updatedAt,


    };
  }

  String get effectiveWorkingStatus {
    final status = workingStatus.trim().toLowerCase();
    if (status.contains('خاف') || status.contains('خفار') || workingHours.contains('24') || workingHours.contains('دائمي') || workingHours.contains('مستمر')) {
      return workingStatus.isEmpty ? 'مفتوحة' : workingStatus;
    }

    try {
      final parts = workingHours.split(RegExp(r'[-–toإلى]'));
      if (parts.length >= 2) {
        final startParts = parts[0].trim().split(':');
        final endParts = parts[1].trim().split(':');

        final startHour = int.tryParse(startParts[0]) ?? 8;
        final startMinute = startParts.length > 1 ? (int.tryParse(startParts[1]) ?? 0) : 0;

        final endHour = int.tryParse(endParts[0]) ?? 16;
        final endMinute = endParts.length > 1 ? (int.tryParse(endParts[1]) ?? 0) : 0;

        final now = DateTime.now();
        final nowMinutes = now.hour * 60 + now.minute;
        final startMinutes = startHour * 60 + startMinute;
        final endMinutes = endHour * 60 + endMinute;

        if (nowMinutes >= startMinutes && nowMinutes <= endMinutes) {
          return 'مفتوحة';
        } else {
          return 'مغلقة';
        }
      }
    } catch (_) {}

    return workingStatus.isEmpty ? 'مفتوحة' : workingStatus;
  }
  Station copyWith({

    String? id,
    String? name,
    String? stationType,
    String? governorate,
    String? district,
    String? branchId,
    String? branchName,

    double? latitude,
    double? longitude,

    String? phone,
    String? address,

    String? managerUid,
    String? managerName,
    String? managerPhone,


    int? regular95,
    int? improved95,
    int? super95,
    int? diesel,
    int? whiteOil,
    int? lpg,
    Map<String, bool>? supportedProducts,

    String? workingStatus,
    String? crowdStatus,
    String? status,


    bool? approved,
    bool? active,


    String? workingHours,
    String? notes,


    String? licenseNumber,
    String? licenseIssuer,


    String? licenseIssueDate,
    String? licenseExpiryDate,
    String? stationLicense,


    String? createdAt,
    String? updatedAt,


  }) {


    return Station(

      id: id ?? this.id,

      name: name ?? this.name,

      stationType:
      stationType ?? this.stationType,


      governorate:
      governorate ?? this.governorate,


      district:
      district ?? this.district,


      branchId:
      branchId ?? this.branchId,


      branchName:
      branchName ?? this.branchName,


      latitude:
      latitude ?? this.latitude,


      longitude:
      longitude ?? this.longitude,


      phone:
      phone ?? this.phone,


      address:
      address ?? this.address,


      managerUid:
      managerUid ?? this.managerUid,


      managerName:
      managerName ?? this.managerName,


      managerPhone:
      managerPhone ?? this.managerPhone,



      regular95:
      regular95 ?? this.regular95,


      improved95:
      improved95 ?? this.improved95,


      super95:
      super95 ?? this.super95,


      diesel:
      diesel ?? this.diesel,


      whiteOil:
      whiteOil ?? this.whiteOil,


      lpg:
      lpg ?? this.lpg,

      supportedProducts:
      supportedProducts ?? this.supportedProducts,

      workingStatus:
      workingStatus ?? this.workingStatus,

      crowdStatus:
      crowdStatus ?? this.crowdStatus,


      status:
      status ?? this.status,


      approved:
      approved ?? this.approved,


      active:
      active ?? this.active,



      workingHours:
      workingHours ?? this.workingHours,


      notes:
      notes ?? this.notes,



      licenseNumber:
      licenseNumber ?? this.licenseNumber,


      licenseIssuer:
      licenseIssuer ?? this.licenseIssuer,


      licenseIssueDate:
      licenseIssueDate ?? this.licenseIssueDate,


      licenseExpiryDate:
      licenseExpiryDate ?? this.licenseExpiryDate,


      stationLicense:
      stationLicense ?? this.stationLicense,



      createdAt:
      createdAt ?? this.createdAt,


      updatedAt:
      updatedAt ?? this.updatedAt,


    );

  }
}