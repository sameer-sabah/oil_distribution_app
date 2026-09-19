import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AddUserScreen extends StatefulWidget {
  // null = إضافة
  // user = تعديل
  final Map<String, dynamic>? user;

  const AddUserScreen({
    super.key,
    this.user,
  });

  @override
  State<AddUserScreen> createState() =>
      _AddUserScreenState();
}

class _AddUserScreenState
    extends State<AddUserScreen> {

  final formKey =
  GlobalKey<FormState>();

  final AuthService auth =
      AuthService.instance;

  final FirebaseDatabase database =
      FirebaseDatabase.instance;

  final UserService userService =
      UserService.instance;

  //====================================
  // الحقول
  //====================================

  final nameController =
  TextEditingController();

  final usernameController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  //====================================
  // الصلاحية
  //====================================

  String role = "branchManager";

  //====================================
  // الفروع
  //====================================

  List<Map<String, String>> branches = [];

  String? selectedBranchId;
  String? selectedBranchName;

  bool loading = false;
  bool loadingBranches = true;
  bool obscurePassword = true;

  //====================================
  // بداية الشاشة
  //====================================

  @override
  void initState() {
    super.initState();

    // إذا تعديل، نملأ البيانات القديمة
    if (widget.user != null) {
      final user = widget.user!;

      nameController.text =
          (user["fullName"] ??
              user["name"] ??
              "")
              .toString();

      usernameController.text =
          (user["username"] ??
              user["email"] ??
              "")
              .toString();

      phoneController.text =
          (user["phone"] ?? "")
              .toString();

      role =
          (user["role"] ??
              "branchManager")
              .toString();

      final branchId =
      (user["branchId"] ?? "")
          .toString();

      final branchName =
      (user["branchName"] ?? "")
          .toString();

      selectedBranchId =
      branchId.isEmpty
          ? null
          : branchId;

      selectedBranchName =
      branchName.isEmpty
          ? null
          : branchName;
    }

    loadBranches();
  }

  //====================================
  // جلب الفروع
  //====================================

  Future<void> loadBranches() async {

    try {

      final snapshot =
      await database
          .ref("branches")
          .get();

      final List<Map<String, String>>
      loadedBranches = [];

      if (snapshot.exists &&
          snapshot.value != null) {

        final data =
        Map<dynamic, dynamic>.from(
          snapshot.value as Map,
        );

        for (final item
        in data.entries) {

          final branchId =
          item.key.toString();

          final map =
          Map<dynamic, dynamic>.from(
            item.value as Map,
          );

          final branchName =
          (map["name"] ??
              map["branchName"] ??
              map["title"] ??
              "")
              .toString();

          if (branchName.isNotEmpty) {

            loadedBranches.add({
              "id": branchId,
              "name": branchName,
            });
          }
        }
      }

      if (!mounted) return;

      setState(() {

        branches =
            loadedBranches;

        loadingBranches =
        false;

        // إذا كان تعديل ونفس الفرع موجود
        // نأخذ اسم الفرع من قاعدة البيانات
        if (selectedBranchId != null) {

          for (final branch
          in branches) {

            if (branch["id"] ==
                selectedBranchId) {

              selectedBranchName =
              branch["name"];

              break;
            }
          }
        }
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        loadingBranches = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "تعذر جلب الفروع: $e",
          ),
          backgroundColor:
          Colors.red,
        ),
      );
    }
  }

  //====================================
  // إنشاء / تعديل المستخدم
  //====================================

  Future<void> saveUser() async {

    if (!formKey.currentState!
        .validate()) {
      return;
    }

    // مدير الفرع يجب أن يختار فرع
    if (role == "branchManager" &&
        selectedBranchId == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "يرجى اختيار الفرع لمدير الفرع",
          ),
          backgroundColor:
          Colors.red,
        ),
      );

      return;
    }

    final email =
    usernameController.text.trim();

    final password =
    passwordController.text.trim();

    //====================================
    // التحقق من البريد
    //====================================

    if (!email.contains('@') ||
        !email.contains('.')) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "أدخل بريدًا إلكترونيًا صحيحًا",
          ),
          backgroundColor:
          Colors.red,
        ),
      );

      return;
    }

    //====================================
    // التحقق من كلمة المرور
    //
    // نفس التحقق الأصلي محفوظ
    //====================================

    if (password.length < 6) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "كلمة المرور يجب أن تكون 6 أحرف أو أكثر",
          ),
          backgroundColor:
          Colors.red,
        ),
      );

      return;
    }

    try {

      setState(() {
        loading = true;
      });

      //====================================
      // بيانات الفرع
      //====================================

      final branchId =
      role == "branchManager"
          ? selectedBranchId ?? ""
          : "";

      final branchName =
      role == "branchManager"
          ? selectedBranchName ?? ""
          : "";

      //====================================
      // إذا تعديل
      //====================================

      if (widget.user != null) {

        final uid =
        (widget.user!["uid"] ??
            widget.user!["id"] ??
            "")
            .toString();

        if (uid.isEmpty) {
          throw Exception(
            "معرف المستخدم غير موجود",
          );
        }

        // لا نغير كلمة المرور هنا
        // لأن كلمة مرور Firebase Authentication
        // لا تتغير من Realtime Database.

        final Map<String, dynamic>
        updateData = {

          "fullName":
          nameController.text.trim(),

          "username":
          email,

          "email":
          email,

          "phone":
          phoneController.text.trim(),

          "role":
          role,

          "branchId":
          branchId,

          "branchName":
          branchName,

          "position":
          role == "admin"
              ? "مدير النظام"
              : "مدير الفرع",

          "updatedAt":
          DateTime.now()
              .toIso8601String(),
        };

        await userService.updateUser(
          uid,
          updateData,
        );

        if (!mounted) return;

        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "تم تعديل المستخدم بنجاح",
            ),
            backgroundColor:
            Colors.green,
          ),
        );

        Navigator.pop(
          context,
          true,
        );

        return;
      }

      //====================================
      // المستخدم الجديد
      //====================================

      final user = AppUser(

        id:
        const Uuid().v4(),

        fullName:
        nameController.text.trim(),

        username:
        email,

        password:
        password,

        email:
        email,

        phone:
        phoneController.text.trim(),

        role:
        role,

        // لا يوجد ربط بمحطة
        stationId:
        "",

        stationName:
        "",

        governorateId:
        "",

        governorateName:
        "",

        // ربط الفرع
        branchId:
        branchId,

        branchName:
        branchName,

        position:
        role == "admin"
            ? "مدير النظام"
            : "مدير الفرع",

        image:
        "",

        active:
        true,

        createdAt:
        DateTime.now(),

        updatedAt:
        DateTime.now(),

        lastLogin:
        DateTime.now(),
      );

      //====================================
      // إنشاء الحساب
      //====================================

      final createdUser =
      await auth.createUserAccount(
        user: user,
      );

      if (createdUser == null) {

        throw Exception(
          "لم يتم إنشاء المستخدم",
        );
      }

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      //====================================
      // نجاح
      //====================================

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "تم إنشاء المستخدم بنجاح",
          ),
          backgroundColor:
          Colors.green,
        ),
      );

      // true = تم إنشاء مستخدم
      // حتى تعيد شاشة الإدارة تحميل القائمة
      Navigator.pop(
        context,
        true,
      );

    } on FirebaseAuthException catch (e) {

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      String message;

      switch (e.code) {

        case 'email-already-in-use':

          message =
          "هذا البريد مستخدم مسبقًا";

          break;

        case 'invalid-email':

          message =
          "البريد الإلكتروني غير صحيح";

          break;

        case 'weak-password':

          message =
          "كلمة المرور ضعيفة";

          break;

        case 'network-request-failed':

          message =
          "تأكد من اتصال الإنترنت";

          break;

        case 'operation-not-allowed':

          message =
          "تسجيل الدخول بالبريد وكلمة المرور غير مفعل في Firebase";

          break;

        default:

          message =
          "فشل إنشاء المستخدم: ${e.code}";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text(message),
          backgroundColor:
          Colors.red,
        ),
      );

    } catch (e) {

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text("حدث خطأ: $e"),
          backgroundColor:
          Colors.red,
        ),
      );
    }
  }

  //====================================
  // الواجهة
  //====================================

  @override
  Widget build(
      BuildContext context) {

    final bool isEdit =
        widget.user != null;

    return Scaffold(

      appBar:
      AppBar(

        title:
        Text(
          isEdit
              ? "تعديل مستخدم"
              : "إضافة مستخدم",
        ),

        centerTitle:
        true,
      ),

      body:

      Form(

        key:
        formKey,

        child:

        ListView(

          padding:
          const EdgeInsets.all(16),

          children: [

            //================================
            // الاسم
            //================================

            field(
              nameController,
              "الاسم الكامل",
              Icons.person,
            ),

            //================================
            // البريد
            //================================

            field(
              usernameController,
              "البريد الإلكتروني",
              Icons.email,
              keyboardType:
              TextInputType.emailAddress,
            ),

            //================================
            // كلمة المرور
            //================================

            Padding(

              padding:
              const EdgeInsets.only(
                bottom: 15,
              ),

              child:

              TextFormField(

                controller:
                passwordController,

                obscureText:
                obscurePassword,

                validator:
                    (value) {

                  if (value == null ||
                      value.trim().isEmpty) {

                    return "الحقل مطلوب";
                  }

                  if (value.length < 6) {

                    return
                      "كلمة المرور يجب أن تكون 6 أحرف أو أكثر";
                  }

                  return null;
                },

                decoration:
                InputDecoration(

                  labelText:
                  "كلمة المرور",

                  prefixIcon:
                  const Icon(
                    Icons.lock,
                  ),

                  suffixIcon:
                  IconButton(

                    icon:
                    Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),

                    onPressed: () {

                      setState(() {

                        obscurePassword =
                        !obscurePassword;

                      });
                    },
                  ),

                  border:
                  const OutlineInputBorder(),
                ),
              ),
            ),

            //================================
            // الهاتف
            //================================

            field(
              phoneController,
              "رقم الهاتف",
              Icons.phone,
              keyboardType:
              TextInputType.phone,
            ),

            const SizedBox(
              height: 15,
            ),

            //================================
            // الصلاحية
            //================================

            DropdownButtonFormField<String>(

              initialValue:
              role,

              decoration:
              const InputDecoration(

                labelText:
                "الصلاحية",

                border:
                OutlineInputBorder(),

                prefixIcon:
                Icon(
                  Icons.admin_panel_settings,
                ),
              ),

              items:
              const [

                DropdownMenuItem(

                  value:
                  "admin",

                  child:
                  Text(
                    "مدير النظام",
                  ),
                ),

                DropdownMenuItem(

                  value:
                  "branchManager",

                  child:
                  Text(
                    "مدير الفرع",
                  ),
                ),
              ],

              onChanged:
              loading
                  ? null
                  : (value) {

                if (value == null) {
                  return;
                }

                setState(() {

                  role =
                      value;

                  // إذا اختار مدير النظام
                  // نمسح الفرع
                  if (role ==
                      "admin") {

                    selectedBranchId =
                    null;

                    selectedBranchName =
                    null;
                  }

                });
              },
            ),

            //================================
            // اختيار الفرع
            // يظهر فقط لمدير الفرع
            //================================

            if (role ==
                "branchManager") ...[

              const SizedBox(
                height: 15,
              ),

              DropdownButtonFormField<String>(

                initialValue:
                selectedBranchId,

                isExpanded:
                true,

                decoration:
                const InputDecoration(

                  labelText:
                  "الفرع",

                  hintText:
                  "اختر الفرع",

                  border:
                  OutlineInputBorder(),

                  prefixIcon:
                  Icon(
                    Icons.business,
                  ),
                ),

                items:

                loadingBranches

                    ? const []

                    : branches.map(
                      (branch) {

                    return
                      DropdownMenuItem<
                          String>(

                        value:
                        branch["id"],

                        child:
                        Text(
                          branch["name"] ??
                              "",
                        ),
                      );
                  },
                ).toList(),

                onChanged:

                loading ||
                    loadingBranches

                    ? null

                    : (value) {

                  if (value ==
                      null) {
                    return;
                  }

                  final branch =
                  branches.firstWhere(
                        (item) =>
                    item["id"] ==
                        value,
                  );

                  setState(() {

                    selectedBranchId =
                    branch["id"];

                    selectedBranchName =
                    branch["name"];

                  });
                },

                validator:
                    (value) {

                  if (role ==
                      "branchManager" &&
                      (value == null ||
                          value.isEmpty)) {

                    return
                      "يرجى اختيار الفرع";
                  }

                  return null;
                },
              ),
            ],

            const SizedBox(
              height: 30,
            ),

            //================================
            // زر الحفظ
            //================================

            SizedBox(

              height:
              55,

              width:
              double.infinity,

              child:

              ElevatedButton.icon(

                onPressed:
                loading
                    ? null
                    : saveUser,

                icon:

                loading

                    ? const SizedBox(

                  width:
                  22,

                  height:
                  22,

                  child:
                  CircularProgressIndicator(

                    strokeWidth:
                    2,

                    color:
                    Colors.white,
                  ),
                )

                    : const Icon(
                  Icons.save,
                ),

                label:

                Text(

                  loading

                      ? isEdit
                      ? "جاري تعديل المستخدم..."
                      : "جاري إنشاء المستخدم..."

                      : isEdit
                      ? "حفظ التعديل"
                      : "حفظ المستخدم",

                  style:
                  const TextStyle(

                    fontSize:
                    18,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //====================================
  // حقل عام
  //====================================

  Widget field(

      TextEditingController controller,

      String label,

      IconData icon, {

        TextInputType? keyboardType,

      }) {

    return Padding(

      padding:
      const EdgeInsets.only(
        bottom: 15,
      ),

      child:

      TextFormField(

        controller:
        controller,

        keyboardType:
        keyboardType,

        validator:
            (value) {

          if (value == null ||
              value.trim().isEmpty) {

            return "الحقل مطلوب";
          }

          return null;
        },

        decoration:
        InputDecoration(

          labelText:
          label,

          prefixIcon:
          Icon(icon),

          border:
          const OutlineInputBorder(),
        ),
      ),
    );
  }

  //====================================
  // تنظيف
  //====================================

  @override
  void dispose() {

    nameController.dispose();

    usernameController.dispose();

    passwordController.dispose();

    phoneController.dispose();

    super.dispose();
  }
}
