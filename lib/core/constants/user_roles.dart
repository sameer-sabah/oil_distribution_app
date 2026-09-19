class UserRoles {
  UserRoles._();

  static const String admin = "admin";
  static const String branchManager = "branchManager";
  static const String distributionManager = "distributionManager";
  static const String stationManager = "stationManager";

  static const String legacyDistributionManager =
      "distribution_manager";
  static const String legacyStationManager =
      "station_manager";

  static const List<String> all = [
    admin,
    branchManager,
    distributionManager,
    stationManager,
  ];

  static String normalize(String role) {
    final value = role.trim();

    switch (value) {
      case legacyStationManager:
        return stationManager;
      case legacyDistributionManager:
        return distributionManager;
      default:
        return value;
    }
  }

  static bool isAdmin(String? role) =>
      normalize(role ?? "") == admin;

  static bool isBranchManager(String? role) =>
      normalize(role ?? "") == branchManager;

  static bool isStationManager(String? role) =>
      normalize(role ?? "") == stationManager;

  static bool isDistributionManager(String? role) =>
      normalize(role ?? "") == distributionManager;

  static String getName(String role) {
    switch (normalize(role)) {
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
