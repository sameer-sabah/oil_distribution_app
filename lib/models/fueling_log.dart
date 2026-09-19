class FuelingLog {
  final String id;
  final String vehicleId;
  final String plateNumber;
  final String stationId;
  final String stationName;
  final String outletNumber;
  final String employeeUid;
  final String employeeName;
  final String fuelType;
  final double quantity;
  final String createdAt;

  const FuelingLog({
    required this.id,
    required this.vehicleId,
    required this.plateNumber,
    required this.stationId,
    required this.stationName,
    required this.outletNumber,
    required this.employeeUid,
    required this.employeeName,
    required this.fuelType,
    required this.quantity,
    required this.createdAt,
  });

  factory FuelingLog.fromMap(String id, Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    return FuelingLog(
      id: id,
      vehicleId: map['vehicleId']?.toString() ?? '',
      plateNumber: map['plateNumber']?.toString() ?? '',
      stationId: map['stationId']?.toString() ?? '',
      stationName: map['stationName']?.toString() ?? '',
      outletNumber: map['outletNumber']?.toString() ?? '',
      employeeUid: map['employeeUid']?.toString() ?? '',
      employeeName: map['employeeName']?.toString() ?? '',
      fuelType: map['fuelType']?.toString() ?? '',
      quantity: double.tryParse(map['quantity']?.toString() ?? '0') ?? 0.0,
      createdAt: map['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'plateNumber': plateNumber,
      'stationId': stationId,
      'stationName': stationName,
      'outletNumber': outletNumber,
      'employeeUid': employeeUid,
      'employeeName': employeeName,
      'fuelType': fuelType,
      'quantity': quantity,
      'createdAt': createdAt,
    };
  }
}
