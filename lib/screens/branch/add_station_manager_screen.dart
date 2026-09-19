import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/station.dart';
import '../../models/user_model.dart';

import '../../services/auth_service.dart';
import '../../services/station_service.dart';


class AddStationManagerScreen extends StatefulWidget {

  const AddStationManagerScreen({
    super.key,
  });

  @override
  State<AddStationManagerScreen> createState() =>
      _AddStationManagerScreenState();
}


class _AddStationManagerScreenState
    extends State<AddStationManagerScreen> {

  final formKey =
  GlobalKey<FormState>();

  final AuthService auth =
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


  List<Station> stations = [];

  List<Station> filteredStations = [];

  Station? selectedStation;


  String stationType =
      "حكومية";


  bool loading =
  true;

  bool saving =
  false;

  bool obscurePassword =
  true;


  @override
  void initState() {

    super.initState();

    loadStations();

  }


  //====================================
  // جلب المحطات
  //====================================

  Future<void> loadStations() async {

    try {

      final result =
      await stationService.getStations();


      if (!mounted) {
        return;
      }


      setState(() {

        stations =
            result;

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


  //====================================
  // فلترة المحطات حسب النوع
  //====================================

  void filterStations() {

    filteredStations =
        stations.where((station) {

          return station.stationType ==
              stationType;

        }).toList();


    if (selectedStation != null &&
        selectedStation!.stationType !=
            stationType) {

      selectedStation =
      null;

    }

  }


  //====================================
  // إنشاء مدير المحطة
  //====================================

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


    final email =
    usernameController.text
        .trim();


    final password =
    passwordController.text
        .trim();


    if (!email.contains("@") ||
        !email.contains(".")) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "أدخل بريدًا إلكترونيًا صحيحًا",
          ),

          backgroundColor:
          Colors.red,

        ),

      );

      return;

    }


    if (password.length < 6) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
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

        saving =
        true;

      });


      final user =
      AppUser(

        id:
        const Uuid().v4(),

        fullName:
        nameController.text
            .trim(),

        username:
        email,

        password:
        password,

        email:
        email,

        phone:
        phoneController.text
            .trim(),

        // مدير المحطة فقط
        role:
        "stationManager",

        stationId:
        selectedStation!.id,

        stationName:
        selectedStation!.name,

        governorateId:
        selectedStation!.governorate,

        governorateName:
        selectedStation!.governorate,

        branchId:
        selectedStation!.branchId,

        branchName:
        selectedStation!.branchName,

        position:
        "مدير محطة",

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
      // إنشاء الحساب في Firebase
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


      if (!mounted) {
        return;
      }


      setState(() {

        saving =
        false;

      });


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


      setState(() {

        saving =
        false;

      });


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
            "حدث خطأ أثناء إنشاء الحساب: $e",
          ),

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

      loading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          :

      Form(

        key:
        formKey,

        child:

        ListView(

          padding:
          const EdgeInsets.all(16),

          children: [


            //================================
            // نوع المحطة
            //================================

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


            //================================
            // اختيار المحطة
            //================================

            DropdownButtonFormField<Station>(

              initialValue:
              selectedStation,

              isExpanded:
              true,

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
              saving
                  ? null
                  : (value) {

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

                  "لا توجد محطات $stationType",

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


            //================================
            // بيانات المستخدم
            //================================

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

              "البريد الإلكتروني",

              Icons.email,

              keyboardType:
              TextInputType.emailAddress,

            ),


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

                    return
                      "الحقل مطلوب";

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


            //================================
            // معلومات المحطة
            //================================

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

                        "بيانات المحطة",

                        style:

                        TextStyle(

                          fontSize:
                          17,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),


                      const SizedBox(
                        height: 10,
                      ),


                      Text(
                        "اسم المحطة: ${selectedStation!.name}",
                      ),


                      Text(
                        "نوع المحطة: ${selectedStation!.stationType}",
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


            //================================
            // الحفظ
            //================================

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

                  width:
                  22,

                  height:
                  22,

                  child:

                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                  ),

                )

                    : const Icon(
                  Icons.save,
                ),

                label:

                Text(

                  saving
                      ? "جاري إنشاء المستخدم..."
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