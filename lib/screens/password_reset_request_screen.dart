import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/password_reset_request_service.dart';

class PasswordResetRequestScreen extends StatefulWidget {
  final String? initialUsername;

  const PasswordResetRequestScreen({
    super.key,
    this.initialUsername,
  });

  @override
  State<PasswordResetRequestScreen> createState() =>
      _PasswordResetRequestScreenState();
}

class _PasswordResetRequestScreenState
    extends State<PasswordResetRequestScreen> {
  final usernameController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? selectedPhoto;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialUsername != null) {
      usernameController.text =
      widget.initialUsername!;
    }
  }

  Future<void> takePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (image == null) return;

    setState(() {
      selectedPhoto = File(image.path);
    });
  }

  Future<void> choosePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (image == null) return;

    setState(() {
      selectedPhoto = File(image.path);
    });
  }

  Future<void> sendRequest() async {
    final username =
    usernameController.text.trim();

    if (username.isEmpty) {
      showMessage('أدخل اسم المستخدم');
      return;
    }

    if (selectedPhoto == null) {
      showMessage('يرجى إرفاق صورة شخصية للمطابقة');
      return;
    }

    setState(() {
      loading = true;
    });

    final error =
    await PasswordResetRequestService.instance
        .createRequest(
      username: username,
      photo: selectedPhoto!,
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (error != null) {
      showMessage(
        error,
        color: Colors.red,
      );
      return;
    }

    showMessage(
      'تم إرسال طلب تغيير كلمة المرور إلى مدير الفرع',
      color: Colors.green,
    );

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  void showMessage(
      String message, {
        Color color = Colors.orange,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: color,
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        const Color(0xFF020B18),
        appBar: AppBar(
          title: const Text(
            'طلب تغيير كلمة المرور',
          ),
          backgroundColor:
          const Color(0xFF061426),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.lock_reset_rounded,
                size: 70,
                color: Color(0xFF00D9FF),
              ),

              const SizedBox(height: 15),

              const Text(
                'طلب استعادة الحساب',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'أدخل اسم المستخدم وأرفق صورة شخصية للمطابقة مع الصورة المسجلة سابقاً.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: usernameController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'اسم المستخدم',
                  labelStyle: const TextStyle(
                    color: Color(0xFF00D9FF),
                  ),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF00D9FF),
                  ),
                  filled: true,
                  fillColor:
                  const Color(0xFF061426),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color:
                  const Color(0xFF061426),
                  borderRadius:
                  BorderRadius.circular(20),
                  border: Border.all(
                    color:
                    const Color(0xFF00D9FF)
                        .withValues(alpha: .35),
                  ),
                ),
                child: selectedPhoto == null
                    ? const Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons
                          .add_a_photo_outlined,
                      color:
                      Color(0xFF00D9FF),
                      size: 55,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'أرفق صورة شخصية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                )
                    : ClipRRect(
                  borderRadius:
                  BorderRadius.circular(20),
                  child: Image.file(
                    selectedPhoto!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                      loading ? null : takePhoto,
                      icon: const Icon(
                        Icons.camera_alt,
                      ),
                      label: const Text(
                        'الكاميرا',
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                      loading ? null : choosePhoto,
                      icon: const Icon(
                        Icons.photo_library,
                      ),
                      label: const Text(
                        'المعرض',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed:
                  loading ? null : sendRequest,
                  icon: loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.send_rounded,
                  ),
                  label: Text(
                    loading
                        ? 'جاري إرسال الطلب...'
                        : 'إرسال طلب تغيير كلمة المرور',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}