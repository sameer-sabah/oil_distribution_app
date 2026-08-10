class BranchModel {
  final String id;

  final String governorateId;
  final String governorateName;

  final String name;

  final String managerId;
  final String managerName;
  final String phone;
  final String email;
  final String address;

  final bool active;
  final int governmentStations;
  final int privateStations;
  final int usersCount;

  final DateTime updatedAt;
  final DateTime createdAt;

  const BranchModel({
    required this.managerName,

    required this.governmentStations,
    required this.privateStations,
    required this.usersCount,

    required this.updatedAt,
    required this.id,
    required this.governorateId,
    required this.governorateName,
    required this.name,
    required this.managerId,
    required this.phone,
    required this.email,
    required this.address,
    required this.active,
    required this.createdAt,
  });


  //=========================================
  // From Firebase
  //=========================================

  factory BranchModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {

    return BranchModel(

      id: id,

      governorateId:
      map["governorateId"] ?? "",

      governorateName:
      map["governorateName"] ?? "",

      name:
      map["name"] ?? "",

      managerId:
      map["managerId"] ?? "",
      managerName:
      map["managerName"] ?? "",
      phone:
      map["phone"] ?? "",

      email:
      map["email"] ?? "",

      address:
      map["address"] ?? "",

      active:
      map["active"] ?? true,
      governmentStations:
      map["governmentStations"] ?? 0,

      privateStations:
      map["privateStations"] ?? 0,

      usersCount:
      map["usersCount"] ?? 0,
      createdAt:
      DateTime.tryParse(
        map["createdAt"] ?? "",
      ) ??
          DateTime.now(),
      updatedAt:
      DateTime.tryParse(
        map["updatedAt"] ?? "",
      ) ??
          DateTime.now(),
    );
  }



  //=========================================
  // To Firebase
  //=========================================

  Map<String, dynamic> toMap() {

    return {

      "governorateId":
      governorateId,

      "governorateName":
      governorateName,

      "name":
      name,

      "managerId":
      managerId,
      "managerName":
      managerName,
      "phone":
      phone,

      "email":
      email,

      "address":
      address,

      "active":
      active,
      "governmentStations":
      governmentStations,

      "privateStations":
      privateStations,

      "usersCount":
      usersCount,

      "updatedAt":
      updatedAt.toIso8601String(),
      "createdAt":
      createdAt.toIso8601String(),
    };
  }



  //=========================================
  // Copy
  //=========================================

  BranchModel copyWith({

    String? id,

    String? governorateId,

    String? governorateName,

    String? name,
    String? managerName,

    int? governmentStations,

    int? privateStations,

    int? usersCount,

    DateTime? updatedAt,
    String? managerId,

    String? phone,

    String? email,

    String? address,

    bool? active,

    DateTime? createdAt,

  }) {

    return BranchModel(

      id:
      id ?? this.id,

      governorateId:
      governorateId ?? this.governorateId,

      governorateName:
      governorateName ?? this.governorateName,

      name:
      name ?? this.name,

      managerId:
      managerId ?? this.managerId,
      managerName:
      managerName ?? this.managerName,

      governmentStations:
      governmentStations ?? this.governmentStations,

      privateStations:
      privateStations ?? this.privateStations,

      usersCount:
      usersCount ?? this.usersCount,

      updatedAt:
      updatedAt ?? this.updatedAt,
      phone:
      phone ?? this.phone,

      email:
      email ?? this.email,

      address:
      address ?? this.address,

      active:
      active ?? this.active,

      createdAt:
      createdAt ?? this.createdAt,
    );
  }
}