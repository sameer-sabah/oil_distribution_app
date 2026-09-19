import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../services/commercial_conversation_service.dart';
import '../services/internal_message_service.dart';

import 'admin/branches_screen.dart';
import 'admin/commercial_payment_settings_screen.dart';
import 'admin/payment_methods_screen.dart';
import 'admin/user_wallets_screen.dart';
import 'admin/contact_messages_screen.dart';
import 'admin/ratings_screen.dart';
import 'admin/users_screen.dart';
import 'internal_messages_screen.dart';
import 'notifications_screen.dart';
import 'products_screen.dart';
import 'reports_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({
    super.key,
  });

  @override
  State<AdminScreen> createState() =>
      _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final InternalMessageService internalMessageService =
      InternalMessageService.instance;

  bool ratingsNotificationSeen = false;

  late final Stream<int> _adminUnreadCountStream;
  late final Stream<int> _commercialUnreadCountStream;
  late final Stream<int> _stationsCountStream;
  late final Stream<int> _branchesCountStream;
  late final Stream<int> _usersCountStream;

  @override
  void initState() {
    super.initState();

    // مهم:
    // unreadCountStream() قد يكون Single-Subscription.
    // شاشة مدير النظام تعرض عداد المراسلات في أكثر من مكان،
    // لذلك ننشئ Stream واحد فقط ونحوّله إلى Broadcast.
    _adminUnreadCountStream =
        internalMessageService
            .unreadCountStream()
            .asBroadcastStream();

    _commercialUnreadCountStream =
        CommercialConversationService.instance
            .adminUnreadCountStream()
            .asBroadcastStream();

    _stationsCountStream = FirebaseDatabase.instance
        .ref('stations')
        .onValue
        .map((event) => event.snapshot.children.length)
        .asBroadcastStream();

    _branchesCountStream = FirebaseDatabase.instance
        .ref('branches')
        .onValue
        .map((event) => event.snapshot.children.length)
        .asBroadcastStream();

    _usersCountStream = FirebaseDatabase.instance
        .ref('users')
        .onValue
        .map((event) => event.snapshot.children.length)
        .asBroadcastStream();
  }

  int _countNewMessages(Object? value) {
    if (value == null || value is! Map) {
      return 0;
    }

    int count = 0;

    final data =
    Map<dynamic, dynamic>.from(value);

    for (final entry in data.entries) {
      final item =
          entry.value;

      if (item is Map &&
          item['status']?.toString() == 'new') {
        count++;
      }
    }

    return count;
  }

  int _countRatings(Object? value) {
    if (value == null || value is! Map) {
      return 0;
    }

    return Map<dynamic, dynamic>
        .from(value)
        .length;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F8FC),

      body:
      SafeArea(
        child:
        RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },

          child:
          CustomScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),

            slivers: [
              SliverToBoxAdapter(
                child:
                _heroHeader(),
              ),

              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  14,
                  16,
                  14,
                  8,
                ),

                sliver:
                SliverToBoxAdapter(
                  child:
                  _summaryGrid(),
                ),
              ),

              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  14,
                  4,
                  14,
                  8,
                ),

                sliver:
                SliverToBoxAdapter(
                  child:
                  _sectionTitle(
                    'إدارة النظام',
                    Icons.dashboard_customize_rounded,
                  ),
                ),
              ),

              SliverPadding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 14,
                ),

                sliver:
                SliverGrid(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),

                  delegate:
                  SliverChildListDelegate(
                    [
                      _adminTile(
                        title: 'إدارة الفروع',
                        subtitle: 'إضافة وتعديل الفروع ومديريها',
                        icon: Icons.account_tree_rounded,
                        accent: const Color(0xFF0A4F9E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const BranchesScreen(),
                            ),
                          );
                        },
                      ),

                      _adminTile(
                        title: 'إدارة المستخدمين',
                        subtitle: 'الحسابات والصلاحيات',
                        icon: Icons.manage_accounts_rounded,
                        accent: const Color(0xFF45278F),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UsersScreen(),
                            ),
                          );
                        },
                      ),

                      _adminTile(
                        title: 'إدارة المنتجات',
                        subtitle: 'إضافة وتعديل المنتجات',
                        icon: Icons.inventory_2_rounded,
                        accent: const Color(0xFF005C52),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const ProductsScreen(),
                            ),
                          );
                        },
                      ),

                      _adminTile(
                        title: 'التقارير',
                        subtitle: 'الإحصائيات والتقارير',
                        icon: Icons.bar_chart_rounded,
                        accent: const Color(0xFF063B63),
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

                      _adminTile(
                        title: 'حسابات المعلنين',
                        subtitle: 'بيانات المعلنين والتفعيل والتواصل',
                        icon: Icons.storefront_rounded,
                        accent: const Color(0xFF6A3D00),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/advertiserAccountsAdmin',
                          );
                        },
                      ),

                      StreamBuilder<int>(
                        stream: _commercialUnreadCountStream,
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;

                          return _adminTile(
                            title: 'محادثات المعلنين',
                            subtitle: count > 0
                                ? '$count رسالة جديدة من المعلنين'
                                : 'الموافقات والأسعار والأمور المالية',
                            icon: Icons.forum_rounded,
                            accent: const Color(0xFF234E52),
                            badge: count,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/commercialConversationsAdmin',
                              );
                            },
                          );
                        },
                      ),

                      _adminTile(
                        title: 'مدفوعات الإعلانات',
                        subtitle: 'مراجعة عمليات الدفع',
                        icon: Icons.receipt_long_rounded,
                        accent: const Color(0xFF084A66),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/commercialPaymentsAdmin',
                          );
                        },
                      ),

                      _adminTile(
                        title: 'محافظ المستخدمين وطلبات الشحن',
                        subtitle: 'مراجعة طلبات شحن المحافظ والرصيد',
                        icon: Icons.account_balance_wallet_rounded,
                        accent: const Color(0xFF004D43),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const UserWalletsScreen(),
                            ),
                          );
                        },
                      ),

                      _adminTile(
                        title: 'وسائل الدفع',
                        subtitle: 'إدارة حسابات وأرقام طرق الدفع',
                        icon: Icons.payment_rounded,
                        accent: const Color(0xFF0B5345),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const PaymentMethodsScreen(),
                            ),
                          );
                        },
                      ),

                      _adminTile(
                        title: 'إعدادات زين كاش',
                        subtitle: 'السعر وحالة ربط الدفع',
                        icon: Icons.settings_applications_rounded,
                        accent: const Color(0xFF004D43),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const CommercialPaymentSettingsScreen(),
                            ),
                          );
                        },
                      ),

                      StreamBuilder<int>(
                        stream:
                        _adminUnreadCountStream,

                        builder: (context, snapshot) {
                          final count =
                              snapshot.data ?? 0;

                          return _adminTile(
                            title: 'المراسلات الداخلية',
                            subtitle: count > 0
                                ? '$count رسالة غير مقروءة'
                                : 'مراسلات مدير النظام ومديري الفروع',
                            icon: Icons.mark_email_unread_rounded,
                            accent: const Color(0xFF102F6D),
                            badge: count,
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
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  14,
                  18,
                  14,
                  8,
                ),

                sliver:
                SliverToBoxAdapter(
                  child:
                  _sectionTitle(
                    'تنبيهات النظام',
                    Icons.notifications_active_rounded,
                  ),
                ),
              ),

              SliverPadding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 14,
                ),

                sliver:
                SliverToBoxAdapter(
                  child:
                  _alertsPanel(),
                ),
              ),



              SliverToBoxAdapter(
                child:
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    14,
                    18,
                    14,
                    24,
                  ),

                  child:
                  FilledButton.icon(
                    style:
                    FilledButton.styleFrom(
                      minimumSize:
                      const Size.fromHeight(52),
                      backgroundColor:
                      const Color(0xFF0A396D),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                      ),
                    ),

                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                            (route) => false,
                      );
                    },

                    icon:
                    const Icon(
                      Icons.logout_rounded,
                    ),

                    label:
                    const Text(
                      'تسجيل الخروج',
                      style:
                      TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroHeader() {
    return Container(
      margin:
      const EdgeInsets.all(12),

      height: 240,

      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(24),

        image:
        const DecorationImage(
          image:
          AssetImage(
            'assets/images/admin_refinery_header.png',
          ),
          fit:
          BoxFit.cover,
          alignment: Alignment.center,
        ),

        boxShadow: [
          BoxShadow(
            color:
            const Color(0xFF042E59)
                .withValues(alpha: .22),
            blurRadius: 24,
            offset:
            const Offset(0, 10),
          ),
        ],
      ),

      child:
      ClipRRect(
        borderRadius:
        BorderRadius.circular(30),

        child:
        Container(
          padding:
          const EdgeInsets.all(20),

          decoration:
          BoxDecoration(
            gradient:
            LinearGradient(
              begin:
              Alignment.topRight,
              end:
              Alignment.bottomLeft,
              colors: [
                const Color(0xFF032C57)
                    .withValues(alpha: .92),
                const Color(0xFF074D87)
                    .withValues(alpha: .68),
                Colors.transparent,
              ],
            ),
          ),

          child:
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,

            children: [
              Row(
                children: [
                  StreamBuilder<DatabaseEvent>(
                    stream: FirebaseDatabase.instance.ref("notifications").onValue,
                    builder: (context, snapshot) {
                      int unreadCount = 0;
                      if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
                        final val = snapshot.data!.snapshot.value;
                        if (val is Map) {
                          val.forEach((key, item) {
                            if (item is Map) {
                              final map = Map<String, dynamic>.from(item);
                              if (map["read"] != true) {
                                unreadCount++;
                              }
                            }
                          });
                        }
                      }
                      return _headerAction(
                        icon: Icons.notifications_none_rounded,
                        badge: unreadCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(userId: 'admin'),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(width: 8),

                  StreamBuilder<int>(
                    stream:
                    _adminUnreadCountStream,
                    builder: (context, snapshot) {
                      return _headerAction(
                        icon:
                        Icons.mail_outline_rounded,
                        badge:
                        snapshot.data ?? 0,
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

                  const Spacer(),

                  Container(
                    width: 54,
                    height: 54,
                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white
                          .withValues(alpha: .14),
                      shape:
                      BoxShape.circle,
                      border:
                      Border.all(
                        color:
                        Colors.white
                            .withValues(alpha: .24),
                      ),
                    ),
                    child:
                    const Icon(
                      Icons.admin_panel_settings_rounded,
                      color:
                      Colors.white,
                      size: 31,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              const Text(
                'مرحباً بك',
                textAlign:
                TextAlign.right,
                style:
                TextStyle(
                  color:
                  Colors.white70,
                  fontSize: 17,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'مدير النظام',
                textAlign:
                TextAlign.right,
                style:
                TextStyle(
                  color:
                  Colors.white,
                  fontSize: 34,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'يمكنك من هنا إدارة بيانات النظام ومتابعة الفروع والمحطات والمستخدمين',
                textAlign:
                TextAlign.right,
                style:
                TextStyle(
                  color:
                  Colors.white
                      .withValues(alpha: .84),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerAction({
    required IconData icon,
    required int badge,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior:
      Clip.none,

      children: [
        InkWell(
          borderRadius:
          BorderRadius.circular(18),
          onTap:
          onTap,
          child:
          Container(
            width: 46,
            height: 46,
            decoration:
            BoxDecoration(
              color:
              Colors.white
                  .withValues(alpha: .12),
              borderRadius:
              BorderRadius.circular(16),
              border:
              Border.all(
                color:
                Colors.white
                    .withValues(alpha: .18),
              ),
            ),
            child:
            Icon(
              icon,
              color:
              Colors.white,
              size: 24,
            ),
          ),
        ),

        if (badge > 0)
          Positioned(
            top: -4,
            right: -4,
            child:
            Container(
              constraints:
              const BoxConstraints(
                minWidth: 21,
                minHeight: 21,
              ),
              padding:
              const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(0xFFE43B3B),
                borderRadius:
                BorderRadius.circular(20),
              ),
              alignment:
              Alignment.center,
              child:
              Text(
                badge > 99
                    ? '99+'
                    : '$badge',
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 9.5,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _summaryGrid() {
    return StreamBuilder<int>(
      stream: _stationsCountStream,
      initialData: 0,
      builder: (context, stationsSnapshot) {
        return StreamBuilder<int>(
          stream: _branchesCountStream,
          initialData: 0,
          builder: (context, branchesSnapshot) {
            return StreamBuilder<int>(
              stream: _usersCountStream,
              initialData: 0,
              builder: (context, usersSnapshot) {
                return Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        'المحطات',
                        stationsSnapshot.data ?? 0,
                        'محطة',
                        Icons.local_gas_station_rounded,
                        const Color(0xFFB64F00),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _summaryCard(
                        'الفروع',
                        branchesSnapshot.data ?? 0,
                        'فرع',
                        Icons.apartment_rounded,
                        const Color(0xFF0A4F9E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _summaryCard(
                        'المستخدمين',
                        usersSnapshot.data ?? 0,
                        'مستخدم',
                        Icons.groups_rounded,
                        const Color(0xFF47288D),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _summaryCard(
      String title,
      int value,
      String footer,
      IconData icon,
      Color accent,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(14),

      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border:
        Border.all(
          color:
          accent.withValues(alpha: .09),
        ),
        boxShadow: [
          BoxShadow(
            color:
            const Color(0xFF173B5B)
                .withValues(alpha: .07),
            blurRadius: 14,
            offset:
            const Offset(0, 6),
          ),
        ],
      ),

      child:
      Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
            BoxDecoration(
              color:
              accent.withValues(alpha: .11),
              shape:
              BoxShape.circle,
            ),
            child:
            Icon(
              icon,
              color:
              accent,
              size: 27,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child:
            Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Color(0xFF52677B),
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$value',
                  style:
                  const TextStyle(
                    color:
                    Color(0xFF102A43),
                    fontSize: 24,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                Text(
                  footer,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Color(0xFF75879A),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color:
          const Color(0xFF07477F),
          size: 21,
        ),
        const Spacer(),
        Text(
          title,
          style:
          const TextStyle(
            color:
            Color(0xFF102A43),
            fontSize: 18,
            fontWeight:
            FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _adminTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    int badge = 0,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
      Colors.transparent,

      child:
      InkWell(
        borderRadius:
        BorderRadius.circular(22),
        onTap:
        onTap,

        child:
        Ink(
          padding:
          const EdgeInsets.all(10),

          decoration:
          BoxDecoration(
            color:
            Colors.white,
            borderRadius:
            BorderRadius.circular(22),
            border:
            Border.all(
              color:
              accent.withValues(alpha: .10),
            ),
            boxShadow: [
              BoxShadow(
                color:
                const Color(0xFF173B5B)
                    .withValues(alpha: .07),
                blurRadius: 14,
                offset:
                const Offset(0, 6),
              ),
            ],
          ),

          child:
          Stack(
            children: [
              if (badge > 0)
                Positioned(
                  top: 0,
                  left: 0,
                  child:
                  Container(
                    constraints:
                    const BoxConstraints(
                      minWidth: 25,
                      minHeight: 25,
                    ),
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(0xFFE43B3B),
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    alignment:
                    Alignment.center,
                    child:
                    Text(
                      badge > 99
                          ? '99+'
                          : '$badge',
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment:
                    Alignment.topRight,
                    child:
                    Container(
                      width: 38,
                      height: 38,
                      decoration:
                      BoxDecoration(
                        color:
                        accent.withValues(alpha: .11),
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child:
                      Icon(
                        icon,
                        color:
                        accent,
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    title,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    textAlign:
                    TextAlign.right,
                    style:
                    const TextStyle(
                      color:
                      Color(0xFF102A43),
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    textAlign:
                    TextAlign.right,
                    style:
                    const TextStyle(
                      color:
                      Color(0xFF6D7E90),
                      fontSize: 9.5,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _alertsPanel() {
    return Column(
      children: [
        StreamBuilder<DatabaseEvent>(
          stream:
          FirebaseDatabase.instance
              .ref('contactMessages')
              .onValue,

          builder: (context, snapshot) {
            final count =
            _countNewMessages(
              snapshot.data
                  ?.snapshot
                  .value,
            );

            return _alertTile(
              title:
              'رسائل التواصل',
              subtitle:
              count > 0
                  ? '$count رسالة جديدة من المواطنين'
                  : 'لا توجد رسائل جديدة',
              icon:
              Icons.mark_email_unread_rounded,
              accent:
              const Color(0xFF0A4F9E),
              badge:
              count,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const ContactMessagesScreen(),
                  ),
                );
              },
            );
          },
        ),

        const SizedBox(height: 10),

        StreamBuilder<DatabaseEvent>(
          stream:
          FirebaseDatabase.instance
              .ref('appRatings')
              .onValue,

          builder: (context, snapshot) {
            final count =
            _countRatings(
              snapshot.data
                  ?.snapshot
                  .value,
            );

            final visibleCount =
            ratingsNotificationSeen
                ? 0
                : count;

            return _alertTile(
              title:
              'تقييمات المستخدمين',
              subtitle:
              visibleCount > 0
                  ? '$visibleCount تقييم متاح للمراجعة'
                  : 'عرض تقييمات وتعليقات المواطنين',
              icon:
              Icons.star_rate_rounded,
              accent:
              const Color(0xFF8A4300),
              badge:
              visibleCount,
              onTap: () {
                setState(() {
                  ratingsNotificationSeen =
                  true;
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const RatingsScreen(),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _alertTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required int badge,
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
        BorderRadius.circular(18),

        child:
        Ink(
          padding:
          const EdgeInsets.all(14),

          decoration:
          BoxDecoration(
            color:
            Colors.white,
            borderRadius:
            BorderRadius.circular(18),
            border:
            Border.all(
              color:
              const Color(0xFFE3EAF1),
            ),
          ),

          child:
          Row(
            children: [
              if (badge > 0)
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(0xFFE43B3B),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child:
                  Text(
                    '$badge',
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(width: 10),

              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style:
                      const TextStyle(
                        color:
                        Color(0xFF102A43),
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      textAlign:
                      TextAlign.right,
                      style:
                      const TextStyle(
                        color:
                        Color(0xFF6D7E90),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Container(
                width: 44,
                height: 44,
                decoration:
                BoxDecoration(
                  color:
                  accent.withValues(alpha: .11),
                  shape:
                  BoxShape.circle,
                ),
                child:
                Icon(
                  icon,
                  color:
                  accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
