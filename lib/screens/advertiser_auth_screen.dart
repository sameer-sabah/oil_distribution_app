import 'package:flutter/material.dart';

import '../services/advertiser_account_service.dart';

class AdvertiserAuthScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;
  final bool embedded;

  const AdvertiserAuthScreen({
    super.key,
    this.onAuthenticated,
    this.embedded = false,
  });

  @override
  State<AdvertiserAuthScreen> createState() =>
      _AdvertiserAuthScreenState();
}

class _AdvertiserAuthScreenState extends State<AdvertiserAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _businessName = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _registerMode = true;
  bool _saving = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _fullName.dispose();
    _businessName.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) return;

    if (_registerMode && _password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (_registerMode) {
        await AdvertiserAccountService.instance.register(
          fullName: _fullName.text,
          businessName: _businessName.text,
          email: _email.text,
          phone: _phone.text,
          whatsapp: _whatsapp.text,
          password: _password.text,
        );
      } else {
        await AdvertiserAccountService.instance.login(
          email: _email.text,
          password: _password.text,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _registerMode
                ? 'تم إنشاء حساب المعلن بنجاح'
                : 'تم تسجيل الدخول بنجاح',
          ),
        ),
      );
      widget.onAuthenticated?.call();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AdvertiserAccountService.instance.authErrorMessage(error),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب بريدك الإلكتروني أولاً')),
      );
      return;
    }

    try {
      await AdvertiserAccountService.instance.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال رابط تغيير كلمة المرور إلى بريدك'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AdvertiserAccountService.instance.authErrorMessage(error),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        child: Icon(Icons.storefront_rounded, size: 38),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _registerMode
                            ? 'إنشاء حساب معلن'
                            : 'دخول حساب المعلن',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _registerMode
                            ? 'حساب بسيط لمتابعة الموافقة والسعر والدفع والتواصل مع مدير النظام.'
                            : 'ادخل لمتابعة إعلاناتك ومراسلات الإدارة.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (_registerMode) ...[
                        _field(
                          _fullName,
                          'الاسم الكامل',
                          icon: Icons.person_outline,
                          required: true,
                        ),
                        _field(
                          _businessName,
                          'اسم الشركة أو المحل (اختياري)',
                          icon: Icons.business_outlined,
                        ),
                        _field(
                          _phone,
                          'رقم الهاتف',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          required: true,
                        ),
                        _field(
                          _whatsapp,
                          'رقم واتساب',
                          icon: Icons.chat_outlined,
                          keyboardType: TextInputType.phone,
                          required: true,
                        ),
                      ],
                      _field(
                        _email,
                        'البريد الإلكتروني',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        required: true,
                        email: true,
                      ),
                      _field(
                        _password,
                        'كلمة المرور',
                        icon: Icons.lock_outline,
                        required: true,
                        obscureText: _hidePassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                          ),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      if (_registerMode)
                        _field(
                          _confirmPassword,
                          'تأكيد كلمة المرور',
                          icon: Icons.lock_reset_outlined,
                          required: true,
                          obscureText: _hidePassword,
                        ),
                      if (!_registerMode)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton(
                            onPressed: _resetPassword,
                            child: const Text('نسيت كلمة المرور؟'),
                          ),
                        ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _saving ? null : _submit,
                        icon: _saving
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : Icon(
                          _registerMode
                              ? Icons.person_add_alt_1
                              : Icons.login,
                        ),
                        label: Text(
                          _saving
                              ? 'يرجى الانتظار...'
                              : (_registerMode
                              ? 'إنشاء الحساب والمتابعة'
                              : 'تسجيل الدخول'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => setState(
                              () => _registerMode = !_registerMode,
                        ),
                        child: Text(
                          _registerMode
                              ? 'عندي حساب معلن بالفعل'
                              : 'إنشاء حساب معلن جديد',
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
    );

    if (widget.embedded) return content;
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المعلن'),
        centerTitle: true,
      ),
      body: content,
    );
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        required IconData icon,
        bool required = false,
        bool email = false,
        bool obscureText = false,
        TextInputType? keyboardType,
        Widget? suffixIcon,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        autofillHints: email
            ? const [AutofillHints.email]
            : (obscureText ? const [AutofillHints.password] : null),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (required && text.isEmpty) return 'هذا الحقل مطلوب';
          if (email && text.isNotEmpty && !text.contains('@')) {
            return 'اكتب بريداً إلكترونياً صحيحاً';
          }
          if (obscureText && text.isNotEmpty && text.length < 6) {
            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
