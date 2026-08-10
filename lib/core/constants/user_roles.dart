class UserRoles {
  UserRoles._();

  static const String admin = "admin";
  static const String branchManager = "branchManager";
  static const String distributionManager = "distribution_manager";
  static const String stationManager = "station_manager";

  static const List<String> all = [
    admin,
    branchManager,
    distributionManager,
    stationManager,
  ];

  static String getName(String role) {
    switch (role) {
      case admin:
        return "مدير النظام";

      case branchManager:
        return "مدير الفرع";

      case distributionManager:
        return "مدير قسم التوزيع";

      case stationManager:
        return "مدير المحطة";

      default:
        return "غير معروف";
    }
  }
}