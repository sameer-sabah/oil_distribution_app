import 'dart:io';

import 'package:excel/excel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/station.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'station_coordinates_report_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  // =========================================================
  // إنشاء PDF
  // =========================================================

  Future<pw.Document> _createPdf(
      List<Station> stations,
      ) async {
    final regular =
    stations.fold<int>(0, (sum, s) => sum + s.regular95);

    final improved =
    stations.fold<int>(0, (sum, s) => sum + s.improved95);

    final diesel =
    stations.fold<int>(0, (sum, s) => sum + s.diesel);

    final white =
    stations.fold<int>(0, (sum, s) => sum + s.whiteOil);

    final totalFuel =
        regular + improved + diesel + white;

    final approved =
        stations.where((s) => s.approved).length;

    final notApproved =
        stations.where((s) => !s.approved).length;

    final sorted = [...stations];

    sorted.sort((a, b) {
      final aFuel =
          a.regular95 +
              a.improved95 +
              a.diesel +
              a.whiteOil;

      final bFuel =
          b.regular95 +
              b.improved95 +
              b.diesel +
              b.whiteOil;

      return bFuel.compareTo(aFuel);
    });

    final topFive = sorted.take(5).toList();
    final bottomFive = sorted.reversed.take(5).toList();

    final Map<String, int> governorates = {};

    for (final station in stations) {
      final name = station.governorate.trim().isEmpty
          ? 'غير محدد'
          : station.governorate.trim();

      governorates[name] =
          (governorates[name] ?? 0) + 1;
    }

    final regularFont =
    await PdfGoogleFonts.notoSansArabicRegular();

    final boldFont =
    await PdfGoogleFonts.notoSansArabicBold();

    final pdf = pw.Document();

    final titleStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 18,
    );

    final sectionStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 13,
    );

    final bodyStyle = pw.TextStyle(
      font: regularFont,
      fontSize: 9,
    );

    final headerStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 9,
    );

    final now = DateTime.now();

    final dateText =
        '${now.day.toString().padLeft(2, '0')} / '
        '${now.month.toString().padLeft(2, '0')} / '
        '${now.year}';

    pw.Widget cell(
        String text, {
          bool header = false,
        }) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(5),
        alignment: pw.Alignment.center,
        child: pw.Text(
          text,
          textDirection: pw.TextDirection.rtl,
          style: header ? headerStyle : bodyStyle,
        ),
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

        header: (context) {
          return pw.Column(
            children: [
              pw.Text(
                'شركة توزيع المنتجات النفطية',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 15,
                ),
              ),
              pw.Text(
                'فرع الأنبار',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 13,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Divider(),
            ],
          );
        },

        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              'صفحة ${context.pageNumber} من ${context.pagesCount}',
              textDirection: pw.TextDirection.rtl,
              style: bodyStyle,
            ),
          );
        },

        build: (context) {
          return [
            pw.Center(
              child: pw.Text(
                'تقرير التقارير والإحصائيات',
                textDirection: pw.TextDirection.rtl,
                style: titleStyle,
              ),
            ),

            pw.SizedBox(height: 5),

            pw.Center(
              child: pw.Text(
                'تاريخ التقرير: $dateText',
                textDirection: pw.TextDirection.rtl,
                style: bodyStyle,
              ),
            ),

            pw.SizedBox(height: 18),

            pw.Text(
              'ملخص حالة المحطات',
              textDirection: pw.TextDirection.rtl,
              style: sectionStyle,
            ),

            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey,
              ),
              children: [
                pw.TableRow(
                  children: [
                    cell('إجمالي المحطات', header: true),
                    cell('الموافق عليها', header: true),
                    cell('غير الموافق عليها', header: true),
                  ],
                ),
                pw.TableRow(
                  children: [
                    cell('${stations.length}'),
                    cell('$approved'),
                    cell('$notApproved'),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 18),

            pw.Text(
              'كميات المنتجات النفطية',
              textDirection: pw.TextDirection.rtl,
              style: sectionStyle,
            ),

            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey,
              ),
              children: [
                pw.TableRow(
                  children: [
                    cell('المنتوج', header: true),
                    cell('الكمية باللتر', header: true),
                  ],
                ),
                pw.TableRow(
                  children: [
                    cell('البنزين العادي'),
                    cell('$regular'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    cell('البنزين المحسن'),
                    cell('$improved'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    cell('زيت الغاز'),
                    cell('$diesel'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    cell('النفط الأبيض'),
                    cell('$white'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    cell('الإجمالي', header: true),
                    cell('$totalFuel', header: true),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 18),

            _pdfRankingTable(
              title: 'أفضل 5 محطات من حيث المخزون',
              stations: topFive,
              bodyStyle: bodyStyle,
              headerStyle: headerStyle,
            ),

            pw.SizedBox(height: 18),

            _pdfRankingTable(
              title: 'أقل 5 محطات من حيث المخزون',
              stations: bottomFive,
              bodyStyle: bodyStyle,
              headerStyle: headerStyle,
            ),

            pw.SizedBox(height: 18),

            pw.Text(
              'الإحصائيات حسب المحافظة',
              textDirection: pw.TextDirection.rtl,
              style: sectionStyle,
            ),

            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey,
              ),
              children: [
                pw.TableRow(
                  children: [
                    cell('المحافظة', header: true),
                    cell('عدد المحطات', header: true),
                  ],
                ),
                ...governorates.entries.map(
                      (entry) {
                    return pw.TableRow(
                      children: [
                        cell(entry.key),
                        cell('${entry.value}'),
                      ],
                    );
                  },
                ),
              ],
            ),

            pw.SizedBox(height: 28),

            pw.Row(
              mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'إعداد: مدير فرع الأنبار',
                  textDirection: pw.TextDirection.rtl,
                  style: bodyStyle,
                ),
                pw.Text(
                  'التوقيع: ______________',
                  textDirection: pw.TextDirection.rtl,
                  style: bodyStyle,
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _pdfRankingTable({
    required String title,
    required List<Station> stations,
    required pw.TextStyle bodyStyle,
    required pw.TextStyle headerStyle,
  }) {
    pw.Widget cell(String text, {bool header = false}) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(5),
        alignment: pw.Alignment.center,
        child: pw.Text(
          text,
          textDirection: pw.TextDirection.rtl,
          style: header ? headerStyle : bodyStyle,
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          title,
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(
            font: headerStyle.font,
            fontSize: 13,
          ),
        ),
        pw.SizedBox(height: 8),
        if (stations.isEmpty)
          pw.Text(
            'لا توجد بيانات',
            textDirection: pw.TextDirection.rtl,
            style: bodyStyle,
          )
        else
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey,
            ),
            children: [
              pw.TableRow(
                children: [
                  cell('#', header: true),
                  cell('اسم المحطة', header: true),
                  cell('المحافظة', header: true),
                  cell('القضاء', header: true),
                  cell('المخزون', header: true),
                ],
              ),
              ...stations.asMap().entries.map(
                    (entry) {
                  final station = entry.value;

                  final fuel =
                      station.regular95 +
                          station.improved95 +
                          station.diesel +
                          station.whiteOil;

                  return pw.TableRow(
                    children: [
                      cell('${entry.key + 1}'),
                      cell(station.name),
                      cell(station.governorate),
                      cell(station.district),
                      cell('$fuel لتر'),
                    ],
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  // =========================================================
  // مشاركة PDF
  // =========================================================

  Future<void> _sharePdf(
      BuildContext context,
      List<Station> stations,
      ) async {
    try {
      _showLoading(
        context,
        'جاري إنشاء تقرير PDF...',
      );

      final pdf = await _createPdf(stations);
      final bytes = await pdf.save();

      final directory =
      await getTemporaryDirectory();

      final file = File(
        '${directory.path}/'
            'تقرير_احصائيات_فرع_الانبار.pdf',
      );

      await file.writeAsBytes(bytes);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      await SharePlus.instance.share(
        ShareParams(
          title: 'تقرير إحصائيات فرع الأنبار',
          text:
          'تقرير التقارير والإحصائيات - فرع الأنبار',
          files: [
            XFile(
              file.path,
              mimeType: 'application/pdf',
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).maybePop();

        _showError(
          context,
          'تعذر إنشاء أو مشاركة PDF\n$e',
        );
      }
    }
  }

  // =========================================================
  // الطباعة = مشاركة PDF
  // =========================================================

  Future<void> _printReport(
      BuildContext context,
      List<Station> stations,
      ) async {
    try {
      _showLoading(
        context,
        'جاري تجهيز التقرير للطباعة...',
      );

      final pdf = await _createPdf(stations);
      final bytes = await pdf.save();

      final directory =
      await getTemporaryDirectory();

      final file = File(
        '${directory.path}/'
            'تقرير_جاهز_للطباعة_فرع_الانبار.pdf',
      );

      await file.writeAsBytes(bytes);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      await SharePlus.instance.share(
        ShareParams(
          title: 'تقرير جاهز للطباعة',
          text: 'تقرير فرع الأنبار جاهز للطباعة أو المشاركة',
          files: [
            XFile(
              file.path,
              mimeType: 'application/pdf',
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).maybePop();

        _showError(
          context,
          'تعذر تجهيز التقرير للطباعة\n$e',
        );
      }
    }
  }

  // =========================================================
  // إنشاء ومشاركة Excel
  // =========================================================

  Future<void> _shareExcel(
      BuildContext context,
      List<Station> stations,
      ) async {
    try {
      _showLoading(
        context,
        'جاري إنشاء ملف Excel...',
      );

      final excel = Excel.createExcel();

      // ---------------------------
      // ملخص
      // ---------------------------

      final summary = excel['ملخص'];

      _setText(
        summary,
        0,
        0,
        'شركة توزيع المنتجات النفطية - فرع الأنبار',
      );

      _setText(
        summary,
        1,
        0,
        'تقرير التقارير والإحصائيات',
      );

      _setText(summary, 3, 0, 'البيان');
      _setText(summary, 3, 1, 'القيمة');

      final approved =
          stations.where((s) => s.approved).length;

      final notApproved =
          stations.where((s) => !s.approved).length;

      final regular =
      stations.fold<int>(
        0,
            (sum, s) => sum + s.regular95,
      );

      final improved =
      stations.fold<int>(
        0,
            (sum, s) => sum + s.improved95,
      );

      final diesel =
      stations.fold<int>(
        0,
            (sum, s) => sum + s.diesel,
      );

      final white =
      stations.fold<int>(
        0,
            (sum, s) => sum + s.whiteOil,
      );

      final totalFuel =
          regular + improved + diesel + white;

      _setText(
        summary,
        4,
        0,
        'إجمالي المحطات',
      );
      _setInt(
        summary,
        4,
        1,
        stations.length,
      );

      _setText(
        summary,
        5,
        0,
        'الموافق عليها',
      );
      _setInt(
        summary,
        5,
        1,
        approved,
      );

      _setText(
        summary,
        6,
        0,
        'غير الموافق عليها',
      );
      _setInt(
        summary,
        6,
        1,
        notApproved,
      );

      _setText(
        summary,
        8,
        0,
        'البنزين العادي',
      );
      _setInt(summary, 8, 1, regular);

      _setText(
        summary,
        9,
        0,
        'البنزين المحسن',
      );
      _setInt(summary, 9, 1, improved);

      _setText(
        summary,
        10,
        0,
        'زيت الغاز',
      );
      _setInt(summary, 10, 1, diesel);

      _setText(
        summary,
        11,
        0,
        'النفط الأبيض',
      );
      _setInt(summary, 11, 1, white);

      _setText(
        summary,
        12,
        0,
        'إجمالي الوقود',
      );
      _setInt(summary, 12, 1, totalFuel);

      // ---------------------------
      // المحطات
      // ---------------------------

      final stationSheet =
      excel['المحطات'];

      final headers = [
        'اسم المحطة',
        'رقم الترخيص',
        'المحافظة',
        'القضاء',
        'الحالة',
        'الموافقة',
        'البنزين العادي',
        'البنزين المحسن',
        'زيت الغاز',
        'النفط الأبيض',
        'إجمالي المخزون',
      ];

      for (var i = 0;
      i < headers.length;
      i++) {
        _setText(
          stationSheet,
          0,
          i,
          headers[i],
        );
      }

      for (var i = 0;
      i < stations.length;
      i++) {
        final station = stations[i];
        final row = i + 1;

        final total =
            station.regular95 +
                station.improved95 +
                station.diesel +
                station.whiteOil;

        _setText(
          stationSheet,
          row,
          0,
          station.name,
        );

        _setText(
          stationSheet,
          row,
          1,
          station.stationLicense,
        );

        _setText(
          stationSheet,
          row,
          2,
          station.governorate,
        );

        _setText(
          stationSheet,
          row,
          3,
          station.district,
        );

        _setText(
          stationSheet,
          row,
          4,
          station.active
              ? 'عاملة'
              : 'متوقفة',
        );

        _setText(
          stationSheet,
          row,
          5,
          station.approved
              ? 'موافق عليها'
              : 'غير موافق عليها',
        );

        _setInt(
          stationSheet,
          row,
          6,
          station.regular95,
        );

        _setInt(
          stationSheet,
          row,
          7,
          station.improved95,
        );

        _setInt(
          stationSheet,
          row,
          8,
          station.diesel,
        );

        _setInt(
          stationSheet,
          row,
          9,
          station.whiteOil,
        );

        _setInt(
          stationSheet,
          row,
          10,
          total,
        );
      }

      // ---------------------------
      // كميات المنتجات
      // ---------------------------

      final fuelSheet =
      excel['كميات المنتجات'];

      _setText(
        fuelSheet,
        0,
        0,
        'المنتوج',
      );

      _setText(
        fuelSheet,
        0,
        1,
        'الكمية باللتر',
      );

      _setText(
        fuelSheet,
        1,
        0,
        'البنزين العادي',
      );
      _setInt(
        fuelSheet,
        1,
        1,
        regular,
      );

      _setText(
        fuelSheet,
        2,
        0,
        'البنزين المحسن',
      );
      _setInt(
        fuelSheet,
        2,
        1,
        improved,
      );

      _setText(
        fuelSheet,
        3,
        0,
        'زيت الغاز',
      );
      _setInt(
        fuelSheet,
        3,
        1,
        diesel,
      );

      _setText(
        fuelSheet,
        4,
        0,
        'النفط الأبيض',
      );
      _setInt(
        fuelSheet,
        4,
        1,
        white,
      );

      // ---------------------------
      // أفضل / أقل 5
      // ---------------------------

      final sorted = [...stations];

      sorted.sort((a, b) {
        final aFuel =
            a.regular95 +
                a.improved95 +
                a.diesel +
                a.whiteOil;

        final bFuel =
            b.regular95 +
                b.improved95 +
                b.diesel +
                b.whiteOil;

        return bFuel.compareTo(aFuel);
      });

      _writeRankingExcel(
        excel,
        'أفضل 5 محطات',
        sorted.take(5).toList(),
      );

      _writeRankingExcel(
        excel,
        'أقل 5 محطات',
        sorted.reversed.take(5).toList(),
      );

      // ---------------------------
      // المحافظات
      // ---------------------------

      final governorateSheet =
      excel['إحصائيات المحافظات'];

      _setText(
        governorateSheet,
        0,
        0,
        'المحافظة',
      );

      _setText(
        governorateSheet,
        0,
        1,
        'عدد المحطات',
      );

      final Map<String, int> governorates = {};

      for (final station in stations) {
        final name =
        station.governorate.trim().isEmpty
            ? 'غير محدد'
            : station.governorate.trim();

        governorates[name] =
            (governorates[name] ?? 0) + 1;
      }

      var row = 1;

      for (final entry
      in governorates.entries) {
        _setText(
          governorateSheet,
          row,
          0,
          entry.key,
        );

        _setInt(
          governorateSheet,
          row,
          1,
          entry.value,
        );

        row++;
      }

      final bytes = excel.save();

      if (bytes == null) {
        throw Exception(
          'تعذر إنشاء ملف Excel',
        );
      }

      final directory =
      await getTemporaryDirectory();

      final file = File(
        '${directory.path}/'
            'تقرير_احصائيات_فرع_الانبار.xlsx',
      );

      await file.writeAsBytes(bytes);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      await SharePlus.instance.share(
        ShareParams(
          title: 'تقرير Excel - فرع الأنبار',
          text:
          'تقرير إحصائيات فرع الأنبار',
          files: [
            XFile(
              file.path,
              mimeType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).maybePop();

        _showError(
          context,
          'تعذر إنشاء أو مشاركة Excel\n$e',
        );
      }
    }
  }

  // =========================================================
  // Excel helpers
  // =========================================================

  void _setText(
      Sheet sheet,
      int row,
      int column,
      String value,
      ) {
    sheet
        .cell(
      CellIndex.indexByColumnRow(
        columnIndex: column,
        rowIndex: row,
      ),
    )
        .value = TextCellValue(value);
  }

  void _setInt(
      Sheet sheet,
      int row,
      int column,
      int value,
      ) {
    sheet
        .cell(
      CellIndex.indexByColumnRow(
        columnIndex: column,
        rowIndex: row,
      ),
    )
        .value = IntCellValue(value);
  }

  void _writeRankingExcel(
      Excel excel,
      String name,
      List<Station> stations,
      ) {
    final sheet = excel[name];

    final headers = [
      '#',
      'اسم المحطة',
      'المحافظة',
      'القضاء',
      'المخزون',
    ];

    for (var i = 0;
    i < headers.length;
    i++) {
      _setText(
        sheet,
        0,
        i,
        headers[i],
      );
    }

    for (var i = 0;
    i < stations.length;
    i++) {
      final station = stations[i];

      final fuel =
          station.regular95 +
              station.improved95 +
              station.diesel +
              station.whiteOil;

      _setInt(
        sheet,
        i + 1,
        0,
        i + 1,
      );

      _setText(
        sheet,
        i + 1,
        1,
        station.name,
      );

      _setText(
        sheet,
        i + 1,
        2,
        station.governorate,
      );

      _setText(
        sheet,
        i + 1,
        3,
        station.district,
      );

      _setInt(
        sheet,
        i + 1,
        4,
        fuel,
      );
    }
  }

  // =========================================================
  // Loading / error
  // =========================================================

  void _showLoading(
      BuildContext context,
      String message,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  message,
                  textDirection:
                  TextDirection.rtl,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showError(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xffF4F6FA),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'التقارير والإحصائيات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder<List<Station>>(
        future:
        DatabaseService.instance.getStations(),

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
                padding:
                const EdgeInsets.all(20),
                child: Text(
                  snapshot.error.toString(),
                  textAlign:
                  TextAlign.center,
                  textDirection:
                  TextDirection.rtl,
                ),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد بيانات',
                style:
                TextStyle(fontSize: 22),
              ),
            );
          }

          final stations = snapshot.data!
              .where(
                (station) => station.active,
          )
              .toList();

          final totalStations =
              stations.length;

          final active = stations
              .where((e) => e.active)
              .length;

          final inactive = stations
              .where((e) => !e.active)
              .length;

          final approved = stations
              .where((e) => e.approved)
              .length;

          final notApproved = stations
              .where((e) => !e.approved)
              .length;

          final regular =
          stations.fold<int>(
            0,
                (a, b) => a + b.regular95,
          );

          final improved =
          stations.fold<int>(
            0,
                (a, b) => a + b.improved95,
          );

          final diesel =
          stations.fold<int>(
            0,
                (a, b) => a + b.diesel,
          );

          final white =
          stations.fold<int>(
            0,
                (a, b) => a + b.whiteOil,
          );

          final totalFuel =
              regular +
                  improved +
                  diesel +
                  white;

          final maxFuel = [
            regular.toDouble(),
            improved.toDouble(),
            diesel.toDouble(),
            white.toDouble(),
          ].reduce(
                (a, b) => a > b ? a : b,
          );

          stations.sort((a, b) {
            final fuelA =
                a.regular95 +
                    a.improved95 +
                    a.diesel +
                    a.whiteOil;

            final fuelB =
                b.regular95 +
                    b.improved95 +
                    b.diesel +
                    b.whiteOil;

            return fuelB.compareTo(fuelA);
          });

          return ListView(
            padding:
            const EdgeInsets.all(16),

            children: [
              if (AuthService.instance.isAdmin ||
                  AuthService.instance.isBranchManager) ...[
                Card(
                  margin: const EdgeInsets.only(
                    bottom: 18,
                  ),
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.location_on,
                      ),
                    ),
                    title: const Text(
                      'تقرير إحداثيات المحطات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'جدول منفصل للمحطات الحكومية والأهلية مع تنزيل PDF والطباعة',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const StationCoordinatesReportScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const Text(
                'لوحة التحكم',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
                children: [
                  reportCard(
                    'عدد المحطات',
                    '$totalStations',
                    Icons.local_gas_station,
                    Colors.blue,
                  ),
                  reportCard(
                    'المحطات العاملة',
                    '$active',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  reportCard(
                    'المحطات المتوقفة',
                    '$inactive',
                    Icons.cancel,
                    Colors.red,
                  ),
                  reportCard(
                    'الموافق عليها',
                    '$approved',
                    Icons.verified,
                    Colors.orange,
                  ),
                  reportCard(
                    'غير الموافق عليها',
                    '$notApproved',
                    Icons.warning,
                    Colors.deepOrange,
                  ),
                  reportCard(
                    'إجمالي الوقود',
                    '$totalFuel لتر',
                    Icons.oil_barrel,
                    Colors.indigo,
                  ),
                ],
              ),

              const SizedBox(height: 35),

              const Text(
                'توزيع المنتجات النفطية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 280,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 45,
                    sectionsSpace: 4,
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value:
                        regular.toDouble(),
                        title: 'عادي',
                        radius: 75,
                      ),
                      PieChartSectionData(
                        color: Colors.blue,
                        value:
                        improved.toDouble(),
                        title: 'محسن',
                        radius: 75,
                      ),
                      PieChartSectionData(
                        color: Colors.orange,
                        value:
                        diesel.toDouble(),
                        title: 'كاز',
                        radius: 75,
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value:
                        white.toDouble(),
                        title: 'أبيض',
                        radius: 75,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'مقارنة كميات الوقود',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment:
                    BarChartAlignment.spaceAround,
                    maxY: maxFuel <= 0
                        ? 10
                        : maxFuel * 1.2,
                    borderData:
                    FlBorderData(
                      show: false,
                    ),
                    gridData:
                    const FlGridData(
                      show: true,
                    ),
                    titlesData:
                    FlTitlesData(
                      rightTitles:
                      const AxisTitles(
                        sideTitles:
                        SideTitles(
                          showTitles: false,
                        ),
                      ),
                      topTitles:
                      const AxisTitles(
                        sideTitles:
                        SideTitles(
                          showTitles: false,
                        ),
                      ),
                      leftTitles:
                      const AxisTitles(
                        sideTitles:
                        SideTitles(
                          showTitles: true,
                        ),
                      ),
                      bottomTitles:
                      AxisTitles(
                        sideTitles:
                        SideTitles(
                          showTitles: true,
                          getTitlesWidget:
                              (value, meta) {
                            switch (
                            value.toInt()) {
                              case 0:
                                return const Text(
                                  'عادي',
                                );
                              case 1:
                                return const Text(
                                  'محسن',
                                );
                              case 2:
                                return const Text(
                                  'كاز',
                                );
                              case 3:
                                return const Text(
                                  'أبيض',
                                );
                              default:
                                return const SizedBox();
                            }
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      _barGroup(
                        0,
                        regular.toDouble(),
                        Colors.green,
                      ),
                      _barGroup(
                        1,
                        improved.toDouble(),
                        Colors.blue,
                      ),
                      _barGroup(
                        2,
                        diesel.toDouble(),
                        Colors.orange,
                      ),
                      _barGroup(
                        3,
                        white.toDouble(),
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'أفضل 5 محطات من حيث المخزون',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              ...stations.take(5).map(
                    (station) {
                  final fuel =
                      station.regular95 +
                          station.improved95 +
                          station.diesel +
                          station.whiteOil;

                  return Card(
                    elevation: 3,
                    child: ListTile(
                      leading:
                      const CircleAvatar(
                        child: Icon(
                          Icons.local_gas_station,
                        ),
                      ),
                      title:
                      Text(station.name),
                      subtitle: Text(
                        '${station.governorate} - ${station.district}',
                      ),
                      trailing: Text(
                        '$fuel لتر',
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          color:
                          Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              const Text(
                'كميات الوقود',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              fuelTile(
                'البنزين العادي',
                regular,
                Colors.green,
              ),

              fuelTile(
                'البنزين المحسن',
                improved,
                Colors.blue,
              ),

              fuelTile(
                'زيت الغاز',
                diesel,
                Colors.orange,
              ),

              fuelTile(
                'النفط الأبيض',
                white,
                Colors.red,
              ),

              const SizedBox(height: 35),

              const Text(
                'أقل 5 محطات من حيث المخزون',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              ...stations.reversed.take(5).map(
                    (station) {
                  final fuel =
                      station.regular95 +
                          station.improved95 +
                          station.diesel +
                          station.whiteOil;

                  return Card(
                    elevation: 3,
                    child: ListTile(
                      leading:
                      const CircleAvatar(
                        backgroundColor:
                        Colors.red,
                        child: Icon(
                          Icons.warning,
                          color: Colors.white,
                        ),
                      ),
                      title:
                      Text(station.name),
                      subtitle: Text(
                        '${station.governorate} - ${station.district}',
                      ),
                      trailing: Text(
                        '$fuel لتر',
                        style:
                        const TextStyle(
                          color: Colors.red,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 35),

              const Text(
                'إحصائيات حسب المحافظة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              ..._governorateStatistics(
                stations,
              ),

              const SizedBox(height: 35),

              // =================================================
              // أزرار التصدير والمشاركة
              // =================================================

              Row(
                children: [
                  Expanded(
                    child:
                    ElevatedButton.icon(
                      onPressed: () =>
                          _sharePdf(
                            context,
                            stations,
                          ),
                      icon: const Icon(
                        Icons.picture_as_pdf,
                      ),
                      label:
                      const Text('PDF'),
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.red,
                        foregroundColor:
                        Colors.white,
                        minimumSize:
                        const Size.fromHeight(
                          55,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child:
                    ElevatedButton.icon(
                      onPressed: () =>
                          _shareExcel(
                            context,
                            stations,
                          ),
                      icon: const Icon(
                        Icons.table_chart,
                      ),
                      label:
                      const Text('Excel'),
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.green,
                        foregroundColor:
                        Colors.white,
                        minimumSize:
                        const Size.fromHeight(
                          55,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 55,
                child:
                ElevatedButton.icon(
                  onPressed: () =>
                      _printReport(
                        context,
                        stations,
                      ),
                  icon: const Icon(
                    Icons.print,
                  ),
                  label: const Text(
                    'طباعة التقرير / مشاركة',
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget reportCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
              color.withValues(
                alpha: .15,
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(height: 12),

            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1.15,
                ),
              ),
            ),

            const SizedBox(height: 8),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fuelTile(
      String title,
      int value,
      Color color,
      ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(
            Icons.local_gas_station,
            color: Colors.white,
          ),
        ),
        title: Text(title),
        trailing: Text(
          '$value لتر',
          style: TextStyle(
            color: color,
            fontWeight:
            FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(
      int x,
      double value,
      Color color,
      ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 28,
          borderRadius:
          BorderRadius.circular(8),
        ),
      ],
    );
  }

  List<Widget> _governorateStatistics(
      List<Station> stations,
      ) {
    final Map<String, int> governorates = {};

    for (final station in stations) {
      final name =
      station.governorate.trim().isEmpty
          ? 'غير محدد'
          : station.governorate.trim();

      governorates[name] =
          (governorates[name] ?? 0) + 1;
    }

    return governorates.entries.map(
          (entry) {
        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.location_city,
              color: Colors.indigo,
            ),
            title: Text(entry.key),
            trailing: Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration:
              BoxDecoration(
                color:
                Colors.indigo.shade100,
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Text(
                '${entry.value} محطة',
                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    ).toList();
  }
}