import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChangePasswordRequestScreen extends StatefulWidget {
  const ChangePasswordRequestScreen({super.key});

  @override
  State<ChangePasswordRequestScreen> createState() =>
      _ChangePasswordRequestScreenState();
}

class _ChangePasswordRequestScreenState
    extends State<ChangePasswordRequestScreen> {
final _formKey = GlobalKey<FormState>();

final usernameController = TextEditingController();
final fullnameController = TextEditingController();
final phoneController = TextEditingController();
final stationController = TextEditingController();
final reasonController = TextEditingController();

bool loading = false;

final DatabaseReference requestRef =
FirebaseDatabase.instance.ref("passwordRequests");

Future<void> sendRequest() async {
if (!_formKey.currentState!.validate()) return;

setState(() {
loading = true;
});

try {
final id = DateTime.now().millisecondsSinceEpoch.toString();

await requestRef.child(id).set({
"id": id,
"username": usernameController.text.trim(),
"fullName": fullnameController.text.trim(),
"phone": phoneController.text.trim(),
"station": stationController.text.trim(),
"reason": reasonController.text.trim(),
"status": "pending",
"createdAt": DateTime.now().toIso8601String(),
});

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"تم إرسال الطلب بنجاح",
),
),
);

Navigator.pop(context);
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
"حدث خطأ\n$e",
),
),
);
}

setState(() {
loading = false;
});
}

@override
void dispose() {
usernameController.dispose();
fullnameController.dispose();
phoneController.dispose();
stationController.dispose();
reasonController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
"طلب تغيير كلمة المرور",
),
),

body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.all(20),

child: Form(
key: _formKey,

child: Column(
children: [
TextFormField(
controller: fullnameController,
decoration: const InputDecoration(
labelText: "الاسم الكامل",
prefixIcon: Icon(Icons.person),
border: OutlineInputBorder(),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "يرجى إدخال الاسم الكامل";
}
return null;
},
),

const SizedBox(height: 18),

TextFormField(
controller: usernameController,
decoration: const InputDecoration(
labelText: "اسم المستخدم",
prefixIcon: Icon(Icons.account_circle),
border: OutlineInputBorder(),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "يرجى إدخال اسم المستخدم";
}
return null;
},
),

const SizedBox(height: 18),

TextFormField(
controller: phoneController,
keyboardType: TextInputType.phone,
decoration: const InputDecoration(
labelText: "رقم الهاتف",
prefixIcon: Icon(Icons.phone),
border: OutlineInputBorder(),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "يرجى إدخال رقم الهاتف";
}
return null;
},
),

const SizedBox(height: 18),

TextFormField(
controller: stationController,
decoration: const InputDecoration(
labelText: "اسم المحطة / الفرع",
prefixIcon: Icon(Icons.local_gas_station),
border: OutlineInputBorder(),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "يرجى إدخال اسم المحطة أو الفرع";
}
return null;
},
),

const SizedBox(height: 18),

TextFormField(
controller: reasonController,
maxLines: 4,
decoration: const InputDecoration(
labelText: "سبب طلب تغيير كلمة المرور",
alignLabelWithHint: true,
prefixIcon: Icon(Icons.edit_note),
border: OutlineInputBorder(),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "يرجى كتابة سبب الطلب";
}
return null;
},
),

const SizedBox(height: 30),
  SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton.icon(
      onPressed: loading ? null : sendRequest,
      icon: loading
          ? const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Colors.white,
        ),
      )
          : const Icon(Icons.send),
      label: Text(
        loading
            ? "جاري إرسال الطلب..."
            : "إرسال الطلب",
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),

  const SizedBox(height: 25),

  const Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: 40,
          ),
          SizedBox(height: 10),
          Text(
            "سيتم إرسال طلبك إلى مدير النظام، وبعد مراجعته سيتم تغيير كلمة المرور وإشعارك بالنتيجة.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
  ),

],
),
),
),
),
);
}
}