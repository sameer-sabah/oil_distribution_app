import 'package:flutter/material.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() =>
      _UsersManagementScreenState();
}

class _UsersManagementScreenState
    extends State<UsersManagementScreen> {

  final searchController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      floatingActionButton:
      FloatingActionButton.extended(

        icon: const Icon(Icons.person_add),

        label: const Text("إضافة مستخدم"),

        onPressed: () {

        },

      ),

      body: Column(

        children: [

          const SizedBox(height: 15),

          Padding(

            padding:
            const EdgeInsets.symmetric(
              horizontal: 15,
            ),

            child: TextField(

              controller:
              searchController,

              decoration:
              InputDecoration(

                hintText:
                "ابحث عن مستخدم",

                prefixIcon:
                const Icon(Icons.search),

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

          const SizedBox(height: 15),

          Expanded(

            child: ListView(

              children: [

                Card(

                  margin:
                  const EdgeInsets.all(10),

                  child: ListTile(

                    leading:
                    const CircleAvatar(

                      child: Icon(
                        Icons.person,
                      ),

                    ),

                    title:
                    const Text(
                      "مدير النظام",
                    ),

                    subtitle:
                    const Text(
                      "admin",
                    ),

                    trailing: PopupMenuButton(

                      itemBuilder:
                          (context) {

                        return [

                          const PopupMenuItem(

                            value: 1,

                            child: Text(
                              "تعديل",
                            ),

                          ),

                          const PopupMenuItem(

                            value: 2,

                            child: Text(
                              "حذف",
                            ),

                          ),

                        ];

                      },

                    ),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  @override
  void dispose() {

    searchController.dispose();

    super.dispose();

  }

}
