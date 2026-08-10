import 'package:firebase_database/firebase_database.dart';

class DashboardService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// عدد المستخدمين
  Future<int> getUsersCount() async {
    final snapshot = await _db.child("users").get();

    if (!snapshot.exists) return 0;

    final data = snapshot.value as Map<dynamic, dynamic>;

    return data.length;
  }

  /// عدد المحطات
  Future<int> getStationsCount() async {
    final snapshot = await _db.child("stations").get();

    if (!snapshot.exists) return 0;

    final data = snapshot.value as Map<dynamic, dynamic>;

    return data.length;
  }

  /// عدد المحطات النشطة
  Future<int> getActiveStationsCount() async {
    final snapshot = await _db.child("stations").get();

    if (!snapshot.exists) return 0;

    int count = 0;

    final data = snapshot.value as Map<dynamic, dynamic>;

    data.forEach((key, value) {
      if ((value["active"] ?? false) == true) {
        count++;
      }
    });

    return count;
  }

  /// عدد المحطات غير النشطة
  Future<int> getInactiveStationsCount() async {
    final snapshot = await _db.child("stations").get();

    if (!snapshot.exists) return 0;

    int count = 0;

    final data = snapshot.value as Map<dynamic, dynamic>;

    data.forEach((key, value) {
      if ((value["active"] ?? false) == false) {
        count++;
      }
    });

    return count;
  }

  /// عدد تحديثات المخزون
  Future<int> getStockHistoryCount() async {
    final snapshot = await _db.child("stock_history").get();

    if (!snapshot.exists) return 0;

    final data = snapshot.value as Map<dynamic, dynamic>;

    return data.length;
  }
}