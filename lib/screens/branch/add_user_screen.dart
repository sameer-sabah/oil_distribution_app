import 'package:flutter/material.dart';

import '../../models/station.dart';
import '../../models/user_model.dart';

import '../../services/auth_service.dart';
import '../../services/station_service.dart';


class AddUserScreen extends StatefulWidget {

  const AddUserScreen({
    super.key,
  });

  @override
  State<AddUserScreen> createState() =>
      _AddUserScreenState();

}


class _AddUserScreenState
    extends State<AddUserScreen> {


  final formKey =
  GlobalKey<FormState>();


  final AuthService authService =
      AuthService.instance;


  final StationService stationService =
      StationService.instance;


  final nameController =
  TextEditingController();


  final usernameController =
  TextEditingController();


  final passwordController =
  TextEditingController();


  final phoneController =
  TextEditingController();


  List<Station> allStations = [];


  List<Station> filteredStations = [];


  Station? selectedStation;


  String stationType =
      "حكومية";


  bool loading =
  true;


  bool saving =
  false;


  /*
  ==========================================================
  ملاحظة مهمة
  ==========================================================

  مدير الفرع الحالي يجب أن يكون موجودًا داخل:

  AuthService.instance.currentUser

  ونأخذ منه:

  branchId
  branchName

  حتى لا يستطيع مدير الفرع إنشاء مدير محطة
  تابع لفرع آخر.
  */


  @override
  void initState() {

    super.initState();

    loadStations();

  }


  Future<void> loadStations() async {

    try {

      final currentUser =
          authService.currentUser;


      if (currentUser == null) {

        if (!mounted) {
          return;
        }

        setState(() {

          loading = false;

        });

        return;

      }


      final branchId =
          currentUser.branchId;


      final stations =
      await stationService.getStations();


      /*
      ======================================================
      فلترة المحطات:

      1. نفس فرع مدير الفرع
      2. المحطة معتمدة
      3. المحطة فعالة
      ======================================================
      */


      final branchStations =
      stations.where((station) {

        return station.branchId ==
            branchId &&
            station.approved &&
            station.active;

      }).toList();


      if (!mounted) {
        return;
      }


      setState(() {

        allStations =
            branchStations;

        filterStations();

        loading =
        false;

      });


    } catch (e) {

      if (!mounted) {
        return;
      }


      setState(() {

        loading =
        false;

      });


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
            "حدث خطأ في جلب المحطات: $e",
          ),

          backgroundColor:
          Colors.red,

        ),

      );

    }

  }


  void filterStations() {

    filteredStations =
        allStations.where((station) {

          return station.stationType ==
              stationType;

        }).toList();


    /*
    إذا تغير النوع وكانت المحطة
    المختارة لا تنتمي للنوع الجديد
    يتم إلغاء الاختيار.
    */

    if (selectedStation != null &&
        selectedStation!.stationType !=
            stationType) {

      selectedStation =
      null;

    }

  }


  Future<void> saveUser() async {

    if (!formKey.currentState!
        .validate()) {

      return;

    }


    if (selectedStation == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "يرجى اختيار المحطة",
          ),

          backgroundColor:
          Colors.red,

        ),

      );

      return;

    }


    final currentUser =
        authService.currentUser;


    if (currentUser == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "تعذر معرفة بيانات مدير الفرع",
          ),

          backgroundColor:
          Colors.red,

        ),

      );

      return;

    }


    /*
    ==========================================================
    التأكد أن المحطة تابعة لفرع مدير الفرع
    ==========================================================
    */

    if (selectedStation!.branchId !=
        currentUser.branchId) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "لا يمكن ربط المستخدم بمحطة تابعة لفرع آخر",
          ),

          backgroundColor:
          Colors.red,

        ),

      );

      return;

    }


    try {

      setState(() {

        saving =
        true;

      });


      final username =
      usernameController.text
          .trim();


      final email =
      username.contains("@")
          ? username
          : "$username@opdc.iq";


      final now =
      DateTime.now();


      /*
      ==========================================================
      إنشاء المستخدم

      الصلاحية ثابتة:
      stationManager

      لا يستطيع مدير الفرع تغييرها.
      ==========================================================
      */

      final user =
      AppUser(

        id:
        UniqueKey()
            .toString(),

        fullName:
        nameController.text
            .trim(),

        username:
        username,

        password:
        passwordController.text
            .trim(),

        email:
        email,

        phone:
        phoneController.text
            .trim(),

        role:
        "stationManager",

        governorateId:
        selectedStation!
            .governorate,

        governorateName:
        selectedStation!
            .governorate,

        branchId:
        selectedStation!
            .branchId,

        branchName:
        selectedStation!
            .branchName,

        stationId:
        selectedStation!
            .id,

        stationName:
        selectedStation!
            .name,

        position:
        "مدير محطة",

        image:
        "",

        active:
        true,

        createdAt:
        now,

        updatedAt:
        now,

        lastLogin:
        now,

      );


      /*
      ==========================================================
      إنشاء حساب Firebase Authentication
      + حفظ بيانات المستخدم في users
      ==========================================================
      */

      await authService
          .createUserAccount(
        user: user,
      );


      if (!mounted) {
        return;
      }


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "تم إنشاء حساب مدير المحطة بنجاح",
          ),

          backgroundColor:
          Colors.green,

        ),

      );


      Navigator.pop(
        context,
        true,
      );


    } catch (e) {

      if (!mounted) {
        return;
      }


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
            "حدث خطأ أثناء إنشاء المستخدم: $e",
          ),

          backgroundColor:
          Colors.red,

        ),

      );


    } finally {

      if (mounted) {

        setState(() {

          saving =
          false;

        });

      }

    }

  }


  @override
  Widget build(
      BuildContext context) {


    if (loading) {

      return const Scaffold(

        body:

        Center(

          child:

          CircularProgressIndicator(),

        ),

      );

    }


    return Scaffold(

      appBar:

      AppBar(

        title:

        const Text(
          "إضافة مدير محطة",
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


            /*
            ==================================================
            نوع المحطة
            ==================================================
            */

            const Text(

              "نوع المحطة",

              style:

              TextStyle(

                fontSize:
                18,

                fontWeight:
                FontWeight.bold,

              ),

            ),


            const SizedBox(
              height: 10,
            ),


            Card(
              child: RadioGroup<String>(
                groupValue: stationType,
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    stationType = value;
                    filterStations();
                  });
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: "حكومية",
                      title: const Text(
                        "المحطات الحكومية",
                      ),
                      secondary: const Icon(
                        Icons.account_balance,
                      ),
                    ),
                    RadioListTile<String>(
                      value: "أهلية",
                      title: const Text(
                        "المحطات الأهلية",
                      ),
                      secondary: const Icon(
                        Icons.local_gas_station,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),


            /*
            ==================================================
            اختيار المحطة
            ==================================================
            */

            DropdownButtonFormField<Station>(

              initialValue:
              selectedStation,

              decoration:

              const InputDecoration(

                labelText:
                "المحطة",

                hintText:
                "اختر المحطة",

                prefixIcon:

                Icon(
                  Icons.local_gas_station,
                ),

                border:
                OutlineInputBorder(),

              ),


              items:

              filteredStations
                  .map((station) {

                return DropdownMenuItem<Station>(

                  value:
                  station,

                  child:

                  Text(
                    station.name,
                  ),

                );

              }).toList(),


              onChanged:
                  (value) {

                setState(() {

                  selectedStation =
                      value;

                });

              },


              validator:
                  (value) {

                if (value == null) {

                  return
                    "يرجى اختيار المحطة";

                }

                return null;

              },

            ),


            if (filteredStations.isEmpty)

              Padding(

                padding:
                const EdgeInsets.only(
                  top: 10,
                ),

                child:

                Text(

                  "لا توجد محطات $stationType معتمدة وفعالة تابعة لهذا الفرع",

                  style:

                  const TextStyle(

                    color:
                    Colors.red,

                  ),

                ),

              ),


            const SizedBox(
              height: 25,
            ),


            /*
            ==================================================
            بيانات المستخدم الجديد
            ==================================================
            */

            const Text(

              "بيانات المستخدم الجديد",

              style:

              TextStyle(

                fontSize:
                18,

                fontWeight:
                FontWeight.bold,

              ),

            ),


            const SizedBox(
              height: 15,
            ),


            field(

              nameController,

              "الاسم الكامل",

              Icons.person,

            ),


            field(

              usernameController,

              "اسم المستخدم",

              Icons.account_circle,

            ),


            field(

              passwordController,

              "كلمة المرور",

              Icons.lock,

              password:
              true,

            ),


            field(

              phoneController,

              "رقم الهاتف",

              Icons.phone,

            ),


            const SizedBox(
              height: 15,
            ),


            /*
            ==================================================
            الصلاحية ثابتة
            ==================================================
            */

            InputDecorator(

              decoration:

              const InputDecoration(

                labelText:
                "الصلاحية",

                prefixIcon:

                Icon(
                  Icons.admin_panel_settings,
                ),

                border:
                OutlineInputBorder(),

              ),

              child:

              const Text(
                "مدير محطة",
              ),

            ),


            const SizedBox(
              height: 25,
            ),


            /*
            ==================================================
            معلومات المحطة المختارة
            ==================================================
            */

            if (selectedStation != null)

              Card(

                child:

                Padding(

                  padding:
                  const EdgeInsets.all(15),

                  child:

                  Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [


                      const Text(

                        "المحطة المختارة",

                        style:

                        TextStyle(

                          fontWeight:
                          FontWeight.bold,

                          fontSize:
                          17,

                        ),

                      ),


                      const SizedBox(
                        height: 10,
                      ),


                      Text(
                        "المحطة: ${selectedStation!.name}",
                      ),


                      Text(
                        "النوع: ${selectedStation!.stationType}",
                      ),


                      Text(
                        "الفرع: ${selectedStation!.branchName}",
                      ),


                      Text(
                        "المحافظة: ${selectedStation!.governorate}",
                      ),

                    ],

                  ),

                ),

              ),


            const SizedBox(
              height: 25,
            ),


            /*
            ==================================================
            زر الحفظ
            ==================================================
            */

            SizedBox(

              height:
              55,

              width:
              double.infinity,

              child:

              ElevatedButton.icon(

                onPressed:
                saving
                    ? null
                    : saveUser,

                icon:

                saving

                    ? const SizedBox(

                  width: 22,

                  height: 22,

                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),

                )

                    : const Icon(
                  Icons.save,
                ),

                label:

                Text(

                  saving
                      ? "جاري الحفظ..."
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


  Widget field(

      TextEditingController controller,

      String label,

      IconData icon, {

        bool password =
        false,

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

        obscureText:
        password,

        validator:
            (value) {

          if (value == null ||
              value.trim().isEmpty) {

            return
              "الحقل مطلوب";

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


  @override
  void dispose() {

    nameController.dispose();

    usernameController.dispose();

    passwordController.dispose();

    phoneController.dispose();

    super.dispose();

  }

}