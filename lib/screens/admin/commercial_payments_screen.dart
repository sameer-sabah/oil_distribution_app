import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../services/commercial_payment_settings_service.dart';
import '../../services/commercial_service.dart';

class CommercialPaymentsScreen extends StatefulWidget {
  const CommercialPaymentsScreen({super.key});

  @override
  State<CommercialPaymentsScreen> createState() =>
      _CommercialPaymentsScreenState();
}

class _CommercialPaymentsScreenState
    extends State<CommercialPaymentsScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final ScrollController _horizontalController = ScrollController();
  final Set<String> _busyPaymentIds = <String>{};

  late final Stream<DatabaseEvent> _paymentsStream;
  Future<List<_CommercialPaymentRow>> _rowsFuture =
  Future<List<_CommercialPaymentRow>>.value(
    <_CommercialPaymentRow>[],
  );

  String _paymentsSignature = '';
  bool _paymentsInitialized = false;
  bool _printing = false;

  @override
  void initState() {
    super.initState();
    _paymentsStream = _firebaseEvents(
      _database.ref('commercialPayments'),
    );
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  Stream<DatabaseEvent> _firebaseEvents(Query query) {
    return Stream<DatabaseEvent>.multi((controller) {
      final subscription = query.onValue.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onCancel = subscription.cancel;
    }, isBroadcast: true);
  }

  List<Map<String, dynamic>> _paymentMaps(Object? value) {
    if (value is! Map) {
      return <Map<String, dynamic>>[];
    }

    final raw = Map<dynamic, dynamic>.from(value);
    final payments = <Map<String, dynamic>>[];

    for (final entry in raw.entries) {
      if (entry.value is! Map) {
        continue;
      }

      final payment = Map<String, dynamic>.from(
        entry.value as Map,
      );
      payment['id'] = entry.key.toString();
      payments.add(payment);
    }

    payments.sort((a, b) {
      return (b['createdAt'] ?? '').toString().compareTo(
        (a['createdAt'] ?? '').toString(),
      );
    });

    return payments;
  }

  String _signatureFor(List<Map<String, dynamic>> payments) {
    return payments.map((payment) {
      return <Object?>[
        payment['id'],
        payment['amount'],
        payment['method'],
        payment['status'],
        payment['durationDays'],
        payment['pricePerDay'],
        payment['businessName'],
        payment['ownerName'],
        payment['confirmedAt'],
      ].join('|');
    }).join('||');
  }

  void _prepareRows(List<Map<String, dynamic>> payments) {
    final signature = _signatureFor(payments);
    if (_paymentsInitialized && signature == _paymentsSignature) {
      return;
    }

    _paymentsInitialized = true;
    _paymentsSignature = signature;
    _rowsFuture = _loadRows(payments);
  }

  Future<List<_CommercialPaymentRow>> _loadRows(
      List<Map<String, dynamic>> payments,
      ) async {
    final settings = await CommercialPaymentSettingsService
        .instance
        .getSettings();

    final rows = await Future.wait(
      payments.map(
            (payment) => _buildRow(
          payment,
          settings.pricePerDay.toDouble(),
        ),
      ),
    );

    return rows;
  }

  Future<Map<String, dynamic>> _readMap(String path) async {
    if (path.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final snapshot = await _database.ref(path).get();
      if (snapshot.value is Map) {
        return Map<String, dynamic>.from(
          snapshot.value as Map,
        );
      }
    } catch (error) {
      debugPrint('تعذر قراءة $path: $error');
    }

    return <String, dynamic>{};
  }

  Future<_CommercialPaymentRow> _buildRow(
      Map<String, dynamic> payment,
      double configuredPricePerDay,
      ) async {
    final id = payment['id']?.toString() ?? '';
    final ownerUid = payment['ownerUid']?.toString() ?? '';
    final entityType = payment['entityType']?.toString() ?? 'ad';
    final entityId = payment['entityId']?.toString() ?? '';

    final entityPath = entityType == 'ad'
        ? 'commercialAds/$entityId'
        : 'commercialServices/$entityId';

    final results = await Future.wait<Map<String, dynamic>>([
      _readMap(entityPath),
      ownerUid.isEmpty
          ? Future<Map<String, dynamic>>.value(
        <String, dynamic>{},
      )
          : _readMap('advertiserAccounts/$ownerUid'),
    ]);

    final entity = results[0];
    final account = results[1];

    final businessName = _firstNonEmpty([
      payment['businessName'],
      entity['businessName'],
      account['businessName'],
      payment['entityTitle'],
      entityType == 'ad' ? entity['title'] : entity['name'],
      'غير محدد',
    ]);

    final ownerName = _firstNonEmpty([
      payment['ownerName'],
      entity['ownerName'],
      account['fullName'],
      ownerUid,
      'غير معروف',
    ]);

    int durationDays = _toInt(payment['durationDays']);
    if (durationDays <= 0) {
      durationDays = _toInt(entity['durationDays']);
    }
    if (durationDays <= 0) {
      final start = DateTime.tryParse(
        entity['startAt']?.toString() ?? '',
      );
      final end = DateTime.tryParse(
        entity['endAt']?.toString() ?? '',
      );
      if (start != null && end != null) {
        durationDays = end.difference(start).inDays;
      }
    }
    if (durationDays <= 0) {
      durationDays = 1;
    }

    final storedAmount = _toDouble(payment['amount']);
    double pricePerDay = _toDouble(payment['pricePerDay']);
    if (pricePerDay <= 0 && storedAmount > 0) {
      pricePerDay = storedAmount / durationDays;
    }
    if (pricePerDay <= 0) {
      pricePerDay = configuredPricePerDay;
    }

    final calculatedAmount = durationDays * pricePerDay;
    final amount = calculatedAmount > 0
        ? calculatedAmount
        : storedAmount;

    return _CommercialPaymentRow(
      id: id,
      entityType: entityType,
      entityId: entityId,
      businessName: businessName,
      ownerName: ownerName,
      durationDays: durationDays,
      pricePerDay: pricePerDay,
      amount: amount,
      method: payment['method']?.toString() ?? '',
      status: payment['status']?.toString() ?? '',
    );
  }

  String _firstNonEmpty(Iterable<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  int _toInt(Object? value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(Object? value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _money(num value) {
    final digits = value.round().toString();
    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
    );
    return '$formatted د.ع';
  }

  String _entityTypeLabel(String entityType) {
    return entityType == 'ad' ? 'إعلان' : 'خدمة';
  }

  String _paymentMethodLabel(String method) {
    final clean = method.trim();
    if (clean.isEmpty) {
      return 'لم تُحدد';
    }

    final lower = clean.toLowerCase();
    if (lower.contains('zain') || lower.contains('زين')) {
      return 'زين كاش';
    }

    return clean;
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'awaiting_payment':
        return 'بانتظار الدفع';
      case 'submitted':
        return 'بانتظار التأكيد';
      case 'paid':
        return 'مدفوعة';
      case 'rejected':
        return 'مرفوضة';
      default:
        return status.trim().isEmpty ? 'غير محددة' : status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'submitted':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  double _paidTotal(List<_CommercialPaymentRow> rows) {
    return rows
        .where((row) => row.status == 'paid')
        .fold<double>(
      0,
          (sum, row) => sum + row.amount,
    );
  }

  Future<void> _confirmPayment(
      _CommercialPaymentRow row,
      ) async {
    if (_busyPaymentIds.contains(row.id)) {
      return;
    }

    setState(() {
      _busyPaymentIds.add(row.id);
    });

    try {
      await CommercialService.instance.confirmPaymentAndPublish(
        entityType: row.entityType,
        entityId: row.entityId,
      );
      await _database
          .ref('commercialPayments/${row.id}')
          .update({
        'status': 'paid',
        'confirmedAt': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تأكيد الدفع ونشر المحتوى'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر تأكيد الدفع: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyPaymentIds.remove(row.id);
        });
      }
    }
  }

  Future<void> _deletePayment(
      _CommercialPaymentRow row,
      ) async {
    if (_busyPaymentIds.contains(row.id)) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف سجل الدفع'),
        content: Text(
          'هل تريد حذف إعلان/خدمة ${row.businessName} نهائياً؟\n'
              'سيُحذف المحتوى وسجل الدفع من قاعدة البيانات، وسيختفي الإعلان من جميع شاشات العرض مباشرة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_forever),
            label: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final entityId = row.entityId.trim();
    if (entityId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر الحذف: معرّف الإعلان أو الخدمة غير موجود',
          ),
        ),
      );
      return;
    }

    setState(() {
      _busyPaymentIds.add(row.id);
    });

    try {
      final entityPath = row.entityType == 'ad'
          ? 'commercialAds/$entityId'
          : 'commercialServices/$entityId';

      await _database.ref().update({
        'commercialPayments/${row.id}': null,
        entityPath: null,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حذف المحتوى وسجل الدفع من قاعدة البيانات',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر حذف سجل الدفع: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyPaymentIds.remove(row.id);
        });
      }
    }
  }

  Future<void> _printReport(
      List<_CommercialPaymentRow> rows,
      ) async {
    if (rows.isEmpty || _printing) {
      return;
    }

    setState(() {
      _printing = true;
    });

    try {
      final regularFont =
      await PdfGoogleFonts.notoSansArabicRegular();
      final boldFont =
      await PdfGoogleFonts.notoSansArabicBold();
      final pdf = pw.Document();
      final total = _paidTotal(rows);
      final now = DateTime.now();
      final dateText =
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/'
          '${now.year}';

      pw.Widget cell(
          String text, {
            bool header = false,
          }) {
        return pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
          child: pw.Text(
            text,
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              font: header ? boldFont : regularFont,
              fontSize: header ? 8.5 : 7.5,
            ),
          ),
        );
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(26),
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
                  fontSize: 13,
                ),
              ),
              pw.Divider(),
            ],
          ),
          footer: (context) => pw.Center(
            child: pw.Text(
              'صفحة ${context.pageNumber} من ${context.pagesCount}',
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
                'تقرير مدفوعات الإعلانات والخدمات',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 17,
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
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey500,
                width: .6,
              ),
              columnWidths: const {
                0: pw.FixedColumnWidth(28),
                1: pw.FlexColumnWidth(2.2),
                2: pw.FlexColumnWidth(1.8),
                3: pw.FlexColumnWidth(.7),
                4: pw.FlexColumnWidth(1.5),
                5: pw.FlexColumnWidth(1.2),
                6: pw.FlexColumnWidth(1.1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [
                    cell('ت', header: true),
                    cell('اسم الشركة أو المتجر', header: true),
                    cell('اسم صاحب الشركة', header: true),
                    cell('عدد الأيام', header: true),
                    cell('المبلغ', header: true),
                    cell('نوع الدفع', header: true),
                    cell('الحالة', header: true),
                  ],
                ),
                ...rows.asMap().entries.map((entry) {
                  final row = entry.value;
                  return pw.TableRow(
                    children: [
                      cell('${entry.key + 1}'),
                      cell(
                        '${row.businessName}\n'
                            '(${_entityTypeLabel(row.entityType)})',
                      ),
                      cell(row.ownerName),
                      cell('${row.durationDays}'),
                      cell(
                        '${_money(row.amount)}\n'
                            '${_money(row.pricePerDay)} × '
                            '${row.durationDays}',
                      ),
                      cell(_paymentMethodLabel(row.method)),
                      cell(_statusLabel(row.status)),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey600,
                ),
              ),
              child: pw.Text(
                'إجمالي المبالغ المدفوعة: ${_money(total)}',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      await Printing.layoutPdf(
        name: 'تقرير مدفوعات الإعلانات والخدمات',
        onLayout: (_) async => bytes,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(
            'تعذر تجهيز تقرير الطباعة: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _printing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدفوعات الإعلانات والخدمات'),
        centerTitle: true,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _paymentsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'تعذر تحميل المدفوعات:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final payments = _paymentMaps(
            snapshot.data?.snapshot.value,
          );
          _prepareRows(payments);

          return FutureBuilder<List<_CommercialPaymentRow>>(
            future: _rowsFuture,
            builder: (context, rowsSnapshot) {
              if (rowsSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'تعذر تجهيز جدول المدفوعات:\n'
                          '${rowsSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (rowsSnapshot.connectionState ==
                  ConnectionState.waiting &&
                  !rowsSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final rows = rowsSnapshot.data ??
                  <_CommercialPaymentRow>[];
              return _buildTablePage(rows);
            },
          );
        },
      ),
    );
  }

  Widget _buildTablePage(List<_CommercialPaymentRow> rows) {
    final total = _paidTotal(rows);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سجل المدفوعات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('عدد السجلات: ${rows.length}'),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: rows.isEmpty || _printing
                    ? null
                    : () => _printReport(rows),
                icon: _printing
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.print),
                label: Text(
                  _printing
                      ? 'جارٍ التجهيز...'
                      : 'طباعة التقرير',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (rows.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text('لا توجد عمليات دفع'),
                    ),
                  ),
                )
              else
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth < 1080
                          ? 1080.0
                          : constraints.maxWidth;

                      return Scrollbar(
                        controller: _horizontalController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _horizontalController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: width,
                            child: DataTable(
                              headingRowColor:
                              WidgetStatePropertyAll<Color>(
                                Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              columnSpacing: 22,
                              horizontalMargin: 14,
                              dataRowMinHeight: 58,
                              dataRowMaxHeight: 76,
                              columns: const [
                                DataColumn(label: Text('ت')),
                                DataColumn(
                                  label: Text('اسم الشركة أو المتجر'),
                                ),
                                DataColumn(
                                  label: Text('اسم صاحب الشركة'),
                                ),
                                DataColumn(
                                  numeric: true,
                                  label: Text('عدد الأيام'),
                                ),
                                DataColumn(
                                  numeric: true,
                                  label: Text('المبلغ'),
                                ),
                                DataColumn(label: Text('نوع الدفع')),
                                DataColumn(label: Text('الحالة')),
                                DataColumn(label: Text('حذف/إجراء')),
                              ],
                              rows: rows.asMap().entries.map((entry) {
                                return _dataRow(
                                  entry.key + 1,
                                  entry.value,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(Icons.calculate_rounded),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'إجمالي المبالغ المدفوعة',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _money(total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _dataRow(
      int index,
      _CommercialPaymentRow row,
      ) {
    final busy = _busyPaymentIds.contains(row.id);

    return DataRow(
      cells: [
        DataCell(Text('$index')),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.businessName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _entityTypeLabel(row.entityType),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          SizedBox(
            width: 155,
            child: Text(
              row.ownerName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text('${row.durationDays}')),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(row.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_money(row.pricePerDay)} × '
                    '${row.durationDays}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(_paymentMethodLabel(row.method))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _statusColor(row.status)
                  .withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _statusColor(row.status)
                    .withValues(alpha: .45),
              ),
            ),
            child: Text(
              _statusLabel(row.status),
              style: TextStyle(
                color: _statusColor(row.status),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          busy
              ? const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (row.status == 'submitted')
                IconButton(
                  tooltip: 'تأكيد الدفع والنشر',
                  onPressed: () => _confirmPayment(row),
                  icon: const Icon(
                    Icons.verified,
                    color: Colors.green,
                  ),
                ),
              IconButton(
                tooltip: 'حذف سجل الدفع',
                onPressed: () => _deletePayment(row),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommercialPaymentRow {
  final String id;
  final String entityType;
  final String entityId;
  final String businessName;
  final String ownerName;
  final int durationDays;
  final double pricePerDay;
  final double amount;
  final String method;
  final String status;

  const _CommercialPaymentRow({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.businessName,
    required this.ownerName,
    required this.durationDays,
    required this.pricePerDay,
    required this.amount,
    required this.method,
    required this.status,
  });
}
