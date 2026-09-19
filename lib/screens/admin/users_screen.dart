import 'package:flutter/material.dart';

import '../../services/user_service.dart';
import 'add_user_screen.dart';


class UsersScreen extends StatefulWidget {

  const UsersScreen({
    super.key,
  });


  @override
  State<UsersScreen> createState() =>
      _UsersScreenState();

}



class _UsersScreenState
    extends State<UsersScreen> {


  final UserService userService =
      UserService.instance;


  List<Map<String,dynamic>> users = [];


  List<Map<String,dynamic>> filteredUsers = [];


  final searchController =
  TextEditingController();


  @override
  void initState(){

    super.initState();

    loadUsers();

    searchController.addListener(() {
      filterUsers();
    });

  }


  Future<void> loadUsers() async {

    users =
    await userService.getUsers();


    if(!mounted) {
      return;
    }


    setState((){

      filteredUsers = users;

    });

  }


  //====================================
  // البحث
  //====================================

  void filterUsers() {

    final query =
    searchController.text
        .trim()
        .toLowerCase();

    setState(() {

      if(query.isEmpty){

        filteredUsers = users;

      }else{

        filteredUsers =
            users.where((user){

              final fullName =
              (user["fullName"] ?? "")
                  .toString()
                  .toLowerCase();

              final username =
              (user["username"] ?? "")
                  .toString()
                  .toLowerCase();

              final email =
              (user["email"] ?? "")
                  .toString()
                  .toLowerCase();

              final role =
              (user["role"] ?? "")
                  .toString()
                  .toLowerCase();

              return
                fullName.contains(query) ||
                    username.contains(query) ||
                    email.contains(query) ||
                    role.contains(query);

            }).toList();

      }

    });

  }


  //====================================
  // اسم الصلاحية
  //====================================

  String roleName(dynamic role){

    switch(role?.toString()){

      case "admin":
        return "مدير النظام";

      case "branchManager":
        return "مدير الفرع";

      case "branch_employee":
        return "موظف الفرع";

      case "station_writer":
        return "كاتب المحطة";

      default:
        return role?.toString() ?? "";

    }

  }


  //====================================
  // لون الحالة
  //====================================

  Color statusColor(dynamic active){

    return active == true
        ? Colors.green
        : Colors.red;

  }


  //====================================
  // إضافة مستخدم
  //====================================

  Future<void> addUser() async {

    final result =
    await Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=>
        const AddUserScreen(),

      ),

    );


    if(result == true){

      await loadUsers();

    }

  }


  //====================================
  // تعديل مستخدم
  //====================================

  Future<void> editUser(
      Map<String,dynamic> user
      ) async {

    final result =
    await Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=>
            AddUserScreen(
              userToEdit: user,
            ),

      ),

    );


    if(result == true){

      await loadUsers();

    }

  }


  //====================================
  // حذف مستخدم
  //====================================

  Future<void> deleteUser(
      Map<String,dynamic> user
      ) async {

    final uid =
    (user["uid"] ?? "")
        .toString();

    if(uid.isEmpty){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
          Text(
            "معرف المستخدم غير موجود",
          ),
        ),

      );

      return;

    }


    if(uid == "admin" ||
        user["username"] == "admin"){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
          Text(
            "لا يمكن حذف مدير النظام الأساسي",
          ),
          backgroundColor:
          Colors.red,
        ),

      );

      return;

    }


    final confirm =
    await showDialog<bool>(

      context: context,

      builder:(context){

        return AlertDialog(

          title:
          const Text(
            "تأكيد الحذف",
          ),

          content:
          Text(
            "هل أنت متأكد من حذف المستخدم\n"
                "${user["fullName"] ?? ""}؟",
          ),

          actions:[

            TextButton(

              onPressed:(){

                Navigator.pop(
                  context,
                  false,
                );

              },

              child:
              const Text(
                "إلغاء",
              ),

            ),

            ElevatedButton(

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.red,
                foregroundColor:
                Colors.white,
              ),

              onPressed:(){

                Navigator.pop(
                  context,
                  true,
                );

              },

              child:
              const Text(
                "حذف",
              ),

            ),

          ],

        );

      },

    );


    if(confirm != true) {
      return;
    }


    try{

      await userService.deleteUser(uid);


      if(!mounted) {
        return;
      }


      setState((){

        users.removeWhere((item){

          return
            (item["uid"] ?? "")
                .toString() ==
                uid;

        });


        filteredUsers.removeWhere((item){

          return
            (item["uid"] ?? "")
                .toString() ==
                uid;

        });

      });


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "تم حذف المستخدم بنجاح",
          ),

          backgroundColor:
          Colors.green,

        ),

      );

    }catch(e){

      if(!mounted) {
        return;
      }


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
            "فشل حذف المستخدم: $e",
          ),

          backgroundColor:
          Colors.red,

        ),

      );

    }

  }


  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(

        title:
        const Text(
            "إدارة المستخدمين"
        ),

        centerTitle:
        true,

        actions:[

          IconButton(

            icon:
            const Icon(
              Icons.refresh,
            ),

            onPressed:
            loadUsers,

          ),

        ],

      ),


      body:
      Column(

        children:[

          const SizedBox(
            height: 15,
          ),


          Padding(

            padding:
            const EdgeInsets.symmetric(
              horizontal: 15,
            ),

            child:
            TextField(

              controller:
              searchController,

              decoration:
              InputDecoration(

                hintText:
                "ابحث عن مستخدم",

                prefixIcon:
                const Icon(
                  Icons.search,
                ),

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),

                ),

              ),

            ),

          ),


          const SizedBox(
            height: 15,
          ),


          Expanded(

            child:
            filteredUsers.isEmpty

                ? RefreshIndicator(

              onRefresh:
              loadUsers,

              child:
              ListView(

                children:[

                  const SizedBox(
                    height: 180,
                  ),

                  const Center(

                    child:
                    Text(
                      "لا يوجد مستخدمون",
                      style:
                      TextStyle(
                        fontSize: 18,
                      ),
                    ),

                  ),

                ],

              ),

            )

                :

            RefreshIndicator(

              onRefresh:
              loadUsers,

              child:
              ListView.builder(

                padding:
                const EdgeInsets.all(
                  10,
                ),

                itemCount:
                filteredUsers.length,

                itemBuilder:
                    (context,index){

                  final user =
                  filteredUsers[index];


                  final fullName =
                  (user["fullName"] ??
                      "بدون اسم")
                      .toString();


                  final username =
                  (user["username"] ??
                      "")
                      .toString();


                  final email =
                  (user["email"] ??
                      "")
                      .toString();


                  final phone =
                  (user["phone"] ??
                      "")
                      .toString();


                  final role =
                  user["role"];


                  final branchName =
                  (user["branchName"] ??
                      "")
                      .toString();


                  final active =
                      user["active"] ??
                          true;


                  return Card(

                    margin:
                    const EdgeInsets.only(
                      bottom: 10,
                    ),

                    child:
                    ListTile(

                      leading:
                      CircleAvatar(

                        backgroundColor:
                        statusColor(
                          active,
                        ),

                        child:
                        const Icon(
                          Icons.person,
                          color:
                          Colors.white,
                        ),

                      ),


                      title:
                      Text(

                        fullName,

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),

                      ),


                      subtitle:
                      Column(

                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children:[

                          if(username
                              .isNotEmpty)

                            Text(
                              "اسم المستخدم: $username",
                            ),


                          if(email
                              .isNotEmpty)

                            Text(
                              "البريد: $email",
                            ),


                          if(phone
                              .isNotEmpty)

                            Text(
                              "الهاتف: $phone",
                            ),


                          Text(
                            "الصلاحية: ${roleName(role)}",
                          ),


                          if(branchName
                              .isNotEmpty)

                            Text(
                              "الفرع: $branchName",
                            ),


                          Text(

                            active == true
                                ? "الحالة: فعال"
                                : "الحالة: غير فعال",

                            style:
                            TextStyle(

                              color:
                              statusColor(
                                active,
                              ),

                              fontWeight:
                              FontWeight.bold,

                            ),

                          ),

                        ],

                      ),


                      trailing:
                      PopupMenuButton<int>(

                        onSelected:
                            (value){

                          if(value == 1){

                            editUser(
                              user,
                            );

                          }


                          if(value == 2){

                            deleteUser(
                              user,
                            );

                          }

                        },


                        itemBuilder:
                            (context){

                          return [

                            const PopupMenuItem(

                              value: 1,

                              child:
                              Row(

                                children:[

                                  Icon(
                                    Icons.edit,
                                  ),

                                  SizedBox(
                                    width: 10,
                                  ),

                                  Text(
                                    "تعديل",
                                  ),

                                ],

                              ),

                            ),


                            const PopupMenuItem(

                              value: 2,

                              child:
                              Row(

                                children:[

                                  Icon(
                                    Icons.delete,
                                    color:
                                    Colors.red,
                                  ),

                                  SizedBox(
                                    width: 10,
                                  ),

                                  Text(
                                    "حذف",
                                  ),

                                ],

                              ),

                            ),

                          ];

                        },

                      ),

                    ),

                  );

                },

              ),

            ),

          ),

        ],

      ),


      floatingActionButton:

      FloatingActionButton(

        onPressed:
        addUser,

        child:
        const Icon(
          Icons.add,
        ),

      ),

    );

  }


  @override
  void dispose(){

    searchController.dispose();

    super.dispose();

  }

}