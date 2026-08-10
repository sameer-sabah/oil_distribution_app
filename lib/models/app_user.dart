class AppUser {
  final String id;
  final String uid;

  final String fullName;
  final String username;
  final String password;

  final String email;
  final String phone;

  final String role;

  final String governorateId;
  final String governorateName;

  final String branchId;
  final String branchName;

  final String stationId;
  final String stationName;

  final String position;
  final String image;

  final bool active;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLogin;


  const AppUser({
    required this.id,
    required this.uid,

    required this.fullName,
    required this.username,
    required this.password,

    required this.email,
    required this.phone,

    required this.role,

    required this.governorateId,
    required this.governorateName,

    required this.branchId,
    required this.branchName,

    required this.stationId,
    required this.stationName,

    required this.position,
    required this.image,

    required this.active,

    required this.createdAt,
    required this.updatedAt,
    required this.lastLogin,
  });



  factory AppUser.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {

    return AppUser(

      id: id,

      uid:
      map["uid"] ?? id,


      fullName:
      map["fullName"] ??
          map["name"] ??
          "",


      username:
      map["username"] ?? "",


      password:
      map["password"] ?? "",


      email:
      map["email"] ?? "",


      phone:
      map["phone"] ?? "",


      role:
      map["role"] ?? "",


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


      position:
      map["position"] ?? "",


      image:
      map["image"] ?? "",


      active:
      map["active"] ?? true,


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


      lastLogin:
      DateTime.tryParse(
        map["lastLogin"] ?? "",
      ) ??
          DateTime.now(),

    );
  }



  Map<String,dynamic> toMap(){

    return {

      "uid":uid,

      "fullName":fullName,

      "username":username,

      "password":password,

      "email":email,

      "phone":phone,

      "role":role,


      "governorateId":
      governorateId,


      "station.governorateName":
      governorateName,


      "branchId":
      branchId,


      "branchName":
      branchName,


      "stationId":
      stationId,


      "stationName":
      stationName,


      "position":
      position,


      "image":
      image,


      "active":
      active,


      "createdAt":
      createdAt.toIso8601String(),


      "updatedAt":
      updatedAt.toIso8601String(),


      "lastLogin":
      lastLogin.toIso8601String(),

    };
  }



  AppUser copyWith({

    String? id,
    String? uid,

    String? fullName,
    String? username,
    String? password,

    String? email,
    String? phone,

    String? role,

    String? governorateId,
    String? governorateName,

    String? branchId,
    String? branchName,

    String? stationId,
    String? stationName,

    String? position,
    String? image,

    bool? active,

    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,

  }){

    return AppUser(

      id:id ?? this.id,

      uid:uid ?? this.uid,


      fullName:
      fullName ?? this.fullName,


      username:
      username ?? this.username,


      password:
      password ?? this.password,


      email:
      email ?? this.email,


      phone:
      phone ?? this.phone,


      role:
      role ?? this.role,


      governorateId:
      governorateId ?? this.governorateId,


      governorateName:
      governorateName ?? this.governorateName,


      branchId:
      branchId ?? this.branchId,


      branchName:
      branchName ?? this.branchName,


      stationId:
      stationId ?? this.stationId,


      stationName:
      stationName ?? this.stationName,


      position:
      position ?? this.position,


      image:
      image ?? this.image,


      active:
      active ?? this.active,


      createdAt:
      createdAt ?? this.createdAt,


      updatedAt:
      updatedAt ?? this.updatedAt,


      lastLogin:
      lastLogin ?? this.lastLogin,

    );
  }
}