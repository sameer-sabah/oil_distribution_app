import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/commercial_service.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController subject = TextEditingController();
  final TextEditingController message = TextEditingController();
  final TextEditingController phone = TextEditingController();

  bool saving = false;

  @override
  void dispose() {
    subject.dispose();
    message.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تسجيل الدخول أولاً لإرسال الرسالة'),
        ),
      );
      return;
    }

    final String messageText = message.text.trim();

    if (messageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب الرسالة أولاً')),
      );
      return;
    }

    if (messageText.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرسالة يجب ألا تتجاوز 2000 حرف')),
      );
      return;
    }

    if (saving) return;

    setState(() {
      saving = true;
    });

    try {
      await CommercialService.instance.submitContact(
        subject: subject.text.trim(),
        message: messageText,
        phone: phone.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال رسالتك بنجاح')),
      );

      subject.clear();
      message.clear();
      phone.clear();

      Navigator.of(context).pop();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إرسال الرسالة: ${e.message ?? ''}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إرسال الرسالة: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية ثابتة فاخرة باللون الكحلي
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0B132B)],
              ),
            ),
          ),
          Positioned(
            right: -40,
            top: 80,
            child: Opacity(
              opacity: 0.05,
              child: const Icon(
                Icons.local_gas_station_rounded,
                size: 320,
                color: Color(0xFFD4AF37),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // شريط العنوان
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Text(
                        'تواصل معنا',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFDFBF7), Color(0xFFF4EFE6)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'أرسل استفسارك أو اقتراحك وسيتم تحويله إلى فريق الإدارة مباشرة.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 20),

                            TextField(
                              controller: subject,
                              enabled: !saving,
                              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'الموضوع',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                prefixIcon: const Icon(Icons.subject, color: Color(0xFF8A6D1C)),
                              ),
                            ),
                            const SizedBox(height: 14),

                            TextField(
                              controller: phone,
                              enabled: !saving,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'رقم الهاتف (اختياري)',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                prefixIcon: const Icon(Icons.phone, color: Color(0xFF8A6D1C)),
                              ),
                            ),
                            const SizedBox(height: 14),

                            TextField(
                              controller: message,
                              enabled: !saving,
                              maxLines: 5,
                              maxLength: 2000,
                              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'نص الرسالة',
                                alignLabelWithHint: true,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                prefixIcon: const Icon(Icons.message, color: Color(0xFF8A6D1C)),
                              ),
                            ),
                            const SizedBox(height: 20),

                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: saving ? null : _submit,
                                icon: saving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.send_rounded),
                                label: Text(
                                  saving ? 'جارٍ الإرسال...' : 'إرسال الرسالة',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8A6D1C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
