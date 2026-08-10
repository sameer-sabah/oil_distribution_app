import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/station.dart';
import '../services/station_service.dart';
import '../services/navigation_service.dart';
import '../services/auth_service.dart';
import '../widgets/station_card.dart';

import 'notifications_screen.dart';

class CitizenScreen extends StatefulWidget {
  const CitizenScreen({
    super.key,
  });

  @override
  State<CitizenScreen> createState() =>
      _CitizenScreenState();
}

class _CitizenScreenState
    extends State<CitizenScreen> {

  final StationService stationService =
      StationService.instance;

  final AuthService auth =
      AuthService.instance;

  List<Station> stations = [];

  List<Station> filteredStations = [];

  StreamSubscription? stationSubscription;

  bool loading = true;

  bool locationLoading = false;

  double? userLatitude;

  double? userLongitude;

  String search = "";

  String selectedProduct =
      "بنزين عادي";

  final products = const [
    "بنزين عادي",
    "بنزين محسن",
    "بنزين سوبر",
    "ديزل",
    "نفط أبيض",
    "غاز",
  ];

  @override
  void initState() {
    super.initState();

    getLocation();

    listenStations();
  }

  // =========================================================
  // البث المباشر للمحطات
  // =========================================================

  void listenStations() {
    stationSubscription =
        stationService.stationsStream().listen(
              (data) {

            stations = data.where((station) {
              return station.active &&
                  station.approved &&
                  station.status != "deleted";
            }).toList();

            filterStations();

            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          },
          onError: (error) {
            if (!mounted) return;

            setState(() {
              loading = false;
            });

            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  "تعذر تحميل المحطات: $error",
                ),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
  }

  // =========================================================
  // تحديث البيانات
  // =========================================================

  Future<void> loadData() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      await getLocation();

      final data =
      await stationService.getStations();

      stations = data.where((station) {
        return station.active &&
            station.approved &&
            station.status != "deleted";
      }).toList();

      filterStations();

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "تعذر تحديث البيانات: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // تحديد موقع المواطن
  // =========================================================

  Future<void> getLocation() async {
    if (mounted) {
      setState(() {
        locationLoading = true;
      });
    }

    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          locationLoading = false;
        });

        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          locationLoading = false;
        });

        return;
      }

      final position =
      await Geolocator.getCurrentPosition();

      userLatitude = position.latitude;

      userLongitude = position.longitude;

      filterStations();

      if (!mounted) return;

      setState(() {
        locationLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        locationLoading = false;
      });
    }
  }

  // =========================================================
  // حساب المسافة
  // =========================================================

  double distanceFromUser(
      Station station,
      ) {
    if (userLatitude == null ||
        userLongitude == null) {
      return 0;
    }

    if (station.latitude == 0 ||
        station.longitude == 0) {
      return 0;
    }

    return Geolocator.distanceBetween(
      userLatitude!,
      userLongitude!,
      station.latitude,
      station.longitude,
    ) /
        1000;
  }

  // =========================================================
  // فلترة المحطات
  // =========================================================

  void filterStations() {
    filteredStations =
        stations.where((station) {

          bool matchSearch = true;

          if (search.trim().isNotEmpty) {
            final value =
            search.toLowerCase().trim();

            matchSearch =
                station.name
                    .toLowerCase()
                    .contains(value) ||
                    station.governorate
                        .toLowerCase()
                        .contains(value) ||
                    station.district
                        .toLowerCase()
                        .contains(value);
          }

          final bool available =
          checkProduct(station);

          return matchSearch &&
              available;
        }).toList();

    filteredStations.sort(
          (a, b) {
        return distanceFromUser(a)
            .compareTo(
          distanceFromUser(b),
        );
      },
    );
  }

  // =========================================================
  // فحص توفر المنتج
  // =========================================================

  bool checkProduct(
      Station station,
      ) {
    switch (selectedProduct) {
      case "بنزين عادي":
        return station.regular95 > 0;

      case "بنزين محسن":
        return station.improved95 > 0;

      case "بنزين سوبر":
        return station.super95 > 0;

      case "ديزل":
        return station.diesel > 0;

      case "نفط أبيض":
        return station.whiteOil > 0;

      case "غاز":
        return station.lpg > 0;

      default:
        return true;
    }
  }

  // =========================================================
  // كمية المنتج
  // =========================================================

  int productQuantity(
      Station station,
      ) {
    switch (selectedProduct) {
      case "بنزين عادي":
        return station.regular95;

      case "بنزين محسن":
        return station.improved95;

      case "بنزين سوبر":
        return station.super95;

      case "ديزل":
        return station.diesel;

      case "نفط أبيض":
        return station.whiteOil;

      case "غاز":
        return station.lpg;

      default:
        return 0;
    }
  }

  // =========================================================
  // اسم المنتج
  // =========================================================

  String getProductName() {
    return selectedProduct;
  }

  // =========================================================
  // أقرب محطة
  // =========================================================

  Station? get nearestStation {
    if (filteredStations.isEmpty) {
      return null;
    }

    return filteredStations.first;
  }

  // =========================================================
  // اتصال الطوارئ 911
  // =========================================================

  Future<void> callEmergency() async {
    final uri = Uri(
      scheme: "tel",
      path: "911",
    );

    try {
      final launched =
      await launchUrl(uri);

      if (!launched && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "تعذر فتح الاتصال بالطوارئ",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "تعذر الاتصال بالطوارئ",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // الملاحة إلى محطة
  // =========================================================

  Future<void> navigateToStation(
      Station station,
      ) async {
    if (station.latitude == 0 ||
        station.longitude == 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "إحداثيات المحطة غير موجودة",
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    try {
      await NavigationService()
          .navigateToStation(
        station.latitude,
        station.longitude,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "تعذر فتح الملاحة: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // الإشعارات
  // =========================================================

  void openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(
          userId: "citizen",
        ),
      ),
    );
  }


  // =========================================================
  // واجهة الشاشة
  // =========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Directionality(
      textDirection:
      TextDirection.rtl,

      child: Scaffold(
        backgroundColor:
        const Color(0xffF4F7FC),

        appBar: AppBar(
          backgroundColor:
          Colors.blue.shade800,

          foregroundColor:
          Colors.white,

          title: const Text(
            "نافذة المنتوج النفطي",
            style: TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),

          centerTitle: true,

          actions: [
            IconButton(
              tooltip: "الإشعارات",
              icon: const Icon(
                Icons.notifications,
              ),
              onPressed:
              openNotifications,
            ),

            IconButton(
              tooltip: "تحديث",
              icon: const Icon(
                Icons.refresh,
              ),
              onPressed:
              loadData,
            ),
          ],
        ),

        body: loading
            ? const Center(
          child:
          CircularProgressIndicator(),
        )
            : RefreshIndicator(
          onRefresh:
          loadData,

          child: ListView(
            padding:
            const EdgeInsets.all(
              12,
            ),

            children: [

              // =================================================
              // الترحيب
              // =================================================

              Card(
                elevation: 4,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),

                child:
                Padding(
                  padding:
                  const EdgeInsets
                      .all(
                    16,
                  ),

                  child:
                  Row(
                    children: [

                      CircleAvatar(
                        radius: 30,

                        backgroundColor:
                        Colors.blue
                            .shade100,

                        child:
                        Icon(
                          Icons
                              .person,
                          size: 34,
                          color: Colors
                              .blue
                              .shade800,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      const Expanded(
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [
                            Text(
                              "أهلاً بك 👋",
                              style:
                              TextStyle(
                                fontSize:
                                20,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            SizedBox(
                              height: 5,
                            ),

                            Text(
                              "اعرف توفر المنتجات النفطية في أقرب محطة إليك",
                              style:
                              TextStyle(
                                color:
                                Colors
                                    .grey,
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
                height: 12,
              ),

              // =================================================
              // الطوارئ 911
              // =================================================

              InkWell(
                borderRadius:
                BorderRadius.circular(
                  18,
                ),

                onTap:
                callEmergency,

                child:
                Container(
                  padding:
                  const EdgeInsets
                      .all(
                    16,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    Colors.red
                        .shade700,

                    borderRadius:
                    BorderRadius
                        .circular(
                      18,
                    ),

                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 5,
                        offset:
                        Offset(
                          0,
                          3,
                        ),
                      ),
                    ],
                  ),

                  child:
                  Row(
                    children: [

                      Container(
                        width: 55,
                        height: 55,

                        decoration:
                        const BoxDecoration(
                          color:
                          Colors.white,
                          shape:
                          BoxShape
                              .circle,
                        ),

                        child:
                        const Icon(
                          Icons
                              .phone_in_talk,
                          color:
                          Colors.red,
                          size: 30,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      const Expanded(
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Text(
                              "الطوارئ 911",
                              style:
                              TextStyle(
                                color:
                                Colors
                                    .white,
                                fontSize:
                                20,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            SizedBox(
                              height: 4,
                            ),

                            Text(
                              "اتصال سريع بخدمات الطوارئ",
                              style:
                              TextStyle(
                                color:
                                Colors
                                    .white,
                                fontSize:
                                13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons
                            .arrow_forward_ios,
                        color:
                        Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // =================================================
              // الموقع
              // =================================================

              Card(
                elevation: 3,

                child:
                ListTile(
                  leading:
                  CircleAvatar(
                    backgroundColor:
                    Colors.green
                        .shade100,

                    child:
                    locationLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                      ),
                    )
                        : Icon(
                      Icons
                          .location_on,
                      color:
                      Colors
                          .green
                          .shade700,
                    ),
                  ),

                  title:
                  const Text(
                    "موقعك الحالي",
                    style:
                    TextStyle(
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),

                  subtitle:
                  Text(
                    userLatitude ==
                        null
                        ? "لم يتم تحديد موقعك"
                        : "تم تحديد موقعك بنجاح",
                  ),

                  trailing:
                  IconButton(
                    icon:
                    const Icon(
                      Icons.my_location,
                      color:
                      Colors.blue,
                    ),
                    onPressed:
                    getLocation,
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // =================================================
              // أقرب محطة
              // =================================================

              _buildNearestStationCard(),

              const SizedBox(
                height: 12,
              ),

              // =================================================
              // البحث
              // =================================================

              TextField(
                decoration:
                InputDecoration(
                  hintText:
                  "بحث عن محطة أو منطقة...",

                  prefixIcon:
                  const Icon(
                    Icons.search,
                  ),

                  suffixIcon:
                  search.isNotEmpty
                      ? IconButton(
                    icon:
                    const Icon(
                      Icons.clear,
                    ),
                    onPressed:
                        () {
                      setState(
                            () {
                          search =
                          "";
                          filterStations();
                        },
                      );
                    },
                  )
                      : null,

                  filled: true,

                  fillColor:
                  Colors.white,

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),

                    borderSide:
                    BorderSide.none,
                  ),
                ),

                onChanged:
                    (value) {
                  setState(
                        () {
                      search =
                          value;

                      filterStations();
                    },
                  );
                },
              ),

              const SizedBox(
                height: 12,
              ),

              // =================================================
              // اختيار المنتج
              // =================================================

              DropdownButtonFormField<
                  String>(
                initialValue:
                selectedProduct,

                decoration:
                InputDecoration(
                  labelText:
                  "نوع المنتوج",

                  prefixIcon:
                  const Icon(
                    Icons
                        .local_gas_station,
                  ),

                  filled: true,

                  fillColor:
                  Colors.white,

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),
                  ),
                ),

                items:
                products.map(
                      (product) {
                    return DropdownMenuItem<
                        String>(
                      value:
                      product,

                      child:
                      Text(
                        product,
                      ),
                    );
                  },
                ).toList(),

                onChanged:
                    (value) {
                  if (value ==
                      null) {
                    return;
                  }

                  setState(
                        () {
                      selectedProduct =
                          value;

                      filterStations();
                    },
                  );
                },
              ),

              const SizedBox(
                height: 12,
              ),

              // =================================================
              // عنوان النتائج
              // =================================================

              Row(
                children: [

                  const Icon(
                    Icons
                        .local_gas_station,
                    color:
                    Colors.blue,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child:
                    Text(
                      "محطات ${getProductName()} المتوفرة",
                      style:
                      const TextStyle(
                        fontSize:
                        18,
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration:
                    BoxDecoration(
                      color: Colors
                          .blue
                          .shade100,

                      borderRadius:
                      BorderRadius
                          .circular(
                        12,
                      ),
                    ),

                    child:
                    Text(
                      "${filteredStations.length}",
                      style:
                      TextStyle(
                        color: Colors
                            .blue
                            .shade900,
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 8,
              ),

              // =================================================
              // المحطات
              // =================================================

              if (filteredStations
                  .isEmpty)

                Card(
                  child:
                  Padding(
                    padding:
                    const EdgeInsets
                        .all(
                      30,
                    ),

                    child:
                    Column(
                      children: [

                        const Icon(
                          Icons
                              .search_off,
                          size: 65,
                          color:
                          Colors.grey,
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        const Text(
                          "لا توجد محطات متوفرة حالياً",
                          style:
                          TextStyle(
                            fontSize:
                            17,
                            color:
                            Colors
                                .grey,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        OutlinedButton
                            .icon(
                          onPressed:
                              () {
                            setState(
                                  () {
                                search =
                                "";
                                filterStations();
                              },
                            );
                          },
                          icon:
                          const Icon(
                            Icons
                                .refresh,
                          ),
                          label:
                          const Text(
                            "إظهار المحطات",
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else

                ...filteredStations
                    .map(
                      (station) {
                    return StationCard(
                      station:
                      station,

                      distance:
                      distanceFromUser(
                        station,
                      ),

                      onDetails:
                          () {
                        _showStationDetails(
                          station,
                        );
                      },

                      onEdit:
                      null,

                      onDelete:
                      null,

                      onMap:
                          () {
                        navigateToStation(
                          station,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // بطاقة أقرب محطة
  // =========================================================

  Widget _buildNearestStationCard() {
    final station =
        nearestStation;

    if (station == null) {
      return Card(
        elevation: 3,

        child:
        const Padding(
          padding:
          EdgeInsets.all(16),

          child:
          Row(
            children: [
              Icon(
                Icons
                    .location_searching,
                color:
                Colors.grey,
                size: 30,
              ),

              SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                Text(
                  "اختر منتجاً متوفراً للعثور على أقرب محطة",
                  style:
                  TextStyle(
                    color:
                    Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final distance =
    distanceFromUser(
      station,
    );

    final quantity =
    productQuantity(
      station,
    );

    final bool isOpen =
        station.workingStatus ==
            "مفتوحة";

    return Card(
      elevation: 5,

      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),

      child:
      Padding(
        padding:
        const EdgeInsets.all(
          16,
        ),

        child:
        Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,

          children: [

            Row(
              children: [

                CircleAvatar(
                  radius: 28,

                  backgroundColor:
                  Colors.green
                      .shade100,

                  child:
                  const Icon(
                    Icons
                        .location_on,
                    color:
                    Colors.green,
                    size: 30,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                const Expanded(
                  child:
                  Text(
                    "أقرب محطة متوفرة",
                    style:
                    TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    isOpen
                        ? Colors.green
                        : Colors.red,

                    borderRadius:
                    BorderRadius
                        .circular(
                      10,
                    ),
                  ),

                  child:
                  Text(
                    isOpen
                        ? "مفتوحة"
                        : "مغلقة",

                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontSize:
                      11,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(
              height: 25,
            ),

            Text(
              station.name,
              style:
              const TextStyle(
                fontSize: 21,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              "${station.governorate} - ${station.district}",
              style:
              const TextStyle(
                color:
                Colors.grey,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Row(
              children: [

                const Icon(
                  Icons
                      .local_gas_station,
                  size: 20,
                  color:
                  Colors.blue,
                ),

                const SizedBox(
                  width: 5,
                ),

                Text(
                  "$selectedProduct: $quantity لتر",
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 5,
            ),

            Row(
              children: [

                const Icon(
                  Icons
                      .directions_car,
                  size: 20,
                  color:
                  Colors.orange,
                ),

                const SizedBox(
                  width: 5,
                ),

                Text(
                  distance > 0
                      ? "${distance.toStringAsFixed(1)} كم"
                      : "المسافة غير متوفرة",
                  style:
                  const TextStyle(
                    color:
                    Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 15,
            ),

            SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton
                  .icon(
                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  Colors.green
                      .shade700,
                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 13,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      12,
                    ),
                  ),
                ),

                onPressed:
                    () {
                  navigateToStation(
                    station,
                  );
                },

                icon:
                const Icon(
                  Icons.navigation,
                ),

                label:
                const Text(
                  "ابدأ الملاحة",
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // تفاصيل المحطة
  // =========================================================

  void _showStationDetails(
      Station station,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
          Text(
            station.name,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),

          content:
          SingleChildScrollView(
            child:
            Column(
              mainAxisSize:
              MainAxisSize.min,

              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [

                Text(
                  "المحافظة: ${station.governorate}",
                ),

                Text(
                  "القضاء: ${station.district}",
                ),

                Text(
                  "نوع المحطة: ${station.stationType}",
                ),

                const SizedBox(
                  height: 10,
                ),

                const Divider(),

                Text(
                  "بنزين عادي: ${station.regular95} لتر",
                ),

                Text(
                  "بنزين محسن: ${station.improved95} لتر",
                ),

                Text(
                  "بنزين سوبر: ${station.super95} لتر",
                ),

                Text(
                  "ديزل: ${station.diesel} لتر",
                ),

                Text(
                  "النفط الأبيض: ${station.whiteOil} لتر",
                ),

                Text(
                  "الغاز السائل: ${station.lpg} لتر",
                ),

                const SizedBox(
                  height: 15,
                ),

                Card(
                  child:
                  ListTile(
                    leading:
                    Icon(
                      station.workingStatus ==
                          "مفتوحة"
                          ? Icons
                          .check_circle
                          : Icons.cancel,

                      color:
                      station.workingStatus ==
                          "مفتوحة"
                          ? Colors
                          .green
                          : Colors.red,
                    ),

                    title:
                    const Text(
                      "حالة المحطة",
                    ),

                    subtitle:
                    Text(
                      station.workingStatus,
                    ),
                  ),
                ),

                Card(
                  child:
                  ListTile(
                    leading:
                    const Icon(
                      Icons.update,
                      color:
                      Colors.blue,
                    ),

                    title:
                    const Text(
                      "آخر تحديث للكميات",
                    ),

                    subtitle:
                    Text(
                      station.updatedAt
                          .isEmpty
                          ? "لا يوجد تحديث"
                          : station.updatedAt,
                    ),
                  ),
                ),

                if (station.address
                    .isNotEmpty)
                  ListTile(
                    leading:
                    const Icon(
                      Icons
                          .location_on,
                    ),
                    title:
                    const Text(
                      "العنوان",
                    ),
                    subtitle:
                    Text(
                      station.address,
                    ),
                  ),

                if (station.phone
                    .isNotEmpty)
                  ListTile(
                    leading:
                    const Icon(
                      Icons.phone,
                    ),
                    title:
                    const Text(
                      "الهاتف",
                    ),
                    subtitle:
                    Text(
                      station.phone,
                    ),
                  ),

                const SizedBox(
                  height: 10,
                ),

                SizedBox(
                  width:
                  double.infinity,

                  child:
                  ElevatedButton
                      .icon(
                    icon:
                    const Icon(
                      Icons.navigation,
                    ),

                    label:
                    const Text(
                      "ابدأ الملاحة",
                    ),

                    onPressed:
                        () {
                      Navigator.pop(
                        dialogContext,
                      );

                      navigateToStation(
                        station,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
              const Text(
                "إغلاق",
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // إنهاء الشاشة
  // =========================================================

  @override
  void dispose() {
    stationSubscription?.cancel();

    super.dispose();
  }
}