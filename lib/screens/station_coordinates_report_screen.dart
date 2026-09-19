import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/station.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

enum _DistanceFilter {
  all,
  governmentGovernment,
  governmentPrivate,
  privatePrivate,
}

class StationCoordinatesReportScreen extends StatefulWidget {
  const StationCoordinatesReportScreen({super.key});

  @override
  State<StationCoordinatesReportScreen> createState() =>
      _StationCoordinatesReportScreenState();
}

class _StationCoordinatesReportScreenState
    extends State<StationCoordinatesReportScreen>
    with SingleTickerProviderStateMixin {
  static const String _directionsApiKey =
  String.fromEnvironment('GOOGLE_DIRECTIONS_API_KEY');

  late final Future<List<Station>> _stationsFuture;
  late final TabController _tabController;

  GoogleMapController? _mapController;

  _DistanceFilter _distanceFilter = _DistanceFilter.all;
  String? _selectedGovernorate;

  bool _routesLoading = false;
  String? _routesError;

  final List<_RoadDistance> _roadDistances = [];
  final Set<Polyline> _routePolylines = {};

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _stationsFuture = _loadAllowedStations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<List<Station>> _loadAllowedStations() async {
    final auth = AuthService.instance;
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    if (!auth.isAdmin && !auth.isBranchManager) {
      throw Exception(
        'هذا التقرير متاح فقط لمدير النظام ومدير الفرع',
      );
    }

    final allStations =
    await DatabaseService.instance.getStations();

    final visibleStations = auth.isAdmin
        ? allStations
        : allStations.where((station) {
            final userBranchId = user.branchId.trim().toLowerCase();
            final userBranchName = user.branchName.trim().toLowerCase();
            final stBranchId = station.branchId.trim().toLowerCase();
            final stBranchName = station.branchName.trim().toLowerCase();

            if (userBranchId.isNotEmpty && stBranchId.isNotEmpty) {
              return userBranchId == stBranchId;
            }
            if (userBranchName.isNotEmpty && stBranchName.isNotEmpty) {
              return userBranchName == stBranchName;
            }
            return false;
          }).toList();

    visibleStations.sort(
          (a, b) => a.name
          .trim()
          .toLowerCase()
          .compareTo(
        b.name.trim().toLowerCase(),
      ),
    );

    return visibleStations;
  }

  bool _isGovernment(Station station) {
    final type = station.stationType.trim().toLowerCase();

    return type == 'حكومية' ||
        type == 'حكومي' ||
        type == 'government';
  }

  bool _isPrivate(Station station) {
    final type = station.stationType.trim().toLowerCase();

    return type == 'أهلية' ||
        type == 'اهلية' ||
        type == 'خاصة' ||
        type == 'private';
  }

  bool _hasCoordinates(Station station) {
    return station.latitude != 0 &&
        station.longitude != 0;
  }

  String _coordinateText(double value) {
    if (value == 0) {
      return 'غير مسجل';
    }

    return value.toStringAsFixed(6);
  }

  String _governorateName(Station station) {
    final value = station.governorate.trim();
    return value.isEmpty ? 'غير محدد' : value;
  }

  List<String> _governorates(
      List<Station> stations,
      ) {
    final names = stations
        .map(_governorateName)
        .toSet()
        .toList()
      ..sort();

    return names;
  }

  List<Station> _stationsForRoadFeature(
      List<Station> stations,
      ) {
    final auth = AuthService.instance;

    if (auth.isBranchManager) {
      return stations.where(_hasCoordinates).toList();
    }

    final selected = _selectedGovernorate;

    if (selected == null || selected.isEmpty) {
      return <Station>[];
    }

    return stations
        .where(
          (station) =>
      _governorateName(station) == selected &&
          _hasCoordinates(station),
    )
        .toList();
  }

  bool _pairAllowed(
      Station first,
      Station second,
      ) {
    final firstGovernment = _isGovernment(first);
    final secondGovernment = _isGovernment(second);
    final firstPrivate = _isPrivate(first);
    final secondPrivate = _isPrivate(second);

    switch (_distanceFilter) {
      case _DistanceFilter.all:
        return (firstGovernment || firstPrivate) &&
            (secondGovernment || secondPrivate);

      case _DistanceFilter.governmentGovernment:
        return firstGovernment && secondGovernment;

      case _DistanceFilter.governmentPrivate:
        return (firstGovernment && secondPrivate) ||
            (firstPrivate && secondGovernment);

      case _DistanceFilter.privatePrivate:
        return firstPrivate && secondPrivate;
    }
  }

  List<_StationPair> _buildPairs(
      List<Station> stations,
      ) {
    final pairs = <_StationPair>[];

    for (var i = 0; i < stations.length; i++) {
      for (var j = i + 1; j < stations.length; j++) {
        final first = stations[i];
        final second = stations[j];

        if (_pairAllowed(first, second)) {
          pairs.add(
            _StationPair(
              first: first,
              second: second,
            ),
          );
        }
      }
    }

    return pairs;
  }

  String _filterLabel(
      _DistanceFilter filter,
      ) {
    switch (filter) {
      case _DistanceFilter.all:
        return 'الكل';
      case _DistanceFilter.governmentGovernment:
        return 'حكومي ↔ حكومي';
      case _DistanceFilter.governmentPrivate:
        return 'حكومي ↔ أهلي';
      case _DistanceFilter.privatePrivate:
        return 'أهلي ↔ أهلي';
    }
  }

  Color _routeColor(
      _DistanceFilter filter,
      ) {
    switch (filter) {
      case _DistanceFilter.all:
        return Colors.indigo;
      case _DistanceFilter.governmentGovernment:
        return Colors.blue;
      case _DistanceFilter.governmentPrivate:
        return Colors.deepOrange;
      case _DistanceFilter.privatePrivate:
        return Colors.green;
    }
  }

  Future<void> _calculateRoadRoutes(
      List<Station> stations,
      ) async {
    final scopedStations =
    _stationsForRoadFeature(stations);

    if (scopedStations.length < 2) {
      setState(() {
        _routesError =
        'لا توجد محطتان على الأقل بإحداثيات صالحة ضمن النطاق المختار.';
      });
      return;
    }

    final pairs = _buildPairs(scopedStations);

    if (pairs.isEmpty) {
      setState(() {
        _routesError =
        'لا توجد أزواج محطات مطابقة لنوع المقارنة المختار.';
      });
      return;
    }

    setState(() {
      _routesLoading = true;
      _routesError = null;
      _roadDistances.clear();
      _routePolylines.clear();
    });

    final polylinePoints = PolylinePoints();
    final bool hasApiKey = _directionsApiKey.trim().isNotEmpty;

    try {
      for (var index = 0; index < pairs.length; index++) {
        final pair = pairs[index];
        List<LatLng> mapPoints = [];
        double? distanceKm;

        if (hasApiKey) {
          try {
            final result = await polylinePoints.getRouteBetweenCoordinates(
              googleApiKey: _directionsApiKey,
              request: PolylineRequest(
                origin: PointLatLng(
                  pair.first.latitude,
                  pair.first.longitude,
                ),
                destination: PointLatLng(
                  pair.second.latitude,
                  pair.second.longitude,
                ),
                mode: TravelMode.driving,
              ),
            );

            if (result.points.isNotEmpty) {
              mapPoints = result.points
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList();
              if (result.totalDistanceValue != null) {
                distanceKm = result.totalDistanceValue! / 1000.0;
              }
            }
          } catch (_) {}
        }

        // حساب المسافة المباشرة كبديل ذكي وفوري عند عدم توفر مفتاح API
        if (distanceKm == null || mapPoints.isEmpty) {
          final meters = Geolocator.distanceBetween(
            pair.first.latitude,
            pair.first.longitude,
            pair.second.latitude,
            pair.second.longitude,
          );
          distanceKm = meters / 1000.0;
          mapPoints = [
            LatLng(pair.first.latitude, pair.first.longitude),
            LatLng(pair.second.latitude, pair.second.longitude),
          ];
        }

        final route = _RoadDistance(
          from: pair.first,
          to: pair.second,
          distanceKm: distanceKm,
          available: true,
        );

        _roadDistances.add(route);

        _routePolylines.add(
          Polyline(
            polylineId: PolylineId(
              'route_${pair.first.id}_${pair.second.id}',
            ),
            points: mapPoints,
            width: 4,
            color: _routeColor(_distanceFilter),
            geodesic: true,
          ),
        );

        if (mounted) {
          setState(() {});
        }
      }

      _roadDistances.sort((a, b) {
        if (a.distanceKm == null && b.distanceKm == null) return 0;
        if (a.distanceKm == null) return 1;
        if (b.distanceKm == null) return -1;
        return a.distanceKm!.compareTo(b.distanceKm!);
      });

      if (mounted) {
        setState(() {
          _routesLoading = false;
        });
      }

      await _fitMapToStations(scopedStations);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _routesLoading = false;
        _routesError = 'تعذر حساب المسافات: $e';
      });
    }
  }

  Future<void> _exportHighResMapReport(List<Station> stations) async {
    try {
      if (_mapController == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى الانتظار لحين تحميل الخريطة')),
        );
        return;
      }

      // التقاط صورة الخريطة بدقة عالية من متحكم الخريطة
      final Uint8List? imageBytes = await _mapController!.takeSnapshot();

      if (imageBytes == null || imageBytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر التقاط صورة الخريطة')),
        );
        return;
      }

      final auth = AuthService.instance;
      final user = auth.currentUser;
      final branchName = user?.branchName.isNotEmpty == true ? user!.branchName : "فرع التوزيع المعتمد";
      final now = DateTime.now();
      final dateStr = "${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // تحميل الخط العربي المعتمد للـ PDF لمنع ظهور مربعات XXXX
      pw.Font? arabicFont;
      pw.Font? arabicBoldFont;
      try {
        arabicFont = await PdfGoogleFonts.cairoMedium();
        arabicBoldFont = await PdfGoogleFonts.cairoBold();
      } catch (_) {}

      // إنشاء مستند عالي الدقة بفرشاة الخط العربي للطباعة والتكبير
      final pdf = pw.Document(
        theme: arabicFont != null
            ? pw.ThemeData.withFont(
                base: arabicFont,
                bold: arabicBoldFont ?? arabicFont,
              )
            : null,
      );

      final mapImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(18),
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue900,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'تقرير إحداثيات ومسافات الخريطة - $branchName',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'التاريخ: $dateStr | عدد محطات الفرع: ${stations.length}',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Expanded(
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400, width: 2),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Image(
                        mapImage,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  if (_roadDistances.isNotEmpty) ...[
                    pw.Text(
                      'جدول مسافات الطرق المنجزة (${_roadDistances.length} مقارنة):',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 6),
                    pw.TableHelper.fromTextArray(
                      headers: ['ت', 'من محطة', 'إلى محطة', 'المسافة (كم)'],
                      data: List.generate(_roadDistances.length > 8 ? 8 : _roadDistances.length, (i) {
                        final item = _roadDistances[i];
                        return [
                          '${i + 1}',
                          item.from.name,
                          item.to.name,
                          item.distanceKm != null ? '${item.distanceKm!.toStringAsFixed(2)} كم' : 'غير محددة',
                        ];
                      }),
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                      cellAlignment: pw.Alignment.centerRight,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );

      // فتح شاشة التنزيل والطباعة فائقة الدقة
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'تقرير_خريطة_المحطات_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر استخراج صورة التقرير: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fitMapToStations(
      List<Station> stations,
      ) async {
    final controller = _mapController;

    if (controller == null ||
        stations.isEmpty) {
      return;
    }

    if (stations.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            stations.first.latitude,
            stations.first.longitude,
          ),
          13,
        ),
      );
      return;
    }

    var minLat = stations.first.latitude;
    var maxLat = stations.first.latitude;
    var minLng = stations.first.longitude;
    var maxLng = stations.first.longitude;

    for (final station in stations.skip(1)) {
      if (station.latitude < minLat) {
        minLat = station.latitude;
      }
      if (station.latitude > maxLat) {
        maxLat = station.latitude;
      }
      if (station.longitude < minLng) {
        minLng = station.longitude;
      }
      if (station.longitude > maxLng) {
        maxLng = station.longitude;
      }
    }

    if (minLat == maxLat &&
        minLng == maxLng) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(minLat, minLng),
          13,
        ),
      );
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            minLat,
            minLng,
          ),
          northeast: LatLng(
            maxLat,
            maxLng,
          ),
        ),
        52,
      ),
    );
  }

  Set<Marker> _buildMarkers(
      List<Station> stations,
      ) {
    return stations
        .where(_hasCoordinates)
        .map(
          (station) => Marker(
        markerId: MarkerId(station.id),
        position: LatLng(
          station.latitude,
          station.longitude,
        ),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: _isGovernment(station)
              ? 'محطة حكومية'
              : _isPrivate(station)
              ? 'محطة أهلية'
              : station.stationType,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _isGovernment(station)
              ? BitmapDescriptor.hueAzure
              : BitmapDescriptor.hueOrange,
        ),
      ),
    )
        .toSet();
  }

  CameraPosition _initialCamera(
      List<Station> stations,
      ) {
    final valid = stations
        .where(_hasCoordinates)
        .toList();

    if (valid.isEmpty) {
      return const CameraPosition(
        target: LatLng(
          33.3152,
          44.3661,
        ),
        zoom: 6,
      );
    }

    var latitude = 0.0;
    var longitude = 0.0;

    for (final station in valid) {
      latitude += station.latitude;
      longitude += station.longitude;
    }

    return CameraPosition(
      target: LatLng(
        latitude / valid.length,
        longitude / valid.length,
      ),
      zoom: valid.length == 1 ? 13 : 8,
    );
  }

  Future<Uint8List> _buildPdf(
      List<Station> stations,
      ) async {
    final regularFont =
    await PdfGoogleFonts.notoSansArabicRegular();

    final boldFont =
    await PdfGoogleFonts.notoSansArabicBold();

    final pdf = pw.Document();
    final auth = AuthService.instance;
    final user = auth.currentUser;

    final government =
    stations.where(_isGovernment).toList();

    final privateStations =
    stations.where(_isPrivate).toList();

    final now = DateTime.now();
    final dateText =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';

    final scopeText = auth.isAdmin
        ? 'جميع الفروع'
        : (user?.branchName.trim().isNotEmpty == true
        ? 'فرع ${user!.branchName.trim()}'
        : 'الفرع الحالي');

    pw.Widget cell(
        String text, {
          bool header = false,
        }) {
      return pw.Container(
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 6,
        ),
        child: pw.Text(
          text,
          textDirection: pw.TextDirection.rtl,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: header ? boldFont : regularFont,
            fontSize: header ? 9 : 8,
          ),
        ),
      );
    }

    pw.Widget stationTable(
        String title,
        List<Station> data,
        ) {
      return pw.Column(
        crossAxisAlignment:
        pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            title,
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 13,
            ),
          ),
          pw.SizedBox(height: 7),
          if (data.isEmpty)
            pw.Text(
              'لا توجد محطات ضمن هذا القسم',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 9,
              ),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey500,
                width: .6,
              ),
              columnWidths: const {
                0: pw.FixedColumnWidth(34),
                1: pw.FlexColumnWidth(2.6),
                2: pw.FlexColumnWidth(1.6),
                3: pw.FlexColumnWidth(1.6),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [
                    cell('ت', header: true),
                    cell('اسم المحطة', header: true),
                    cell('خط العرض', header: true),
                    cell('خط الطول', header: true),
                  ],
                ),
                ...data.asMap().entries.map(
                      (entry) {
                    final station = entry.value;
                    return pw.TableRow(
                      children: [
                        cell('${entry.key + 1}'),
                        cell(station.name),
                        cell(
                          _coordinateText(
                            station.latitude,
                          ),
                        ),
                        cell(
                          _coordinateText(
                            station.longitude,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),
        textDirection: pw.TextDirection.rtl,
        header: (_) => pw.Column(
          children: [
            pw.Text(
              'شركة توزيع المنتجات النفطية',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 14,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              scopeText,
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 11,
              ),
            ),
            pw.Divider(),
          ],
        ),
        footer: (context) => pw.Center(
          child: pw.Text(
            'صفحة ${context.pageNumber} من '
                '${context.pagesCount}',
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8,
            ),
          ),
        ),
        build: (_) => [
          pw.Center(
            child: pw.Text(
              'تقرير إحداثيات المحطات',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 18,
              ),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Center(
            child: pw.Text(
              'تاريخ التقرير: $dateText',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 9,
              ),
            ),
          ),
          pw.SizedBox(height: 18),
          stationTable(
            'أولاً: إحداثيات المحطات الحكومية '
                '(${government.length})',
            government,
          ),
          pw.SizedBox(height: 22),
          stationTable(
            'ثانياً: إحداثيات المحطات الأهلية '
                '(${privateStations.length})',
            privateStations,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> _downloadPdf(
      List<Station> stations,
      ) async {
    try {
      final bytes = await _buildPdf(stations);

      await Printing.sharePdf(
        bytes: bytes,
        filename:
        'تقرير_إحداثيات_المحطات.pdf',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(
        'تعذر تجهيز ملف PDF\n$e',
      );
    }
  }

  Future<void> _printPdf(
      List<Station> stations,
      ) async {
    try {
      final bytes = await _buildPdf(stations);

      await Printing.layoutPdf(
        name: 'تقرير إحداثيات المحطات',
        onLayout: (_) async => bytes,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(
        'تعذر تجهيز التقرير للطباعة\n$e',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _stationTableSection({
    required String title,
    required List<Station> stations,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            color: Theme.of(context)
                .colorScheme
                .primaryContainer,
            child: Text(
              '$title (${stations.length})',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (stations.isEmpty)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Center(
                child: Text(
                  'لا توجد محطات ضمن هذا القسم',
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text('ت'),
                  ),
                  DataColumn(
                    label: Text(
                      'اسم المحطة',
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'خط العرض',
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'خط الطول',
                    ),
                  ),
                ],
                rows: stations
                    .asMap()
                    .entries
                    .map(
                      (entry) => DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '${entry.key + 1}',
                        ),
                      ),
                      DataCell(
                        Text(
                          entry.value.name,
                        ),
                      ),
                      DataCell(
                        SelectableText(
                          _coordinateText(
                            entry.value.latitude,
                          ),
                        ),
                      ),
                      DataCell(
                        SelectableText(
                          _coordinateText(
                            entry.value.longitude,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _coordinatesTab(
      List<Station> stations,
      ) {
    final government =
    stations.where(_isGovernment).toList();

    final privateStations =
    stations.where(_isPrivate).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: stations.isEmpty
                    ? null
                    : () => _downloadPdf(
                  stations,
                ),
                icon: const Icon(
                  Icons.download,
                ),
                label: const Text(
                  'تنزيل PDF',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: stations.isEmpty
                    ? null
                    : () => _printPdf(
                  stations,
                ),
                icon: const Icon(
                  Icons.print,
                ),
                label: const Text(
                  'طباعة',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _stationTableSection(
          title:
          'إحداثيات المحطات الحكومية',
          stations: government,
        ),
        _stationTableSection(
          title:
          'إحداثيات المحطات الأهلية',
          stations: privateStations,
        ),
      ],
    );
  }

  Widget _roadFeatureTab(
      List<Station> stations,
      ) {
    final auth = AuthService.instance;
    final governorates =
    _governorates(stations);

    if (auth.isAdmin &&
        _selectedGovernorate == null &&
        governorates.isNotEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        if (!mounted ||
            _selectedGovernorate != null) {
          return;
        }

        setState(() {
          _selectedGovernorate =
              governorates.first;
        });
      });
    }

    final scopedStations =
    _stationsForRoadFeature(stations);

    final pairCount =
        _buildPairs(scopedStations).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (auth.isAdmin) ...[
          DropdownButtonFormField<String>(
            initialValue: _selectedGovernorate,            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'المحافظة',
              border: OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.map_outlined,
              ),
            ),
            items: governorates
                .map(
                  (name) =>
                  DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  ),
            )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedGovernorate = value;
                _roadDistances.clear();
                _routePolylines.clear();
                _routesError = null;
              });

              WidgetsBinding.instance
                  .addPostFrameCallback((_) {
                _fitMapToStations(
                  _stationsForRoadFeature(
                    stations,
                  ),
                );
              });
            },
          ),
          const SizedBox(height: 12),
        ] else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Text(
              'النطاق: ${AuthService.instance.currentUser?.branchName ?? 'الفرع الحالي'}',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 12),
        DropdownButtonFormField<_DistanceFilter>(
          initialValue: _distanceFilter,
          decoration: const InputDecoration(
            labelText: 'نوع المقارنة',
            border: OutlineInputBorder(),
            prefixIcon: Icon(
              Icons.compare_arrows,
            ),
          ),
          items: _DistanceFilter.values
              .map(
                (filter) =>
                DropdownMenuItem<_DistanceFilter>(
                  value: filter,
                  child: Text(
                    _filterLabel(filter),
                  ),
                ),
          )
              .toList(),
          onChanged: _routesLoading
              ? null
              : (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _distanceFilter = value;
              _roadDistances.clear();
              _routePolylines.clear();
              _routesError = null;
            });
          },
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(12),
          ),
          child: Text(
            'عدد المحطات بإحداثيات صالحة: '
                '${scopedStations.length}\n'
                'عدد المقارنات المطلوبة: $pairCount',
            textDirection: TextDirection.rtl,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _routesLoading ||
              scopedStations.length < 2
              ? null
              : () => _calculateRoadRoutes(
            stations,
          ),
          icon: _routesLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : const Icon(
            Icons.route,
          ),
          label: Text(
            _routesLoading
                ? 'جاري حساب مسافات الطرق...'
                : 'حساب المسافات عبر الشوارع',
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: scopedStations.isEmpty
              ? null
              : () => _exportHighResMapReport(scopedStations),
          icon: const Icon(Icons.download_rounded, color: Color(0xFF0758D8)),
          label: const Text('تنزيل الخريطة والمسافات كصورة عالي الدقة (HD/طباعة)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0758D8),
            side: const BorderSide(color: Color(0xFF0758D8), width: 1.5),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'ملاحظة: كل مقارنة ترسل طلب مسار إلى Google Maps، '
              'لذلك عدد كبير من المحطات يعني عدد طلبات أكبر.',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        if (_routesError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.shade200,
              ),
            ),
            child: Text(
              _routesError!,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.red.shade900,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 430,
            child: scopedStations.isEmpty
                ? const Center(
              child: Text(
                'لا توجد محطات بإحداثيات صالحة ضمن النطاق المختار',
                textAlign:
                TextAlign.center,
              ),
            )
                : GoogleMap(
              initialCameraPosition:
              _initialCamera(
                scopedStations,
              ),
              onMapCreated:
                  (controller) {
                _mapController =
                    controller;

                WidgetsBinding.instance
                    .addPostFrameCallback(
                      (_) => _fitMapToStations(
                    scopedStations,
                  ),
                );
              },
              markers: _buildMarkers(
                scopedStations,
              ),
              polylines:
              _routePolylines,
              myLocationButtonEnabled:
              false,
              mapToolbarEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: true,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                const EdgeInsets.all(14),
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                child: Text(
                  'مسافات الطرق - '
                      '${_filterLabel(_distanceFilter)} '
                      '(${_roadDistances.length})',
                  textDirection:
                  TextDirection.rtl,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (_roadDistances.isEmpty)
                const Padding(
                  padding:
                  EdgeInsets.all(18),
                  child: Text(
                    'اضغط "حساب المسافات عبر الشوارع" لإظهار النتائج.',
                    textAlign:
                    TextAlign.center,
                    textDirection:
                    TextDirection.rtl,
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection:
                  Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(
                        label: Text('ت'),
                      ),
                      DataColumn(
                        label: Text(
                          'من محطة',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'إلى محطة',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'المسافة عبر الطرق',
                        ),
                      ),
                    ],
                    rows: _roadDistances
                        .asMap()
                        .entries
                        .map(
                          (entry) {
                        final item =
                            entry.value;

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '${entry.key + 1}',
                              ),
                            ),
                            DataCell(
                              Text(
                                item.from.name,
                              ),
                            ),
                            DataCell(
                              Text(
                                item.to.name,
                              ),
                            ),
                            DataCell(
                              Text(
                                item.available &&
                                    item.distanceKm !=
                                        null
                                    ? '${item.distanceKm!.toStringAsFixed(2)} كم'
                                    : 'المسار غير متاح',
                              ),
                            ),
                          ],
                        );
                      },
                    )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;

    if (!auth.isAdmin &&
        !auth.isBranchManager) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'تقرير إحداثيات المحطات',
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'هذا التقرير متاح فقط لمدير النظام ومدير الفرع',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      const Color(0xffF4F6FA),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'تقرير إحداثيات المحطات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(
                Icons.table_chart_outlined,
              ),
              text: 'جدول الإحداثيات',
            ),
            Tab(
              icon: Icon(
                Icons.route_outlined,
              ),
              text: 'خريطة ومسافات الطرق',
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Station>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            );
          }

          final stations =
              snapshot.data ?? <Station>[];

          return TabBarView(
            controller: _tabController,
            children: [
              _coordinatesTab(stations),
              _roadFeatureTab(stations),
            ],
          );
        },
      ),
    );
  }
}

class _StationPair {
  final Station first;
  final Station second;

  const _StationPair({
    required this.first,
    required this.second,
  });
}

class _RoadDistance {
  final Station from;
  final Station to;
  final double? distanceKm;
  final bool available;

  const _RoadDistance({
    required this.from,
    required this.to,
    required this.distanceKm,
    required this.available,
  });
}