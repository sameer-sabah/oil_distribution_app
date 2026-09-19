import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/branch_service.dart';
import '../../services/auth_service.dart';

class AddUserScreen extends StatefulWidget {

  final Map<String,dynamic>? userToEdit;

  const AddUserScreen({
    super.key,
    this.userToEdit,
  });


  @override
  State<AddUserScreen> createState() =>
      _AddUserScreenState();

}


class _AddUserScreenState
    extends State<AddUserScreen> {


  final formKey =
  GlobalKey<FormState>();


  final UserService userService =
      UserService.instance;

  final AuthService authService =
      AuthService.instance;

  final BranchService branchService =
      BranchService.instance;


  final nameController =
  TextEditingController();


  final usernameController =
  TextEditingController();


  final passwordController =
  TextEditingController();


  final phoneController =
  TextEditingController();


  List<Map<String,dynamic>> branches = [];


  String role =
      "admin";


  String? selectedBranchId;


  String? selectedBranchName;


  bool loading = true;


  bool saving = false;


  bool get isEditing =>
      widget.userToEdit != null;


  @override
  void initState(){

    super.initState();

    loadBranches();

    if(isEditing){

      loadUserData();

    }

  }


  //====================================
  // بيانات التعديل
  //====================================

  void loadUserData(){

    final user =
    widget.userToEdit!;


    nameController.text =
        (user["fullName"] ?? "")
            .toString();


    usernameController.text =
        (user["username"] ?? "")
            .toString();


    // SECURITY:
    // لا نقرأ أو نعرض كلمة المرور من Realtime Database عند التعديل.
    passwordController.clear();


    phoneController.text =
        (user["phone"] ?? "")
            .toString();


    final savedRole =
    (user["role"] ?? "admin")
        .toString();


    if(savedRole == "admin" ||
        savedRole == "branchManager"){

      role =
          savedRole;

    }else{

      role =
      "admin";

    }


    final branchId =
    (user["branchId"] ?? "")
        .toString();


    final branchName =
    (user["branchName"] ?? "")
        .toString();


    if(branchId.isNotEmpty){

      selectedBranchId =
          branchId;

    }


    if(branchName.isNotEmpty){

      selectedBranchName =
          branchName;

    }

  }


  //====================================
  // جلب الفروع
  //====================================

  Future<void> loadBranches() async {

    try{

      final result =
      await branchService.getBranches();


      final list =
      <Map<String,dynamic>>[];


      for(final branch in result){

        final dynamic item =
            branch;


        final String id =
        (item.id ?? "")
            .toString();


        final String name =
        (item.name ?? "")
            .toString();


        if(id.isNotEmpty &&
            name.isNotEmpty){

          list.add({

            "id":
            id,

            "name":
            name,

          });

        }

      }


      if(!mounted) {
        return;
      }


      setState((){

        branches =
            list;

        loading =
        false;

      });

    }catch(e){

      if(!mounted) {
        return;
      }


      setState((){

        loading =
        false;

      });


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
            "حدث خطأ في جلب الفروع: $e",
          ),

          backgroundColor:
          Colors.red,

        ),

      );

    }

  }


  //====================================
  // حفظ المستخدم
  //====================================

  Future<void> saveUser() async {

    if(!formKey.currentState!
        .validate()){

      return;

    }


    if(role == "branchManager" &&
        (selectedBranchId == null ||
            selectedBranchId!.isEmpty)){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "يرجى اختيار الفرع",
          ),

          backgroundColor:
          Colors.red,

        ),

      );

      return;

    }


    setState((){

      saving =
      true;

    });


    try{

      final now =
      DateTime.now();


      final branchId =
      role == "branchManager"
          ? selectedBranchId ?? ""
          : "";


      final branchName =
      role == "branchManager"
          ? selectedBranchName ?? ""
          : "";


      //================================
      // تعديل
      //================================

      if(isEditing){

        final uid =
        (widget.userToEdit!["uid"] ??
            "")
            .toString();


        if(uid.isEmpty){

          throw Exception(
            "معرف المستخدم غير موجود",
          );

        }


        await userService.updateUser(

          uid,

          {

            "fullName":
            nameController.text.trim(),

            "username":
            usernameController.text.trim(),

            // كلمة مرور Firebase Authentication لا تتغير من Realtime Database.
            "email":
            usernameController.text.trim(),

            "phone":
            phoneController.text.trim(),

            "role":
            role,

            "governorateId":
            branchId,

            "governorateName":
            branchName,

            "branchId":
            branchId,

            "branchName":
            branchName,

            "stationId":
            "",

            "stationName":
            "",

            "position":
            role,

            "updatedAt":
            now.toIso8601String(),

          },

        );

      }


      //================================
      // إضافة
      //================================

      else{

        final user =
        AppUser(

          id:
          const Uuid().v4(),

          fullName:
          nameController.text.trim(),

          username:
          usernameController.text.trim(),

          password:
          passwordController.text.trim(),

          email:
          usernameController.text.trim().contains("@")
              ? usernameController.text.trim()
              : "${usernameController.text.trim()}@opdc.iq",

          phone:
          phoneController.text.trim(),

          role:
          role,

          governorateId:
          branchId,

          governorateName:
          branchName,

          branchId:
          branchId,

          branchName:
          branchName,

          stationId:
          "",

          stationName:
          "",

          position:
          role,

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


        await authService.createUserAccount(
          user: user,
        );
      }
      if(!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text(
            isEditing
                ? "تم تعديل المستخدم بنجاح"
                : "تم إنشاء المستخدم بنجاح",
          ),
          backgroundColor:
          Colors.green,
        ),
      );


      Navigator.pop(
        context,
        true,
      );


    }catch(e){

      if(!mounted) {
        return;
      }


      setState((){

        saving =
        false;

      });


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
            "حدث خطأ أثناء الحفظ: $e",
          ),

          backgroundColor:
          Colors.red,

        ),

      );

    }

  }


  //====================================
  // الحقول
  //====================================

  Widget field(

      TextEditingController controller,

      String label,

      IconData icon,

      {

        bool password = false,

      }

      ){

    return Padding(

      padding:
      const EdgeInsets.only(
        bottom:15,
      ),

      child:
      TextFormField(

        controller:
        controller,

        obscureText:
        password,

        validator:(v){

          if(v == null ||
              v.trim().isEmpty){

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
  Widget build(BuildContext context){

    if(loading){

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

        Text(

          isEditing
              ? "تعديل المستخدم"
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

          children:[


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


            if (!isEditing)
              field(

                passwordController,

                "كلمة المرور",

                Icons.lock,

                password:true,

              ),


            field(

              phoneController,

              "رقم الهاتف",

              Icons.phone,

            ),


            const SizedBox(
              height:15,
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


              onChanged:(value){

                if(value == null) {
                  return;
                }


                setState((){

                  role =
                      value;


                  if(role ==
                      "admin"){

                    selectedBranchId =
                    null;

                    selectedBranchName =
                    null;

                  }

                });

              },

            ),


            //================================
            // الفرع
            // يظهر لمدير الفرع فقط
            //================================

            if(role ==
                "branchManager") ...[

              const SizedBox(
                height:15,
              ),


              DropdownButtonFormField<String>(

                initialValue:
                branches.any(
                      (branch)=>
                  branch["id"] ==
                      selectedBranchId,
                )
                    ? selectedBranchId
                    : null,


                decoration:
                const InputDecoration(

                  labelText:
                  "الفرع",

                  border:
                  OutlineInputBorder(),

                  prefixIcon:
                  Icon(
                    Icons.business,
                  ),

                ),


                items:

                branches.map(
                      (branch){

                    return
                      DropdownMenuItem<String>(

                        value:
                        branch["id"]
                            .toString(),

                        child:
                        Text(

                          branch["name"]
                              .toString(),

                        ),

                      );

                  },

                ).toList(),


                onChanged:(value){

                  if(value == null) {
                    return;
                  }


                  final branch =
                  branches.firstWhere(
                        (item)=>
                    item["id"]
                        .toString() ==
                        value,
                  );


                  setState((){

                    selectedBranchId =
                        branch["id"]
                            .toString();

                    selectedBranchName =
                        branch["name"]
                            .toString();

                  });

                },


                validator:(value){

                  if(role ==
                      "branchManager" &&
                      (value == null ||
                          value.isEmpty)){

                    return
                      "يرجى اختيار الفرع";

                  }

                  return null;

                },

              ),

            ],


            const SizedBox(
              height:30,
            ),


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
                const Icon(
                  Icons.save,
                ),

                label:

                Text(

                  isEditing
                      ? "حفظ التعديل"
                      : "حفظ المستخدم",

                  style:
                  const TextStyle(

                    fontSize:18,

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


  @override
  void dispose(){

    nameController.dispose();

    usernameController.dispose();

    passwordController.dispose();

    phoneController.dispose();

    super.dispose();

  }

}