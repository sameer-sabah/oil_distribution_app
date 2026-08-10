class GovernorateModel {
  final String id;

  // معلومات المحافظة
  final String name;
  final String code;

  // مدير الفرع
  final String managerId;
  final String managerName;

  // الإحصائيات
  final int branchesCount;
  final int governmentStations;
  final int privateStations;

  // حالة المحافظة
  final bool active;

  // التواريخ
  final DateTime createdAt;
  final DateTime updatedAt;

  const GovernorateModel({
    required this.id,
    required this.name,
    required this.code,
    required this.managerId,
    required this.managerName,
    required this.branchesCount,
    required this.governmentStations,
    required this.privateStations,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GovernorateModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return GovernorateModel(
      id: id,

      name: map["name"] ?? "",

      code: map["code"] ?? "",

      managerId: map["managerId"] ?? "",

      managerName: map["managerName"] ?? "",

      branchesCount: map["branchesCount"] ?? 0,

      governmentStations:
      map["governmentStations"] ?? 0,

      privateStations:
      map["privateStations"] ?? 0,

      active: map["active"] ?? true,

      createdAt: DateTime.tryParse(
        map["createdAt"] ?? "",
      ) ??
          DateTime.now(),

      updatedAt: DateTime.tryParse(
        map["updatedAt"] ?? "",
      ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "code": code,

      "managerId": managerId,
      "managerName": managerName,

      "branchesCount": branchesCount,

      "governmentStations": governmentStations,

      "privateStations": privateStations,

      "active": active,

      "createdAt": createdAt.toIso8601String(),

      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  GovernorateModel copyWith({
    String? id,
    String? name,
    String? code,
    String? managerId,
    String? managerName,
    int? branchesCount,
    int? governmentStations,
    int? privateStations,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GovernorateModel(
      id: id ?? this.id,

      name: name ?? this.name,

      code: code ?? this.code,

      managerId: managerId ?? this.managerId,

      managerName:
      managerName ?? this.managerName,

      branchesCount:
      branchesCount ?? this.branchesCount,

      governmentStations:
      governmentStations ??
          this.governmentStations,

      privateStations:
      privateStations ??
          this.privateStations,

      active: active ?? this.active,

      createdAt:
      createdAt ?? this.createdAt,

      updatedAt:
      updatedAt ?? this.updatedAt,
    );
  }
}