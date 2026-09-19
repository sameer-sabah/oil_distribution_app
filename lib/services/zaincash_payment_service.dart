import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class ZainCashPaymentSession {
  final String paymentId;
  final String transactionId;
  final String redirectUrl;
  final String status;

  const ZainCashPaymentSession({
    required this.paymentId,
    required this.transactionId,
    required this.redirectUrl,
    required this.status,
  });

  factory ZainCashPaymentSession.fromMap(
      Map<String, dynamic> map,
      ) {
    return ZainCashPaymentSession(
      paymentId: map['paymentId']?.toString() ?? '',
      transactionId:
      map['transactionId']?.toString() ?? '',
      redirectUrl:
      map['redirectUrl']?.toString() ?? '',
      status: map['status']?.toString() ?? 'PENDING',
    );
  }
}

class ZainCashInquiryResult {
  final String paymentId;
  final String transactionId;
  final String status;
  final bool paid;

  const ZainCashInquiryResult({
    required this.paymentId,
    required this.transactionId,
    required this.status,
    required this.paid,
  });

  factory ZainCashInquiryResult.fromMap(
      Map<String, dynamic> map,
      ) {
    return ZainCashInquiryResult(
      paymentId: map['paymentId']?.toString() ?? '',
      transactionId:
      map['transactionId']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      paid: map['paid'] == true,
    );
  }
}

class ZainCashPaymentService {
  ZainCashPaymentService._();

  static final ZainCashPaymentService instance =
  ZainCashPaymentService._();

  FirebaseFunctions get _functions =>
      FirebaseFunctions.instance;

  Future<ZainCashPaymentSession> createPayment({
    required String entityType,
    required String entityId,
    required String language,
  }) async {
    final callable = _functions.httpsCallable(
      'zainCashCreatePayment',
    );

    final result = await callable.call(
      <String, dynamic>{
        'entityType': entityType,
        'entityId': entityId,
        'language': language,
      },
    );

    final data = Map<String, dynamic>.from(
      result.data as Map,
    );

    final session =
    ZainCashPaymentSession.fromMap(data);

    if (session.paymentId.isEmpty ||
        session.transactionId.isEmpty ||
        session.redirectUrl.isEmpty) {
      throw Exception(
        'استجابة ZainCash غير مكتملة',
      );
    }

    return session;
  }

  Future<void> openPaymentPage(
      String redirectUrl,
      ) async {
    final uri = Uri.tryParse(redirectUrl);

    if (uri == null) {
      throw Exception('رابط الدفع غير صالح');
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      throw Exception(
        'تعذر فتح صفحة الدفع في ZainCash',
      );
    }
  }

  Future<ZainCashInquiryResult> inquiry({
    required String paymentId,
  }) async {
    final callable = _functions.httpsCallable(
      'zainCashInquiry',
    );

    final result = await callable.call(
      <String, dynamic>{
        'paymentId': paymentId,
      },
    );

    return ZainCashInquiryResult.fromMap(
      Map<String, dynamic>.from(
        result.data as Map,
      ),
    );
  }
}
