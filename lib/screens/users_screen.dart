import 'package:flutter/material.dart';

import '../services/user_service.dart';
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




  final TextEditingController searchController =
  TextEditingController();







  @override
  void initState(){

    super.initState();

    loadUsers();

  }







  Future<void> loadUsers() async {



    users =
    await userService.getUsers();



    if(!mounted) {
      return;
    }



    setState((){


      filteredUsers =
          users;


    });



  }









  void search(String value){


    setState((){



      filteredUsers = users.where((user){



        final name =

        (user["fullName"] ??
            user["name"] ??
            "")
            .toString()
            .toLowerCase();




        return name.contains(
            value.toLowerCase()
        );



      }).toList();



    });



  }







  Future<void> deleteUser(String uid) async {
    if (uid.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "تعذر حذف المستخدم: معرف المستخدم غير موجود",
          ),
        ),
      );

      return;
    }

    try {
      // حذف المستخدم من Firebase Realtime Database
      await userService.deleteUser(uid);

      // إعادة تحميل القائمة من Firebase
      await loadUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "تم حذف المستخدم بنجاح",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "فشل حذف المستخدم: $e",
          ),
        ),
      );
    }
  }









  Widget userCard(
      Map<String,dynamic> user
      ){



    return Card(



      margin:

      const EdgeInsets.symmetric(

        horizontal:12,

        vertical:6,

      ),





      elevation:
      3,





      child:

      ListTile(



        leading:

        const CircleAvatar(



          child:
          Icon(
              Icons.person
          ),



        ),






        title:


        Column(



          crossAxisAlignment:
          CrossAxisAlignment.start,



          children: [



            Text(



              user["stationName"] ??
                  "بدون اسم محطة",



              style:

              const TextStyle(

                fontWeight:
                FontWeight.bold,

                fontSize:
                16,

                color:
                Colors.blue,

              ),



            ),





            const SizedBox(
                height:4
            ),




            Text(

              user["fullName"] ??
                  user["name"] ??
                  "",



            ),





            const SizedBox(
                height:4
            ),





            Text(

              "الصلاحية: ${user["role"] ?? ""}",


              style:

              const TextStyle(

                color:
                Colors.grey,

              ),



            ),




          ],



        ),







        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            //====================================
            // زر التعديل
            //====================================

            IconButton(
              tooltip: "تعديل",

              icon: const Icon(
                Icons.edit,
                color: Colors.blue,
              ),

              onPressed: () async {

                final result =
                await Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        AddUserScreen(
                          user: user,
                        ),
                  ),
                );

                // إذا تم التعديل
                // نعيد تحميل القائمة
                if (result == true) {

                  await loadUsers();

                }
              },
            ),

            //====================================
            // زر الحذف
            //====================================

            IconButton(
              tooltip: "حذف",

              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),

              onPressed: () async {

                final confirm =
                await showDialog<bool>(
                  context: context,

                  builder: (context) {

                    return AlertDialog(

                      title: const Text(
                        "حذف المستخدم",
                      ),

                      content: const Text(
                        "هل تريد حذف المستخدم؟",
                      ),

                      actions: [

                        TextButton(
                          onPressed: () {

                            Navigator.pop(
                              context,
                              false,
                            );

                          },

                          child: const Text(
                            "إلغاء",
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () {

                            Navigator.pop(
                              context,
                              true,
                            );

                          },

                          child: const Text(
                            "حذف",
                          ),
                        ),

                      ],
                    );
                  },
                );

                if (confirm == true) {

                  await deleteUser(
                    user["uid"],
                  );

                }
              },
            ),
          ],
        ),



      ),



    );



  }









  @override
  Widget build(BuildContext context){



    return Scaffold(



      appBar:

      AppBar(



        title:

        const Text(
            "إدارة المستخدمين"
        ),



        centerTitle:
        true,



      ),





      floatingActionButton:



      FloatingActionButton(



        child:

        const Icon(
            Icons.add
        ),




        onPressed:() async {



          await Navigator.push(



            context,



            MaterialPageRoute(



              builder:(_)=>

              const AddUserScreen(),



            ),



          );




          loadUsers();



        },



      ),








      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: (v) {
                setState(() {});
              },
              decoration: const InputDecoration(
                hintText: "بحث باسم المستخدم أو المحطة...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: userService.usersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final liveUsers = snapshot.data ?? [];
                final query = searchController.text.trim().toLowerCase();

                final displayList = liveUsers.where((user) {
                  final name = (user["fullName"] ?? user["name"] ?? "").toString().toLowerCase();
                  final stationName = (user["stationName"] ?? "").toString().toLowerCase();
                  final role = (user["role"] ?? "").toString().toLowerCase();
                  return name.contains(query) || stationName.contains(query) || role.contains(query);
                }).toList();

                if (displayList.isEmpty) {
                  return const Center(child: Text("لا يوجد مستخدمون"));
                }

                return ListView.builder(
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    return userCard(displayList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),



    );



  }







  @override
  void dispose(){



    searchController.dispose();



    super.dispose();


  }



}