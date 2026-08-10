import 'package:flutter/material.dart';

import '../models/station.dart';
import '../services/station_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final StationService stationService = StationService.instance;

  List<Station> stations = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStations();
  }

  Future<void> loadStations() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      final data = await stationService.getStations();

      if (!mounted) return;

      setState(() {
        stations = data.where((station) {
          return station.active &&
              station.status != "deleted";
        }).toList();

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تعذر تحميل بيانات المحطات: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // معلومات المنتجات
  // =========================================================

  List<Map<String, dynamic>> get products {
    return [
      {
        "name": "بنزين عادي",
        "field": "regular95",
        "price": 450,
        "icon": Icons.local_gas_station,
        "color": Colors.green,
      },
      {
        "name": "بنزين محسن",
        "field": "improved95",
        "price": 850,
        "icon": Icons.local_gas_station,
        "color": Colors.blue,
      },
      {
        "name": "بنزين سوبر",
        "field": "super95",
        "price": 1250,
        "icon": Icons.local_gas_station,
        "color": Colors.purple,
      },
      {
        "name": "زيت الغاز",
        "field": "diesel",
        "price": 400,
        "icon": Icons.oil_barrel,
        "color": Colors.orange,
      },
      {
        "name": "نفط أبيض",
        "field": "whiteOil",
        "price": 150,
        "icon": Icons.oil_barrel,
        "color": Colors.brown,
      },
      {
        "name": "غاز سائل",
        "field": "lpg",
        "price": 200,
        "icon": Icons.propane_tank,
        "color": Colors.teal,
      },
    ];
  }

  // =========================================================
  // جلب كمية المنتج من المحطة
  // =========================================================

  int getProductQuantity(
      Station station,
      String field,
      ) {
    switch (field) {
      case "regular95":
        return station.regular95;

      case "improved95":
        return station.improved95;

      case "super95":
        return station.super95;

      case "diesel":
        return station.diesel;

      case "whiteOil":
        return station.whiteOil;

      case "lpg":
        return station.lpg;

      default:
        return 0;
    }
  }

  // =========================================================
  // إجمالي كمية المنتج
  // =========================================================

  int getTotalQuantity(String field) {
    int total = 0;

    for (final station in stations) {
      total += getProductQuantity(
        station,
        field,
      );
    }

    return total;
  }

  // =========================================================
  // عدد المحطات التي لديها المنتج
  // =========================================================

  int getProductStationsCount(String field) {
    return stations.where((station) {
      return getProductQuantity(
        station,
        field,
      ) >
          0;
    }).length;
  }

  // =========================================================
  // عدد الفروع التي لديها المنتج
  // =========================================================

  int getProductBranchesCount(String field) {
    final branches = <String>{};

    for (final station in stations) {
      if (getProductQuantity(
        station,
        field,
      ) >
          0) {
        final branchId = station.branchId.trim();

        final branchName = station.branchName.trim();

        final key = branchId.isNotEmpty
            ? branchId
            : branchName;

        if (key.isNotEmpty) {
          branches.add(key);
        }
      }
    }

    return branches.length;
  }

  // =========================================================
  // تنسيق الأرقام
  // =========================================================

  String formatNumber(int value) {
    final text = value.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 &&
          (text.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(text[i]);
    }

    return buffer.toString();
  }

  // =========================================================
  // الشاشة الرئيسية
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF4F7FC),

        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,

          leading: IconButton(
            tooltip: "رجوع",
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          title: const Text(
            "إدارة المنتجات",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          centerTitle: true,

          actions: [
            IconButton(
              tooltip: "تحديث",
              icon: const Icon(
                Icons.refresh,
              ),
              onPressed: loadStations,
            ),
          ],
        ),

        body: loading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : RefreshIndicator(
          onRefresh: loadStations,

          child: stations.isEmpty
              ? ListView(
            children: const [
              SizedBox(
                height: 200,
              ),
              Icon(
                Icons.local_gas_station,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                child: Text(
                  "لا توجد محطات حالياً",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          )
              : ListView(
            padding:
            const EdgeInsets.all(16),

            children: [
              // ==============================
              // العنوان
              // ==============================

              Card(
                elevation: 4,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    18,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                        Colors.blue
                            .shade100,
                        child: Icon(
                          Icons
                              .inventory_2,
                          size: 32,
                          color: Colors
                              .blue
                              .shade800,
                        ),
                      ),

                      const SizedBox(
                        width: 15,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            const Text(
                              "إدارة المنتجات",
                              style:
                              TextStyle(
                                fontSize:
                                21,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              "متابعة المنتجات في جميع الفروع والمحطات",
                              style:
                              TextStyle(
                                color: Colors
                                    .grey
                                    .shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // ==============================
              // المنتجات
              // ==============================

              ...products.map(
                    (product) {
                  final field =
                  product["field"]
                  as String;

                  final total =
                  getTotalQuantity(
                    field,
                  );

                  final stationCount =
                  getProductStationsCount(
                    field,
                  );

                  final branchCount =
                  getProductBranchesCount(
                    field,
                  );

                  return _productCard(
                    product,
                    total,
                    stationCount,
                    branchCount,
                  );
                },
              ),
            ],
          ),
        ),

        floatingActionButton:
        FloatingActionButton.extended(
          backgroundColor: Colors.blue.shade900,

          icon: const Icon(
            Icons.refresh,
          ),

          label: const Text(
            "تحديث البيانات",
          ),

          onPressed: loadStations,
        ),
      ),
    );
  }

  // =========================================================
  // بطاقة المنتج
  // =========================================================

  Widget _productCard(
      Map<String, dynamic> product,
      int total,
      int stationCount,
      int branchCount,
      ) {
    final color =
    product["color"] as Color;

    return Card(
      elevation: 4,

      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),

      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(18),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProductDetailsScreen(
                    product: product,
                    stations: stations,
                  ),
            ),
          );
        },

        child: Padding(
          padding:
          const EdgeInsets.all(16),

          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                    color.withValues(
                      alpha: 0.15,
                    ),
                    child: Icon(
                      product["icon"]
                      as IconData,
                      color: color,
                      size: 30,
                    ),
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          product["name"]
                          as String,
                          style:
                          const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          "${product["price"]} دينار",
                          style:
                          TextStyle(
                            color: color,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons
                        .arrow_forward_ios,
                    size: 18,
                  ),
                ],
              ),

              const Divider(
                height: 25,
              ),

              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceAround,
                children: [
                  _smallStat(
                    "الإجمالي",
                    "${formatNumber(total)} لتر",
                    Icons.inventory_2,
                  ),

                  _smallStat(
                    "الفروع",
                    branchCount.toString(),
                    Icons.account_balance,
                  ),

                  _smallStat(
                    "المحطات",
                    stationCount.toString(),
                    Icons.local_gas_station,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallStat(
      String title,
      String value,
      IconData icon,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blueGrey,
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          value,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        Text(
          title,
          style:
          const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// شاشة تفاصيل المنتج
// ============================================================

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final List<Station> stations;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.stations,
  });

  int getProductQuantity(
      Station station,
      String field,
      ) {
    switch (field) {
      case "regular95":
        return station.regular95;

      case "improved95":
        return station.improved95;

      case "super95":
        return station.super95;

      case "diesel":
        return station.diesel;

      case "whiteOil":
        return station.whiteOil;

      case "lpg":
        return station.lpg;

      default:
        return 0;
    }
  }

  String formatNumber(int value) {
    final text = value.toString();

    final buffer =
    StringBuffer();

    for (int i = 0;
    i < text.length;
    i++) {
      if (i > 0 &&
          (text.length - i) % 3 ==
              0) {
        buffer.write(',');
      }

      buffer.write(text[i]);
    }

    return buffer.toString();
  }

  String stationType(
      Station station,
      ) {
    if (station.stationType ==
        "government" ||
        station.stationType ==
            "حكومية") {
      return "حكومية";
    }

    if (station.stationType ==
        "private" ||
        station.stationType ==
            "أهلية") {
      return "أهلية";
    }

    return station.stationType;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final field =
    product["field"] as String;

    final color =
    product["color"] as Color;

    final productStations =
    stations.where((station) {
      return getProductQuantity(
        station,
        field,
      ) >
          0;
    }).toList();

    final Map<String, List<Station>>
    branches = {};

    for (final station
    in productStations) {
      final branchKey =
      station.branchId.isNotEmpty
          ? station.branchId
          : station.branchName;

      branches
          .putIfAbsent(
        branchKey.isEmpty
            ? "بدون فرع"
            : branchKey,
            () => [],
      )
          .add(station);
    }

    int total = 0;

    for (final station
    in productStations) {
      total += getProductQuantity(
        station,
        field,
      );
    }

    return Directionality(
      textDirection:
      TextDirection.rtl,

      child: Scaffold(
        backgroundColor:
        const Color(0xffF4F7FC),

        appBar: AppBar(
          backgroundColor:
          Colors.blue.shade900,
          foregroundColor:
          Colors.white,

          leading:
          IconButton(
            icon:
            const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
          ),

          title: Text(
            "تفاصيل ${product["name"]}",
          ),

          centerTitle: true,
        ),

        body: ListView(
          padding:
          const EdgeInsets.all(16),

          children: [
            // =====================================
            // ملخص المنتج
            // =====================================

            Card(
              elevation: 4,

              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),

              child: Padding(
                padding:
                const EdgeInsets.all(
                  18,
                ),

                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor:
                      color.withValues(
                        alpha: 0.15,
                      ),
                      child: Icon(
                        product["icon"]
                        as IconData,
                        color: color,
                        size: 38,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      product["name"]
                      as String,
                      style:
                      const TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Text(
                      "${formatNumber(total)} لتر",
                      style:
                      TextStyle(
                        fontSize: 28,
                        fontWeight:
                        FontWeight.bold,
                        color: color,
                      ),
                    ),

                    const Text(
                      "إجمالي الكمية في جميع المحطات",
                      style:
                      TextStyle(
                        color:
                        Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceAround,
                      children: [
                        _summary(
                          "الفروع",
                          branches.length
                              .toString(),
                          Icons
                              .account_balance,
                        ),

                        _summary(
                          "المحطات",
                          productStations
                              .length
                              .toString(),
                          Icons
                              .local_gas_station,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              "الفروع والمحطات",
              style:
              TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // =====================================
            // الفروع
            // =====================================

            ...branches.entries.map(
                  (entry) {
                final branchStations =
                    entry.value;

                int branchTotal = 0;

                for (final station
                in branchStations) {
                  branchTotal +=
                      getProductQuantity(
                        station,
                        field,
                      );
                }

                final branchName =
                branchStations
                    .first
                    .branchName
                    .isNotEmpty
                    ? branchStations
                    .first
                    .branchName
                    : "فرع غير محدد";

                return Card(
                  margin:
                  const EdgeInsets
                      .only(
                    bottom: 12,
                  ),

                  child:
                  ExpansionTile(
                    leading:
                    const CircleAvatar(
                      child: Icon(
                        Icons
                            .account_balance,
                      ),
                    ),

                    title: Text(
                      branchName,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      "المحطات: ${branchStations.length}  |  الكمية: ${formatNumber(branchTotal)} لتر",
                    ),

                    children:
                    branchStations.map(
                          (station) {
                        final quantity =
                        getProductQuantity(
                          station,
                          field,
                        );

                        return _stationTile(
                          context,
                          station,
                          quantity,
                          color,
                        );
                      },
                    ).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(
      String title,
      String value,
      IconData icon,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          color:
          Colors.blue.shade800,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          value,
          style:
          const TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        ),
        Text(
          title,
          style:
          const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _stationTile(
      BuildContext context,
      Station station,
      int quantity,
      Color color,
      ) {
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),

      leading:
      CircleAvatar(
        backgroundColor:
        color.withValues(
          alpha: 0.15,
        ),
        child: Icon(
          Icons
              .local_gas_station,
          color: color,
        ),
      ),

      title: Text(
        station.name,
        style:
        const TextStyle(
          fontWeight:
          FontWeight.bold,
        ),
      ),

      subtitle: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Text(
            "${station.governorate} - ${station.district}",
          ),

          Text(
            "النوع: ${stationType(station)}",
          ),

          Text(
            "الحالة: ${station.workingStatus}",
          ),

          if (station.address
              .isNotEmpty)
            Text(
              "العنوان: ${station.address}",
            ),

          if (station.phone
              .isNotEmpty)
            Text(
              "الهاتف: ${station.phone}",
            ),
        ],
      ),

      trailing:
      Column(
        mainAxisAlignment:
        MainAxisAlignment
            .center,
        children: [
          Text(
            formatNumber(
              quantity,
            ) +
                " لتر",
            style:
            TextStyle(
              color: color,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          const Text(
            "المتوفر",
            style:
            TextStyle(
              fontSize: 10,
              color:
              Colors.grey,
            ),
          ),
        ],
      ),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductStationDetailsScreen(
                  station: station,
                  product: product,
                  quantity: quantity,
                ),
          ),
        );
      },
    );
  }
}

// ============================================================
// تفاصيل المحطة والمنتج
// ============================================================

class ProductStationDetailsScreen
    extends StatelessWidget {
  final Station station;
  final Map<String, dynamic> product;
  final int quantity;

  const ProductStationDetailsScreen({
    super.key,
    required this.station,
    required this.product,
    required this.quantity,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final color =
    product["color"] as Color;

    return Directionality(
      textDirection:
      TextDirection.rtl,

      child: Scaffold(
        backgroundColor:
        const Color(0xffF4F7FC),

        appBar: AppBar(
          backgroundColor:
          Colors.blue.shade900,
          foregroundColor:
          Colors.white,

          leading:
          IconButton(
            icon:
            const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
          ),

          title:
          const Text(
            "تفاصيل المحطة",
          ),

          centerTitle: true,
        ),

        body: ListView(
          padding:
          const EdgeInsets.all(16),

          children: [
            Card(
              elevation: 4,

              child: Padding(
                padding:
                const EdgeInsets.all(
                  18,
                ),

                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor:
                      color.withValues(
                        alpha: 0.15,
                      ),
                      child: Icon(
                        Icons
                            .local_gas_station,
                        size: 42,
                        color: color,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      station.name,
                      style:
                      const TextStyle(
                        fontSize: 23,
                        fontWeight:
                        FontWeight.bold,
                      ),
                      textAlign:
                      TextAlign.center,
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      "${station.governorate} - ${station.district}",
                      style:
                      const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    Container(
                      width:
                      double.infinity,
                      padding:
                      const EdgeInsets.all(
                        18,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        color.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          15,
                        ),
                      ),
                      child:
                      Column(
                        children: [
                          Text(
                            product["name"]
                            as String,
                            style:
                            const TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            "$quantity لتر",
                            style:
                            TextStyle(
                              fontSize: 30,
                              fontWeight:
                              FontWeight
                                  .bold,
                              color: color,
                            ),
                          ),

                          const Text(
                            "الكمية المتوفرة",
                            style:
                            TextStyle(
                              color:
                              Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            _detailCard(
              "معلومات المحطة",
              [
                _detail(
                  "نوع المحطة",
                  station.stationType,
                ),
                _detail(
                  "الفرع",
                  station.branchName,
                ),
                _detail(
                  "المحافظة",
                  station.governorate,
                ),
                _detail(
                  "القضاء",
                  station.district,
                ),
                _detail(
                  "الحالة",
                  station.workingStatus,
                ),
                _detail(
                  "الهاتف",
                  station.phone,
                ),
                _detail(
                  "العنوان",
                  station.address,
                ),
              ],
            ),

            const SizedBox(
              height: 15,
            ),

            _detailCard(
              "باقي المنتجات في المحطة",
              [
                _detail(
                  "بنزين عادي",
                  "${station.regular95} لتر",
                ),
                _detail(
                  "بنزين محسن",
                  "${station.improved95} لتر",
                ),
                _detail(
                  "بنزين سوبر",
                  "${station.super95} لتر",
                ),
                _detail(
                  "زيت الغاز",
                  "${station.diesel} لتر",
                ),
                _detail(
                  "نفط أبيض",
                  "${station.whiteOil} لتر",
                ),
                _detail(
                  "غاز سائل",
                  "${station.lpg} لتر",
                ),
              ],
            ),

            const SizedBox(
              height: 15,
            ),

            _detailCard(
              "الموقع والتحديث",
              [
                _detail(
                  "خط العرض",
                  station.latitude
                      .toString(),
                ),
                _detail(
                  "خط الطول",
                  station.longitude
                      .toString(),
                ),
                _detail(
                  "آخر تحديث",
                  station.updatedAt
                      .isEmpty
                      ? "غير محدد"
                      : station.updatedAt,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard(
      String title,
      List<Widget> children,
      ) {
    return Card(
      elevation: 3,

      child: Padding(
        padding:
        const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,

          children: [
            Text(
              title,
              style:
              const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const Divider(
              height: 22,
            ),

            ...children,
          ],
        ),
      ),
    );
  }

  Widget _detail(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty
                  ? "غير متوفر"
                  : value,
            ),
          ),
        ],
      ),
    );
  }
}