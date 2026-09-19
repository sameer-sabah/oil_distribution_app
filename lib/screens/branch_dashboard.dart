import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/station_service.dart';
import '../services/internal_message_service.dart';

import 'pending_stations_screen.dart';
import 'branch/branch_stations_screen.dart';
import 'notifications_screen.dart';
import 'reports_screen.dart';
import 'branch/users_screen.dart';
import 'branch/quantity_tracking_screen.dart';
import 'internal_messages_screen.dart';
import 'oil_coupon/branch_coupon_management_screen.dart';
import 'oil_coupon/vehicle_login_screen.dart';

class BranchDashboard extends StatefulWidget {
  const BranchDashboard({
    super.key,
  });

  @override
  State<BranchDashboard> createState() =>
      _BranchDashboardState();
}

class _BranchDashboardState
    extends State<BranchDashboard> {
  final AuthService auth =
      AuthService.instance;

  final StationService stationService =
      StationService.instance;

  final InternalMessageService
  internalMessageService =
      InternalMessageService.instance;

  List stations = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStations();
  }

  Future<void> loadStations() async {
    final user =
        auth.currentUser;

    if (user == null) {
      return;
    }

    stations =
    await stationService.getBranchStations(
      user.branchId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _logout() async {
    final confirm =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
          const Text(
            "تسجيل الخروج",
          ),
          content:
          const Text(
            "هل أنت متأكد من أنك تريد تسجيل الخروج؟",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
              const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
              const Text(
                "تسجيل الخروج",
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await auth.signOut();

    if (!mounted) {
      return;
    }

    Navigator.of(context)
        .pushNamedAndRemoveUntil(
      "/login",
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user =
        auth.currentUser;

    final width =
        MediaQuery.sizeOf(context).width;

    final cardRatio =
    width < 380
        ? 0.88
        : 0.94;

    return Scaffold(
      backgroundColor:
      const Color(0xFFF4F7FB),

      body:
      SafeArea(
        child:
        RefreshIndicator(
          onRefresh:
          loadStations,

          child:
          CustomScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),

            slivers: [

              SliverToBoxAdapter(
                child:
                _header(
                  branchName:
                  user?.branchName ?? "",
                  managerName:
                  user?.fullName ?? "",
                  phone:
                  user?.phone ?? "",
                ),
              ),

              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  14,
                  16,
                  14,
                  12,
                ),

                sliver:
                SliverGrid(
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                    2,
                    crossAxisSpacing:
                    12,
                    mainAxisSpacing:
                    12,
                    childAspectRatio:
                    cardRatio,
                  ),

                  delegate:
                  SliverChildListDelegate(
                    [

                      _dashboardTile(
                        title:
                        "إدارة الكوبون النفطي والحصص",
                        subtitle:
                        "تحديد الحصة والمدة وتعميمها على المنافذ",
                        icon:
                        Icons.confirmation_number_rounded,
                        accent:
                        const Color(0xFFB64F00),
                        statusIcon:
                        Icons.verified_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const BranchCouponManagementScreen(),
                            ),
                          );
                        },
                      ),

                      _dashboardTile(
                        title:
                        "تسجيل ودخول السيارات الحكومية",
                        subtitle:
                        "استمارة وصفحة دخول السيارات الحكومية وربط شرائح NFC",
                        icon:
                        Icons.admin_panel_settings_rounded,
                        accent:
                        const Color(0xFF0F766E),
                        statusIcon:
                        Icons.directions_car_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const VehicleLoginScreen(isGovernment: true),
                            ),
                          );
                        },
                      ),

                      // ===============================================
                      // إدارة المحطات
                      // الأمر الأصلي: BranchStationsScreen(branchId)
                      // ===============================================

                      _dashboardTile(
                        title:
                        "إدارة المحطات",
                        subtitle:
                        loading
                            ? "جارٍ تحميل المحطات..."
                            : "${stations.length} محطة في الفرع",
                        icon:
                        Icons.local_gas_station_rounded,
                        accent:
                        const Color(0xFF084F9C),
                        statusIcon:
                        Icons.check_circle_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BranchStationsScreen(
                                    branchId:
                                    user?.branchId ?? "",
                                  ),
                            ),
                          );
                        },
                      ),

                      // ===============================================
                      // طلبات تسجيل المحطات
                      // الأمر الأصلي محفوظ
                      // ===============================================

                      _dashboardTile(
                        title:
                        "طلبات تسجيل المحطات",
                        subtitle:
                        "مراجعة طلبات التسجيل الجديدة",
                        icon:
                        Icons.add_business_rounded,
                        accent:
                        const Color(0xFF00695C),
                        statusIcon:
                        Icons.verified_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const PendingStationsScreen(),
                            ),
                          );
                        },
                      ),

                      // ===============================================
                      // متابعة الكميات
                      // الأمر الأصلي محفوظ
                      // ===============================================

                      _dashboardTile(
                        title:
                        "متابعة الكميات",
                        subtitle:
                        "متابعة منتجات محطات الفرع",
                        icon:
                        Icons.inventory_2_rounded,
                        accent:
                        const Color(0xFF512DA8),
                        statusIcon:
                        Icons.track_changes_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const QuantityTrackingScreen(),
                            ),
                          );
                        },
                      ),

                      // ===============================================
                      // المراسلات الداخلية + العداد
                      // ===============================================

                      StreamBuilder<int>(
                        stream:
                        internalMessageService
                            .unreadCountStream(),

                        builder:
                            (context, snapshot) {
                          final int count =
                              snapshot.data ?? 0;

                          return _dashboardTile(
                            title:
                            "المراسلات الداخلية",
                            subtitle:
                            count > 0
                                ? "$count رسالة غير مقروءة"
                                : "مراسلات مدير الفرع",
                            icon:
                            Icons.mark_email_unread_rounded,
                            accent:
                            const Color(0xFF183A8F),
                            statusIcon:
                            count > 0
                                ? Icons.mark_email_unread_rounded
                                : Icons.check_circle_rounded,
                            badge:
                            count,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const InternalMessagesScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // ===============================================
                      // الإشعارات
                      // الأمر الأصلي + userId محفوظ
                      // ===============================================

                      _dashboardTile(
                        title:
                        "الإشعارات",
                        subtitle:
                        "إرسال ومتابعة إشعارات الفرع",
                        icon:
                        Icons.notifications_active_rounded,
                        accent:
                        const Color(0xFFB85B00),
                        statusIcon:
                        Icons.campaign_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  NotificationsScreen(
                                    userId:
                                    auth.currentUser!.id,
                                  ),
                            ),
                          );
                        },
                      ),

                      // ===============================================
                      // التقارير
                      // ===============================================

                      _dashboardTile(
                        title:
                        "التقارير",
                        subtitle:
                        "تقارير وإحصائيات الفرع",
                        icon:
                        Icons.bar_chart_rounded,
                        accent:
                        const Color(0xFF0B4F82),
                        statusIcon:
                        Icons.trending_up_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const ReportsScreen(),
                            ),
                          );
                        },
                      ),

                      // ===============================================
                      // المستخدمون
                      // ===============================================

                      _dashboardTile(
                        title:
                        "المستخدمون",
                        subtitle:
                        "إدارة مستخدمي الفرع",
                        icon:
                        Icons.people_alt_rounded,
                        accent:
                        const Color(0xFF145A54),
                        statusIcon:
                        Icons.manage_accounts_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const UsersScreen(),
                            ),
                          );
                        },
                      ),

                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child:
                SizedBox(
                  height:
                  24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header({
    required String branchName,
    required String managerName,
    required String phone,
  }) {
    return Container(
      width:
      double.infinity,

      margin:
      const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        0,
      ),

      padding:
      const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        22,
      ),

      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(
          28,
        ),
        image:
        const DecorationImage(
          image:
          AssetImage(
            "assets/images/branch_manager_oil_facility.png",
          ),
          fit:
          BoxFit.cover,
          alignment:
          Alignment.center,
        ),
        boxShadow: [
          BoxShadow(
            color:
            const Color(0xFF053466)
                .withValues(
              alpha:
              .24,
            ),
            blurRadius:
            22,
            offset:
            const Offset(
              0,
              9,
            ),
          ),
        ],
      ),

      child:
      Stack(
        children: [

          Positioned.fill(
            child:
            Container(
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  28,
                ),
                gradient:
                LinearGradient(
                  begin:
                  Alignment.topRight,
                  end:
                  Alignment.bottomLeft,
                  colors: [
                    const Color(0xFF022F5B)
                        .withValues(alpha: .88),
                    const Color(0xFF064C7D)
                        .withValues(alpha: .76),
                    const Color(0xFF00695C)
                        .withValues(alpha: .62),
                  ],
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [

              Row(
                children: [

                  Container(
                    width:
                    48,
                    height:
                    48,
                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white
                          .withValues(
                        alpha:
                        .13,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                    child:
                    const Icon(
                      Icons.account_tree_rounded,
                      color:
                      Colors.white,
                      size:
                      27,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    tooltip:
                    "تسجيل الخروج",
                    onPressed:
                    _logout,
                    icon:
                    const Icon(
                      Icons.logout_rounded,
                      color:
                      Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                10,
              ),

              const Text(
                "لوحة مدير الفرع",
                textAlign:
                TextAlign.right,
                style:
                TextStyle(
                  color:
                  Colors.white,
                  fontSize:
                  28,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(
                height:
                5,
              ),

              Text(
                branchName.trim().isEmpty
                    ? "الفرع"
                    : branchName,
                textAlign:
                TextAlign.right,
                maxLines:
                1,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  color:
                  Color(0xFFD9F5F1),
                  fontSize:
                  17,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              if (managerName.trim().isNotEmpty ||
                  phone.trim().isNotEmpty) ...[
                const SizedBox(
                  height:
                  10,
                ),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal:
                    12,
                    vertical:
                    9,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white
                        .withValues(
                      alpha:
                      .10,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),
                  child:
                  Row(
                    children: [

                      const Icon(
                        Icons.person_rounded,
                        color:
                        Color(0xFF75DDD3),
                        size:
                        20,
                      ),

                      const SizedBox(
                        width:
                        7,
                      ),

                      Expanded(
                        child:
                        Text(
                          [
                            if (managerName
                                .trim()
                                .isNotEmpty)
                              managerName.trim(),
                            if (phone
                                .trim()
                                .isNotEmpty)
                              phone.trim(),
                          ].join(" • "),
                          maxLines:
                          1,
                          overflow:
                          TextOverflow.ellipsis,
                          style:
                          const TextStyle(
                            color:
                            Colors.white,
                            fontSize:
                            12.5,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),

                      if (!loading) ...[
                        const SizedBox(
                          width:
                          8,
                        ),
                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal:
                            9,
                            vertical:
                            5,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            Colors.white
                                .withValues(
                              alpha:
                              .12,
                            ),
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                          child:
                          Text(
                            "${stations.length} محطة",
                            style:
                            const TextStyle(
                              color:
                              Colors.white,
                              fontSize:
                              11.5,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _dashboardTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required IconData statusIcon,
    int badge = 0,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
      Colors.transparent,

      child:
      InkWell(
        onTap:
        onTap,

        borderRadius:
        BorderRadius.circular(
          23,
        ),

        child:
        Ink(
          decoration:
          BoxDecoration(
            color:
            Colors.white,

            borderRadius:
            BorderRadius.circular(
              23,
            ),

            border:
            Border.all(
              color:
              accent.withValues(
                alpha:
                .14,
              ),
              width:
              1.2,
            ),

            boxShadow: [
              BoxShadow(
                color:
                const Color(0xFF173B5B)
                    .withValues(
                  alpha:
                  .10,
                ),
                blurRadius:
                16,
                offset:
                const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),

          child:
          Stack(
            children: [

              if (badge > 0)
                Positioned(
                  top:
                  10,
                  left:
                  10,
                  child:
                  Container(
                    constraints:
                    const BoxConstraints(
                      minWidth:
                      28,
                      minHeight:
                      28,
                    ),
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal:
                      7,
                      vertical:
                      4,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(0xFFC62828),
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                    alignment:
                    Alignment.center,
                    child:
                    Text(
                      badge > 99
                          ? "99+"
                          : "$badge",
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize:
                        11,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),

                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        Container(
                          width:
                          34,
                          height:
                          34,
                          decoration:
                          BoxDecoration(
                            color:
                            accent
                                .withValues(
                              alpha:
                              .13,
                            ),
                            shape:
                            BoxShape.circle,
                          ),
                          child:
                          Icon(
                            statusIcon,
                            color:
                            accent,
                            size:
                            20,
                          ),
                        ),

                        Container(
                          width:
                          50,
                          height:
                          50,
                          decoration:
                          BoxDecoration(
                            color:
                            accent
                                .withValues(
                              alpha:
                              .13,
                            ),
                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),
                          ),
                          child:
                          Icon(
                            icon,
                            color:
                            accent,
                            size:
                            28,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Text(
                      title,
                      textAlign:
                      TextAlign.right,
                      maxLines:
                      3,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      const TextStyle(
                        color:
                        Color(0xFF102A43),
                        fontSize:
                        14,
                        height:
                        1.2,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height:
                      4,
                    ),

                    Text(
                      subtitle,
                      textAlign:
                      TextAlign.right,
                      maxLines:
                      1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      const TextStyle(
                        color:
                        Color(0xFF52667A),
                        fontSize:
                        10.5,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height:
                      6,
                    ),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: [

                        Text(
                          "فتح",
                          style:
                          TextStyle(
                            color:
                            accent,
                            fontSize:
                            11.5,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),

                        const SizedBox(
                          width:
                          4,
                        ),

                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size:
                          12,
                          color:
                          accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
