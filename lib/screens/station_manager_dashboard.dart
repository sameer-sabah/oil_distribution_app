import 'package:flutter/material.dart';
import '../models/station.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'dart:math' as math;
import 'notifications_screen.dart';
import 'internal_messages_screen.dart';
import 'oil_coupon/station_coupon_scanner_screen.dart';
import 'oil_coupon/link_nfc_chip_screen.dart';
import '../services/internal_message_service.dart';
class StationManagerDashboard extends StatefulWidget {
  final Station station;

  const StationManagerDashboard({
    super.key,
    required this.station,
  });

  @override
  State<StationManagerDashboard> createState() =>
      _StationManagerDashboardState();
}

class _StationManagerDashboardState
    extends State<StationManagerDashboard>
    with SingleTickerProviderStateMixin {
  final DatabaseService databaseService =
      DatabaseService.instance;
  final AuthService auth =
      AuthService.instance;
  final TextEditingController regularController = TextEditingController();
  final TextEditingController improvedController = TextEditingController();
  final TextEditingController dieselController = TextEditingController();
  final TextEditingController whiteOilController = TextEditingController();
  final TextEditingController superController = TextEditingController();

  final TextEditingController lpgController = TextEditingController();

  late bool stationOpen;
  late String currentWorkingStatus;
  late String currentCrowdStatus;

  // إضافات جديدة فقط: المنتجات المعتمدة + حركة المستطيل + المراسلات
  late AnimationController _productAnimationController;
  late Animation<double> _productScaleAnimation;
  late Animation<double> _productFadeAnimation;

  late Map<String, bool> supportedProducts;

  final InternalMessageService _messageService =
      InternalMessageService.instance;

  void _openLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      "/login",
          (route) => false,
    );
  }

  void _handleBack() {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    _openLogin();
  }

  @override
  void initState() {
    super.initState();

    regularController.text =
        widget.station.regular95.toString();

    improvedController.text =
        widget.station.improved95.toString();

    dieselController.text =
        widget.station.diesel.toString();

    whiteOilController.text =
        widget.station.whiteOil.toString();

    superController.text =
        widget.station.super95.toString();

    lpgController.text =
        widget.station.lpg.toString();


    stationOpen =
        widget.station.workingStatus == "مفتوحة" || widget.station.workingStatus.contains("خاف");

    currentWorkingStatus = widget.station.workingStatus.isNotEmpty
        ? widget.station.workingStatus
        : "مفتوحة";

    currentCrowdStatus = widget.station.crowdStatus.isNotEmpty
        ? widget.station.crowdStatus
        : "هادئة";

    supportedProducts =
    Map<String, bool>.from(
      widget.station.supportedProducts,
    );

    _productAnimationController =
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 3200),
        );

    _productScaleAnimation =
        CurvedAnimation(
          parent: _productAnimationController,
          curve: Curves.easeOutCubic,
        );

    _productFadeAnimation =
        CurvedAnimation(
          parent: _productAnimationController,
          curve: Curves.easeOut,
        );

    Future.delayed(
      Duration(milliseconds: 250),
          () {
        if (mounted) {
          _productAnimationController.forward();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _openLogin();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            tooltip: "رجوع",
            onPressed: _handleBack,
          ),

          title: Text(
            "مدير محطة ${widget.station.name}",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          centerTitle: true,

          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              tooltip: "مسح الكوبون النفطي",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StationCouponScannerScreen(
                      stationId: widget.station.id,
                      stationName: widget.station.name,
                    ),
                  ),
                );
              },
            ),
            // ✉️ المراسلات الداخلية
            StreamBuilder<int>(
              stream: _messageService.unreadCountStream(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mail_outline),
                      tooltip: "المراسلات الداخلية",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const InternalMessagesScreen(),
                          ),
                        );
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            count > 99 ? "99+" : count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            // 🔔 الإشعارات
            IconButton(
              icon: const Icon(
                Icons.notifications,
              ),
              tooltip: "الإشعارات",
              onPressed: () {
                final managerUid = widget.station.managerUid;

                if (managerUid.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "لا يوجد مسؤول مرتبط بهذه المحطة",
                      ),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(
                      userId: managerUid,
                    ),
                  ),
                );
              },
            ),

            // 🚪 تسجيل الخروج
            IconButton(
              icon: const Icon(
                Icons.logout,
              ),
              tooltip: "تسجيل الخروج",
              onPressed: () async {
                final confirm =
                await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        "تسجيل الخروج",
                      ),
                      content: const Text(
                        "هل تريد تسجيل الخروج من الحساب؟",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              false,
                            );
                          },
                          child: const Text(
                            "إلغاء",
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              true,
                            );
                          },
                          child: const Text(
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

                await auth.logout();

                if (!mounted) {
                  return;
                }
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                      (route) => false,
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Card(
              elevation: 4,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StationCouponScannerScreen(
                        stationId: widget.station.id,
                        stationName: widget.station.name,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.blue.shade800,
                        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مسح وتأكيد الكوبون النفطي (QR)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'انقر هنا لفتح الكاميرا وقراءة كوبون السيارة وتأكيد التزويد فوراً',
                              style: TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 4,
              color: Colors.teal.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LinkNfcChipScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.teal.shade700,
                        child: const Icon(Icons.nfc_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'استمارة ربط وتفعيل شريحة NFC للسيارات الحكومية',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'ربط أو برمجة شريحة NFC الذكية الجديدة بمركبة حكومية',
                              style: TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.teal),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "تحديث كميات الوقود",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 15),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // التاريخ - جهة اليسار
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDateOnly(widget.station.updatedAt),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      const Text(
                        "التاريخ",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // المضخة - الوسط
                const Icon(
                  Icons.local_gas_station,
                  size: 75,
                  color: Colors.blue,
                ),

                // الوقت - جهة اليمين
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatTimeOnly(widget.station.updatedAt),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      const Text(
                        "الوقت",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Text(
              "${widget.station.governorate} - ${widget.station.district}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            SizedBox(height: 25),
            // =====================================================
            // ⛽ المنتجات المعتمدة من مدير الفرع
            // إضافة فقط - لا نحذف أي حقل أصلي
            // =====================================================

            if (supportedProducts.values.any((value) => value)) ...[
              AnimatedBuilder(
                animation: _productAnimationController,
                builder: (context, child) {
                  final scale = _productScaleAnimation.value;
                  final fade = _productFadeAnimation.value;

                  final products = <Map<String, String>>[
                    {
                      "key": "regular95",
                      "name": "بنزين عادي",
                    },
                    {
                      "key": "improved95",
                      "name": "بنزين محسن",
                    },
                    {
                      "key": "super95",
                      "name": "بنزين سوبر",
                    },
                    {
                      "key": "diesel",
                      "name": "ديزل",
                    },
                    {
                      "key": "whiteOil",
                      "name": "نفط أبيض",
                    },
                    {
                      "key": "lpg",
                      "name": "غاز سائل",
                    },
                  ];

                  final selectedProducts = products;

                  return Opacity(
                    opacity: fade,
                    child: Transform.scale(
                      scale: 0.72 + (0.28 * scale),
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          bottom: 20,
                        ),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.white,
                              Colors.blue.shade50,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                              color: Colors.black.withValues(alpha: 0.12),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Center(
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                      begin: -0.04,
                                      end: 0.04,
                                    ),
                                    duration:
                                    Duration(seconds: 3),
                                    curve: Curves.easeInOut,
                                    builder: (context, value, _) {
                                      return Transform.rotate(
                                        angle: value,
                                        child: Opacity(
                                          opacity: 0.055,
                                          child: Icon(
                                            Icons.local_gas_station,
                                            size: 190,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            Column(
                              children: [
                                const Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_gas_station,
                                      size: 27,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "اختر المنتوج",
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16),

                                for (
                                int row = 0;
                                row < selectedProducts.length;
                                row += 2
                                )
                                  Padding(
                                    padding:
                                    EdgeInsets.only(
                                      bottom:
                                      row + 2 <
                                          selectedProducts.length
                                          ? 8
                                          : 0,
                                    ),
                                    child: Row(
                                      children: [
                                        for (
                                        int col = 0;
                                        col < 2;
                                        col++
                                        )
                                          Expanded(
                                            child:
                                            col + row <
                                                selectedProducts.length
                                                ? _approvedProductCard(
                                              selectedProducts[row + col]["name"]!,
                                              selectedProducts[row + col]["key"]!,
                                              row + col,
                                            )
                                                : SizedBox(),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],

            AnimatedSwitcher(
              duration: Duration(milliseconds: 700),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              child: supportedProducts["regular95"] == true
                  ? Padding(
                key: const ValueKey("regular95_visible"),
                padding: EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    TextField(
                      controller: regularController,
                      onTap: () {
                        if (regularController.text == "0") {
                          regularController.clear();
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "بنزين عادي (لتر)",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 15),
                  ],
                ),
              )
                  : SizedBox(
                key: const ValueKey("regular95_hidden"),
              ),
            ),



            AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              child: supportedProducts["improved95"] == true
                  ? Padding(
                key: const ValueKey("improved95_visible"),
                padding: EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    TextField(
                      controller: improvedController,
                      onTap: () {
                        if (improvedController.text == "0") {
                          improvedController.clear();
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "بنزين محسن (لتر)",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 15),
                  ],
                ),
              )
                  : SizedBox(
                key: const ValueKey("improved95_hidden"),
              ),
            ),



            AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              child: supportedProducts["diesel"] == true
                  ? Padding(
                key: const ValueKey("diesel_visible"),
                padding: EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    TextField(
                      controller: dieselController,
                      onTap: () {
                        if (dieselController.text == "0") {
                          dieselController.clear();
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "زيت الغاز (لتر)",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 15),
                  ],
                ),
              )
                  : SizedBox(
                key: const ValueKey("diesel_hidden"),
              ),
            ),



            AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              child: supportedProducts["whiteOil"] == true
                  ? Padding(
                key: const ValueKey("whiteOil_visible"),
                padding: EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    TextField(
                      controller: whiteOilController,
                      onTap: () {
                        if (whiteOilController.text == "0") {
                          whiteOilController.clear();
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "النفط الأبيض (لتر)",
                        border: OutlineInputBorder(),
                      ),
                    ),


                    SizedBox(height: 15),
                  ],
                ),
              )
                  : SizedBox(
                key: const ValueKey("whiteOil_hidden"),
              ),
            ),



            AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              child: supportedProducts["super95"] == true
                  ? Padding(
                key: const ValueKey("super95_visible"),
                padding: EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    TextField(
                      controller: superController,
                      onTap: () {
                        if (superController.text == "0") {
                          superController.clear();
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "بنزين سوبر (لتر)",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 15),
                  ],
                ),
              )
                  : SizedBox(
                key: const ValueKey("super95_hidden"),
              ),
            ),



            AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              child: supportedProducts["lpg"] == true
                  ? Padding(
                key: const ValueKey("lpg_visible"),
                padding: EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    TextField(
                      controller: lpgController,
                      onTap: () {
                        if (lpgController.text == "0") {
                          lpgController.clear();
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "الغاز السائل (لتر)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              )
                  : SizedBox(
                key: const ValueKey("lpg_hidden"),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "حالة عمل المحطة:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("🟢 مفتوحة"),
                        selected: currentWorkingStatus == "مفتوحة",
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              currentWorkingStatus = "مفتوحة";
                              stationOpen = true;
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text("🌙 خافرة"),
                        selected: currentWorkingStatus == "خافرة" || currentWorkingStatus.contains("خاف"),
                        selectedColor: const Color(0xFFF3E8FF),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              currentWorkingStatus = "خافرة";
                              stationOpen = true;
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text("🔴 مغلقة"),
                        selected: currentWorkingStatus == "مغلقة",
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              currentWorkingStatus = "مغلقة";
                              stationOpen = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "مؤشر الازدحام الحالي في المحطة:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("🟢 هادئة (بدون انتظار)"),
                        selected: currentCrowdStatus == "هادئة",
                        selectedColor: const Color(0xFFDCFCE7),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              currentCrowdStatus = "هادئة";
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text("🟡 متوسطة (انتظار خفيف)"),
                        selected: currentCrowdStatus == "متوسطة",
                        selectedColor: const Color(0xFFFEF9C3),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              currentCrowdStatus = "متوسطة";
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text("🔴 مزدحمة (انتظار طويل)"),
                        selected: currentCrowdStatus == "مزدحمة",
                        selectedColor: const Color(0xFFFEE2E2),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              currentCrowdStatus = "مزدحمة";
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("حفظ التحديث"),
                onPressed: () async {
                  try {
                    final updatedStation = widget.station.copyWith(
                      supportedProducts: Map<String, bool>.from(
                        supportedProducts,
                      ),

                      regular95:
                      int.tryParse(regularController.text) ?? 0,

                      improved95:
                      int.tryParse(improvedController.text) ?? 0,

                      diesel:
                      int.tryParse(dieselController.text) ?? 0,

                      whiteOil:
                      int.tryParse(whiteOilController.text) ?? 0,

                      super95:
                      int.tryParse(superController.text) ?? 0,

                      lpg:
                      int.tryParse(lpgController.text) ?? 0,

                      workingStatus: currentWorkingStatus,
                      crowdStatus: currentCrowdStatus,

                      updatedAt:
                      DateTime.now().toIso8601String(),
                    );

                    // حفظ بيانات المحطة
                    await databaseService.updateStation(
                      updatedStation,
                    );

                    // حفظ المنتجات بشكل مستقل
                    await databaseService.stationsRef
                        .child(updatedStation.id)
                        .update({
                      "supportedProducts":
                      Map<String, bool>.from(
                        supportedProducts,
                      ),
                    });

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text(
                          "تم حفظ المنتجات بنجاح",
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          "خطأ في حفظ المنتجات: $e",
                        ),
                      ),
                    );

                    debugPrint(
                      "ERROR SAVING SUPPORTED PRODUCTS: $e",
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  // =====================================================
  // بطاقة المنتج المعتمد - إضافة فقط
  // =====================================================

  Widget _approvedProductCard(
      String title,
      String key,
      int index,
      ) {
    final selected = supportedProducts[key] ?? false;

    return AnimatedBuilder(
      animation: _productAnimationController,
      builder: (context, child) {
        final progress =
        Curves.easeOutBack.transform(
          _productAnimationController.value,
        );

        // مقدار الحركة الدائرية
        final angle =
            (1 - progress) * (0.35 + (index * 0.08));

        // حركة قوسية من المركز
        final radius = 45.0 * (1 - progress);

        final dx =
            radius * math.cos(angle + index);

        final dy =
            radius * math.sin(angle + index);

        return Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.rotate(
              angle: (1 - progress) *
                  (index.isEven ? 0.25 : -0.25),
              child: Transform.scale(
                scale: 0.65 + (0.35 * progress),
                child: child,
              ),
            ),
          ),
        );
      },

      child: InkWell(
        borderRadius: BorderRadius.circular(14),

        onTap: () {
          setState(() {
            supportedProducts[key] = !selected;
          });
        },

        child: AnimatedContainer(
          duration: Duration(milliseconds: 280),
          curve: Curves.easeOutBack,

          margin:
          EdgeInsets.symmetric(horizontal: 3),

          padding:
          EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 9,
          ),

          decoration: BoxDecoration(
            color: selected
                ? Colors.blue.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.82),

            borderRadius:
            BorderRadius.circular(14),

            border: Border.all(
              color: selected
                  ? Colors.blue
                  : Colors.grey.shade300,

              width:
              selected ? 1.6 : 1,
            ),
          ),

          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              AnimatedSwitcher(
                duration:
                Duration(milliseconds: 250),

                transitionBuilder:
                    (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },

                child: Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,

                  key: ValueKey(selected),

                  color: selected
                      ? Colors.green
                      : Colors.grey,

                  size: 21,
                ),
              ),

              SizedBox(width: 4),

              Flexible(
                child: Text(
                  title,

                  textAlign:
                  TextAlign.center,

                  maxLines: 2,

                  overflow:
                  TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(String value){

    try{

      final date = DateTime.parse(value);

      return
        "${date.day.toString().padLeft(2,'0')}/"
            "${date.month.toString().padLeft(2,'0')}/"
            "${date.year} "
            "${date.hour.toString().padLeft(2,'0')}:"
            "${date.minute.toString().padLeft(2,'0')}";

    }catch(e){

      return value;

    }

  }
  String formatDateOnly(String value) {
    try {
      final date = DateTime.parse(value);

      return "${date.year}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  String formatTimeOnly(String value) {
    try {
      final date = DateTime.parse(value);

      return "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }
  @override
  void dispose() {
    _productAnimationController.dispose();
    super.dispose();
  }

}
