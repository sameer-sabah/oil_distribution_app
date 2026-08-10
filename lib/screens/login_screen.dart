import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/station_service.dart';
import '../screens/station_manager_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  bool loading = false;

  bool hidePassword = true;

  // =========================================================
  // تسجيل الدخول
  // =========================================================

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    final user = await AuthService.instance.login(
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      loading = false;
    });

    // =========================================================
    // بيانات الدخول غير صحيحة
    // =========================================================

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "اسم المستخدم أو كلمة المرور غير صحيحة",
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // =========================================================
    // توجيه المستخدم حسب الصلاحية
    // =========================================================

    print("ROLE FROM FIREBASE = ${user.role}");

    switch (user.role) {
    // =======================================================
    // مدير النظام
    // =======================================================

      case "admin":
        Navigator.pushReplacementNamed(
          context,
          "/admin",
        );

        break;

    // =======================================================
    // مدير الفرع
    // =======================================================

      case "branchManager":
        Navigator.pushReplacementNamed(
          context,
          "/branch",
        );

        break;

    // =======================================================
    // مدير المحطة
    // =======================================================

      case "station":
      case "stationManager":
        final station = await StationService.instance.getStation(
          user.stationId,
        );

        if (!mounted) {
          return;
        }

        if (station != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StationManagerDashboard(
                station: station,
              ),
            ),
          );
        }

        break;

    // =======================================================
    // الموظف
    // =======================================================

      case "employee":
        Navigator.pushReplacementNamed(
          context,
          "/employee",
        );

        break;

    // =======================================================
    // صلاحية غير معروفة
    // =======================================================

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "صلاحية غير معرفة: ${user.role}",
            ),
          ),
        );
    }
  }

  // ===========================================================
  // واجهة تسجيل الدخول
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ===================================================
            // خلفية الشاشة
            // ===================================================

            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade900,
                    Colors.blue.shade400,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),

              // =================================================
              // محتوى تسجيل الدخول
              // =================================================

              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            // ===================================
                            // شعار التطبيق
                            // ===================================

                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.blue.shade100,
                              child: const Icon(
                                Icons.local_gas_station,
                                size: 60,
                                color: Colors.blue,
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            // ===================================
                            // اسم التطبيق
                            // ===================================

                            const Text(
                              "نافذة المنتوج النفطي",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            // ===================================
                            // اسم المستخدم
                            // ===================================

                            TextFormField(
                              controller: usernameController,
                              validator: (v) {
                                if (v == null ||
                                    v.trim().isEmpty) {
                                  return "ادخل اسم المستخدم";
                                }

                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: "اسم المستخدم",
                                prefixIcon: Icon(
                                  Icons.person,
                                ),
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // ===================================
                            // كلمة المرور
                            // ===================================

                            TextFormField(
                              controller: passwordController,
                              obscureText: hidePassword,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "ادخل كلمة المرور";
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "كلمة المرور",
                                prefixIcon: const Icon(
                                  Icons.lock,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    hidePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      hidePassword =
                                      !hidePassword;
                                    });
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            // ===================================
                            // زر الدخول
                            // ===================================

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: loading ? null : login,
                                child: loading
                                    ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                    : const Text(
                                  "دخول",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // ===================================
                            // تسجيل محطة جديدة
                            // ===================================

                            TextButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/registerStation",
                                );
                              },
                              icon: const Icon(
                                Icons.local_gas_station,
                              ),
                              label: const Text(
                                "تسجيل محطة جديدة",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ===================================================
            // زر الرجوع
            // ===================================================

            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 30,
                ),
                tooltip: "رجوع",
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // التخلص من Controllers
  // ===========================================================

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }
}