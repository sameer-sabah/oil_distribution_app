import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PasswordResetRequestsScreen extends StatefulWidget {
  const PasswordResetRequestsScreen({super.key});

  @override
  State<PasswordResetRequestsScreen> createState() =>
      _PasswordResetRequestsScreenState();
}

class _PasswordResetRequestsScreenState
    extends State<PasswordResetRequestsScreen> {
  final DatabaseReference _requestsRef =
  FirebaseDatabase.instance.ref('passwordRequests');

  final DatabaseReference _usersRef =
  FirebaseDatabase.instance.ref('users');

  final Set<String> _busyRequests = <String>{};

  String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _whatsAppPhone(String value) {
    var digits = _normalizePhone(value);

    if (digits.startsWith('00964')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('07')) {
      digits = '964${digits.substring(1)}';
    } else if (digits.startsWith('7')) {
      digits = '964$digits';
    }

    return digits;
  }

  Future<Map<String, dynamic>?> _findUserForRequest(
      Map<String, dynamic> request,
      ) async {
    final username =
        request['username']?.toString().trim() ?? '';
    final phone =
    _normalizePhone(
      request['phone']?.toString().trim() ?? '',
    );

    if (username.isEmpty) {
      return null;
    }

    final snapshot = await _usersRef.get();

    if (!snapshot.exists ||
        snapshot.value == null ||
        snapshot.value is! Map) {
      return null;
    }

    final users = Map<dynamic, dynamic>.from(
      snapshot.value as Map,
    );

    for (final entry in users.entries) {
      if (entry.value is! Map) {
        continue;
      }

      final data = Map<String, dynamic>.from(
        entry.value as Map,
      );

      final storedUsername =
          data['username']?.toString().trim() ?? '';
      final storedPhone =
      _normalizePhone(
        data['phone']?.toString().trim() ?? '',
      );

      final usernameMatches =
          storedUsername.toLowerCase() ==
              username.toLowerCase();

      final phoneMatches =
          phone.isEmpty ||
              storedPhone.isEmpty ||
              storedPhone == phone;

      if (usernameMatches && phoneMatches) {
        data['uid'] = entry.key.toString();
        return data;
      }
    }

    return null;
  }

  Future<void> _openWhatsApp({
    required String phone,
    required String username,
    required String email,
  }) async {
    final cleanPhone = _whatsAppPhone(phone);

    if (cleanPhone.isEmpty) {
      throw Exception('رقم الهاتف غير موجود');
    }

    final message = '''
السلام عليكم ورحمة الله وبركاته

نظام نافذة المنتوج النفطي

تمت الموافقة على طلب تغيير كلمة المرور للحساب:

اسم المستخدم:
$username

تم إرسال رابط تغيير كلمة المرور إلى البريد الإلكتروني المسجل:
$email

افتح البريد واتبع الرابط لإنشاء كلمة مرور جديدة.

مع التقدير
إدارة نافذة المنتوج النفطي
''';

    final uri = Uri.https(
      'wa.me',
      '/$cleanPhone',
      <String, String>{
        'text': message,
      },
    );

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      throw Exception('تعذر فتح WhatsApp');
    }
  }

  Future<void> _approveRequest({
    required String requestId,
    required Map<String, dynamic> request,
  }) async {
    if (_busyRequests.contains(requestId)) {
      return;
    }

    setState(() {
      _busyRequests.add(requestId);
    });

    try {
      final user = await _findUserForRequest(request);

      if (user == null) {
        throw Exception(
          'لم يتم العثور على حساب مطابق لاسم المستخدم ورقم الهاتف',
        );
      }

      final email =
          user['email']?.toString().trim() ?? '';
      final username =
          user['username']?.toString().trim() ?? '';
      final requestPhone =
          request['phone']?.toString().trim() ?? '';
      final phone = requestPhone.isNotEmpty
          ? requestPhone
          : (user['phone']?.toString().trim() ?? '');

      if (email.isEmpty) {
        throw Exception(
          'الحساب لا يحتوي على بريد إلكتروني صالح',
        );
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      final now = DateTime.now().toIso8601String();

      await _requestsRef.child(requestId).update({
        'status': 'approved',
        'approvedAt': now,
        'matchedUid': user['uid']?.toString() ?? '',
        'matchedEmail': email,
      });

      if (!mounted) return;

      try {
        await _openWhatsApp(
          phone: phone,
          username: username,
          email: email,
        );

        if (!mounted) return;

        _showMessage(
          'تمت الموافقة وإرسال رابط تغيير كلمة المرور وفتح WhatsApp برسالة جاهزة',
        );
      } catch (whatsAppError) {
        if (!mounted) return;

        _showMessage(
          'تمت الموافقة وإرسال رابط تغيير كلمة المرور، لكن تعذر فتح WhatsApp: $whatsAppError',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'user-not-found':
          message =
          'لا يوجد حساب Firebase Authentication بهذا البريد';
          break;
        case 'invalid-email':
          message = 'البريد الإلكتروني المسجل غير صالح';
          break;
        case 'too-many-requests':
          message =
          'تم إرسال محاولات كثيرة. حاول مرة أخرى بعد قليل';
          break;
        default:
          message =
          'تعذر إرسال رابط تغيير كلمة المرور: ${e.code}';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;
      _showMessage('تعذر تنفيذ الطلب: $e');
    } finally {
      if (mounted) {
        setState(() {
          _busyRequests.remove(requestId);
        });
      }
    }
  }

  Future<void> _rejectRequest({
    required String requestId,
  }) async {
    if (_busyRequests.contains(requestId)) {
      return;
    }

    setState(() {
      _busyRequests.add(requestId);
    });

    try {
      await _requestsRef.child(requestId).update({
        'status': 'rejected',
        'rejectedAt': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      _showMessage('تم رفض الطلب');
    } catch (e) {
      if (!mounted) return;
      _showMessage('تعذر رفض الطلب: $e');
    } finally {
      if (mounted) {
        setState(() {
          _busyRequests.remove(requestId);
        });
      }
    }
  }

  Future<void> _reviewRequest({
    required String requestId,
    required Map<String, dynamic> request,
  }) async {
    final username =
        request['username']?.toString() ?? '';
    final fullName =
        request['fullName']?.toString() ?? '';
    final phone =
        request['phone']?.toString() ?? '';
    final station =
        request['station']?.toString() ?? '';
    final reason =
        request['reason']?.toString() ?? '';

    final photoUrl =
        request['photoUrl']?.toString() ?? request['photo']?.toString() ?? '';

    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'مراجعة طلب تغيير كلمة المرور',
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (fullName.isNotEmpty) Text('الاسم: $fullName'),
                if (fullName.isNotEmpty) const SizedBox(height: 7),
                Text('اسم المستخدم: $username'),
                const SizedBox(height: 7),
                if (phone.isNotEmpty) Text('رقم الهاتف: $phone'),
                if (phone.isNotEmpty) const SizedBox(height: 7),
                if (station.isNotEmpty) Text('المحطة / الفرع: $station'),
                if (station.isNotEmpty) const SizedBox(height: 7),
                if (reason.isNotEmpty) Text('السبب: $reason'),
                if (reason.isNotEmpty) const SizedBox(height: 7),
                if (photoUrl.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'الصورة الشخصية المرفقة للمطابقة:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      photoUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'تعذر تحميل الصورة الشخصية',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 15),
                const Text(
                  'عند الموافقة سيرسل Firebase رابطاً آمناً لتغيير كلمة المرور إلى البريد المسجل بالحساب، ثم يفتح WhatsApp برسالة جاهزة لإبلاغ المستخدم.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('إلغاء'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  'reject',
                );
              },
              icon: const Icon(Icons.close),
              label: const Text('رفض'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  'approve',
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('موافقة'),
            ),
          ],
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == 'approve') {
      await _approveRequest(
        requestId: requestId,
        request: request,
      );
    } else if (action == 'reject') {
      await _rejectRequest(
        requestId: requestId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات تغيير كلمة المرور'),
        centerTitle: true,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _requestsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطأ أثناء تحميل الطلبات\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data?.snapshot.value;

          if (data == null) {
            return const Center(
              child: Text(
                'لا توجد طلبات تغيير كلمة مرور',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final rawData =
          Map<dynamic, dynamic>.from(data as Map);

          final requests = rawData.entries.toList()
            ..sort((a, b) {
              final aMap =
              Map<dynamic, dynamic>.from(
                a.value as Map,
              );
              final bMap =
              Map<dynamic, dynamic>.from(
                b.value as Map,
              );

              final aDate =
                  aMap['createdAt']?.toString() ?? '';
              final bDate =
                  bMap['createdAt']?.toString() ?? '';

              return bDate.compareTo(aDate);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final entry = requests[index];

              final request =
              Map<String, dynamic>.from(
                entry.value as Map,
              );

              final requestId =
              entry.key.toString();

              final username =
                  request['username']?.toString() ?? '';

              final fullName =
                  request['fullName']?.toString() ?? '';

              final phone =
                  request['phone']?.toString() ?? '';

              final station =
                  request['station']?.toString() ?? '';

              final status =
                  request['status']?.toString() ??
                      'pending';

              final createdAt =
                  request['createdAt']?.toString() ??
                      '';

              final busy =
              _busyRequests.contains(requestId);

              return Card(
                margin:
                const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding:
                  const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lock_reset,
                            color: Colors.blue,
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              fullName.isEmpty
                                  ? username
                                  : fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'اسم المستخدم: $username',
                      ),
                      const SizedBox(height: 5),
                      Text('رقم الهاتف: $phone'),
                      const SizedBox(height: 5),
                      Text(
                        'المحطة / الفرع: $station',
                      ),
                      const SizedBox(height: 5),
                      Text('وقت الطلب: $createdAt'),
                      const SizedBox(height: 10),
                      _statusWidget(status),
                      if (status == 'pending') ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: busy
                              ? null
                              : () => _reviewRequest(
                            requestId:
                            requestId,
                            request: request,
                          ),
                          icon: busy
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(
                            Icons.verified_user,
                          ),
                          label: Text(
                            busy
                                ? 'جارٍ التنفيذ...'
                                : 'مراجعة الطلب',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusWidget(String status) {
    String text;
    Color color;
    IconData icon;

    switch (status) {
      case 'approved':
        text = 'تمت الموافقة';
        color = Colors.green;
        icon = Icons.check_circle;
        break;

      case 'rejected':
        text = 'مرفوض';
        color = Colors.red;
        icon = Icons.cancel;
        break;

      default:
        text = 'قيد المراجعة';
        color = Colors.orange;
        icon = Icons.hourglass_top;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
