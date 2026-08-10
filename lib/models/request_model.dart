class RequestModel {
  final String id;

  final String stationId;
  final String stationName;
  final String managerId;

  /// pending
  /// approved
  /// rejected
  /// in_progress
  /// delivered
  /// received
  final String status;

  final String notes;

  /// الاعتماد
  final String approvedBy;
  final DateTime? approvedAt;

  /// الرفض
  final String rejectedBy;
  final String rejectReason;

  /// الاستلام
  final bool received;
  final DateTime? deliveredAt;

  /// آخر تحديث
  final DateTime? updatedAt;

  /// الإنشاء
  final DateTime createdAt;

  /// المنتجات
  final List<RequestItem> items;

  const RequestModel({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.managerId,
    required this.status,
    required this.notes,
    required this.approvedBy,
    required this.approvedAt,
    required this.rejectedBy,
    required this.rejectReason,
    required this.received,
    required this.deliveredAt,
    required this.updatedAt,
    required this.createdAt,
    required this.items,
  });

  factory RequestModel.fromMap(
      String id,
      Map<dynamic, dynamic> map,
      ) {
    final List<RequestItem> items = [];

    if (map["items"] != null) {
      final data = Map<dynamic, dynamic>.from(
        map["items"],
      );

      data.forEach((key, value) {
        items.add(
          RequestItem.fromMap(
            key.toString(),
            Map<dynamic, dynamic>.from(value),
          ),
        );
      });
    }

    return RequestModel(
      id: id,

      stationId: map["stationId"] ?? "",

      stationName: map["stationName"] ?? "",

      managerId: map["managerId"] ?? "",

      status: map["status"] ?? "pending",

      notes: map["notes"] ?? "",

      approvedBy: map["approvedBy"] ?? "",

      approvedAt: map["approvedAt"] != null
          ? DateTime.tryParse(
        map["approvedAt"].toString(),
      )
          : null,

      rejectedBy: map["rejectedBy"] ?? "",

      rejectReason: map["rejectReason"] ?? "",

      received: map["received"] ?? false,

      deliveredAt: map["deliveredAt"] != null
          ? DateTime.tryParse(
        map["deliveredAt"].toString(),
      )
          : null,

      updatedAt: map["updatedAt"] != null
          ? DateTime.tryParse(
        map["updatedAt"].toString(),
      )
          : null,

      createdAt: DateTime.tryParse(
        map["createdAt"] ?? "",
      ) ??
          DateTime.now(),

      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> itemsMap = {};

    for (final item in items) {
      itemsMap[item.id] = item.toMap();
    }

    return {
      "stationId": stationId,

      "stationName": stationName,

      "managerId": managerId,

      "status": status,

      "notes": notes,

      "approvedBy": approvedBy,

      "approvedAt":
      approvedAt?.toIso8601String(),

      "rejectedBy": rejectedBy,

      "rejectReason": rejectReason,

      "received": received,

      "deliveredAt":
      deliveredAt?.toIso8601String(),

      "updatedAt":
      updatedAt?.toIso8601String(),

      "createdAt":
      createdAt.toIso8601String(),

      "items": itemsMap,
    };
  }

  RequestModel copyWith({
    String? id,
    String? stationId,
    String? stationName,
    String? managerId,
    String? status,
    String? notes,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectedBy,
    String? rejectReason,
    bool? received,
    DateTime? deliveredAt,
    DateTime? updatedAt,
    DateTime? createdAt,
    List<RequestItem>? items,
  }) {
    return RequestModel(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      managerId: managerId ?? this.managerId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      approvedBy:
      approvedBy ?? this.approvedBy,
      approvedAt:
      approvedAt ?? this.approvedAt,
      rejectedBy:
      rejectedBy ?? this.rejectedBy,
      rejectReason:
      rejectReason ??
          this.rejectReason,
      received:
      received ?? this.received,
      deliveredAt:
      deliveredAt ??
          this.deliveredAt,
      updatedAt:
      updatedAt ??
          this.updatedAt,
      createdAt:
      createdAt ??
          this.createdAt,
      items: items ?? this.items,
    );
  }
}

class RequestItem {
  final String id;

  final String productName;

  final double currentQuantity;

  final double requestedQuantity;

  final double approvedQuantity;

  const RequestItem({
    required this.id,
    required this.productName,
    required this.currentQuantity,
    required this.requestedQuantity,
    required this.approvedQuantity,
  });

  factory RequestItem.fromMap(
      String id,
      Map<dynamic, dynamic> map,
      ) {
    return RequestItem(
      id: id,

      productName:
      map["productName"] ?? "",

      currentQuantity:
      (map["currentQuantity"] ?? 0)
          .toDouble(),

      requestedQuantity:
      (map["requestedQuantity"] ?? 0)
          .toDouble(),

      approvedQuantity:
      (map["approvedQuantity"] ?? 0)
          .toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "productName": productName,

      "currentQuantity":
      currentQuantity,

      "requestedQuantity":
      requestedQuantity,

      "approvedQuantity":
      approvedQuantity,
    };
  }

  RequestItem copyWith({
    String? id,
    String? productName,
    double? currentQuantity,
    double? requestedQuantity,
    double? approvedQuantity,
  }) {
    return RequestItem(
      id: id ?? this.id,
      productName:
      productName ??
          this.productName,
      currentQuantity:
      currentQuantity ??
          this.currentQuantity,
      requestedQuantity:
      requestedQuantity ??
          this.requestedQuantity,
      approvedQuantity:
      approvedQuantity ??
          this.approvedQuantity,
    );
  }
}