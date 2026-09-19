import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Text(
                        'سياسة الخصوصية',
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
                        child: const Text(
                          'نستخدم البيانات اللازمة لتشغيل خدمات التطبيق، مثل بيانات الحساب، بيانات المحطات، الموقع عند تفعيل خدمات الموقع، وبيانات الإعلانات والخدمات التجارية التي يرسلها المستخدم. لا يتم نشر الإعلان أو الخدمة قبل اعتمادها وفق دورة المراجعة داخل النظام. يمكن للمستخدم التواصل مع الإدارة لطلب الاستفسار أو معالجة بياناته وفق ما تسمح به صلاحيات النظام.',
                          style: TextStyle(fontSize: 16, height: 1.8, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
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
