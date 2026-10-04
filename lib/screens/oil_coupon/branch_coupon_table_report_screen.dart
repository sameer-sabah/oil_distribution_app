import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/vehicle_coupon.dart';
import '../../models/fueling_log.dart';

class BranchCouponTableReportScreen extends StatefulWidget {
  final bool isGovernment;
  final List<VehicleCoupon> vehicles;
  final List<FuelingLog> logs;
  final String? initialMonth;

  const BranchCouponTableReportScreen({
    super.key,
    required this.isGovernment,
    required this.vehicles,
    required this.logs,
    this.initialMonth,
  });

  @override
  State<BranchCouponTableReportScreen> createState() => _BranchCouponTableReportScreenState();
}

class _BranchCouponTableReportScreenState extends State<BranchCouponTableReportScreen> {
  late String _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth ?? DateTime.now().toIso8601String().substring(0, 7); // e.g. "2026-09"
  }

  List<String> get _availableMonths {
    final Set<String> months = {};
    months.add(DateTime.now().toIso8601String().substring(0, 7));
    for (final l in widget.logs) {
      if (l.createdAt.length >= 7) {
        months.add(l.createdAt.substring(0, 7));
      }
    }
    final list = months.toList();
    list.sort((a, b) => b.compareTo(a)); // descending
    return list;
  }

  double _getConsumedForVehicle(String vehicleId) {
    return widget.logs
        .where((l) => l.vehicleId == vehicleId && l.createdAt.startsWith(_selectedMonth))
        .fold<double>(0.0, (sum, l) => sum + l.quantity);
  }

  Future<void> _exportPdfReport(BuildContext context) async {
    try {
      final categoryTitle = widget.isGovernment ? 'الموقف الشهري للسيارات الحكومية' : 'الموقف الشهري للسيارات الخصوصية';
      final pdf = pw.Document();

      final font = await PdfGoogleFonts.cairoRegular();
      final fontBold = await PdfGoogleFonts.cairoBold();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pw.PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('$categoryTitle - لشهر: $_selectedMonth', style: pw.TextStyle(font: fontBold, fontSize: 16)),
                    pw.Text('تاريخ التقرير: ${DateTime.now().toIso8601String().substring(0, 10)}', style: pw.TextStyle(font: font, fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['ت', 'رقم السيارة', 'نوع السيارة', 'اسم صاحب السيارة / الجهة', 'الحصة المقررة', 'المصروف', 'الباقي', 'الملاحظات'],
                  ...List.generate(widget.vehicles.length, (index) {
                    final v = widget.vehicles[index];
                    final consumed = _getConsumedForVehicle(v.id);
                    final remaining = (v.allowedQuantity - consumed).clamp(0.0, v.allowedQuantity);
                    return <String>[
                      '${index + 1}',
                      v.plateFull,
                      '${v.vehicleType} - ${v.vehicleModelName}',
                      v.ownerName,
                      '${v.allowedQuantity.toStringAsFixed(0)} لتر',
                      '${consumed.toStringAsFixed(0)} لتر',
                      '${remaining.toStringAsFixed(0)} لتر',
                      widget.isGovernment ? 'حصة شهرية' : 'كل ${v.intervalDays} أيام',
                    ];
                  }),
                ],
                headerStyle: pw.TextStyle(font: fontBold, fontSize: 9, color: pw.PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: pw.PdfColors.blue900),
                cellStyle: pw.TextStyle(font: font, fontSize: 8),
                cellAlignment: pw.Alignment.centerRight,
                cellPadding: const pw.EdgeInsets.all(5),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (pw.PdfPageFormat format) async => pdf.save(),
        name: 'coupon_report_$_selectedMonth.pdf',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تصدير ملف PDF: $e')),
      );
    }
  }

  @override
  Widget build(context) {
    final title = widget.isGovernment ? 'موقف شهري للسيارات الحكومية' : 'موقف شهري للسيارات الخصوصية';

    return Scaffold(
      appBar: AppBar(
        title: Text('$title - $_selectedMonth'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تنزيل وطباعة التقرير (PDF - من اليمين لليسار)',
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: () => _exportPdfReport(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade900,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'اختر شهر التقرير:',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: _availableMonths.contains(_selectedMonth) ? _selectedMonth : _availableMonths.first,
                    underline: const SizedBox.shrink(),
                    items: _availableMonths.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(m, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMonth = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Report Title Header inside page
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '$title لشهر: $_selectedMonth',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
          ),

          // DataTable
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.blue.shade800),
                  headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columns: const [
                    DataColumn(label: Text('ت')),
                    DataColumn(label: Text('رقم السيارة')),
                    DataColumn(label: Text('نوع السيارة')),
                    DataColumn(label: Text('اسم صاحب السيارة / الجهة')),
                    DataColumn(label: Text('الحصة المقررة')),
                    DataColumn(label: Text('الحصة المصروفة (الشهر)')),
                    DataColumn(label: Text('الباقي')),
                    DataColumn(label: Text('الملاحظات')),
                  ],
                  rows: List.generate(widget.vehicles.length, (index) {
                    final v = widget.vehicles[index];
                    final consumed = _getConsumedForVehicle(v.id);
                    final remaining = (v.allowedQuantity - consumed).clamp(0.0, v.allowedQuantity);

                    return DataRow(
                      cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(v.plateFull, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('${v.vehicleType} - ${v.vehicleModelName}')),
                        DataCell(Text(v.ownerName)),
                        DataCell(Text('${v.allowedQuantity.toStringAsFixed(0)} لتر')),
                        DataCell(Text('${consumed.toStringAsFixed(0)} لتر', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
                        DataCell(Text('${remaining.toStringAsFixed(0)} لتر', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                        DataCell(Text(widget.isGovernment ? 'حصة شهرية' : 'كل ${v.intervalDays} أيام')),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
