import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'add_user_screen.dart';
class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() =>
      _UsersManagementScreenState();
}

class _UsersManagementScreenState
    extends State<UsersManagementScreen> {

  final TextEditingController searchController =
  TextEditingController();

  List<AppUser> users = [];
  List<AppUser> filteredUsers = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadUsers();

    searchController.addListener(() {
      filterUsers();
    });
  }

  //====================================
  // جلب المستخدمين
  //====================================

  Future<void> loadUsers() async {
    try {
      setState(() {
        loading = true;
      });

      final result =
      await AuthService.instance.getUsers();

      if (!mounted) return;

      setState(() {
        users = result;
        filteredUsers = result;
        loading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "حدث خطأ أثناء جلب المستخدمين: $e",
          ),
        ),
      );
    }
  }

  //====================================
  // البحث
  //====================================

  void filterUsers() {
    final query =
    searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredUsers = users;
      } else {
        filteredUsers = users.where((user) {
          return user.fullName
              .toLowerCase()
              .contains(query) ||
              user.username
                  .toLowerCase()
                  .contains(query) ||
              user.email
                  .toLowerCase()
                  .contains(query) ||
              user.phone
                  .toLowerCase()
                  .contains(query);
        }).toList();
      }
    });
  }

  //====================================
  // لون الحالة
  //====================================

  Color statusColor(bool active) {
    return active ? Colors.green : Colors.red;
  }

  //====================================
  // الواجهة
  //====================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      floatingActionButton:
      FloatingActionButton.extended(

        icon: const Icon(Icons.person_add),

        label: const Text(
          "إضافة مستخدم",
        ),

        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddUserScreen(),
            ),
          );

          if (result == true) {
            await loadUsers();
          }
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
              controller: searchController,

              decoration:
              InputDecoration(
                hintText:
                "ابحث عن مستخدم",

                prefixIcon:
                const Icon(
                  Icons.search,
                ),

                suffixIcon:
                IconButton(
                  icon:
                  const Icon(
                    Icons.refresh,
                  ),

                  onPressed:
                  loadUsers,
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

          const SizedBox(height: 10),

          Expanded(

            child: loading

                ? const Center(
              child:
              CircularProgressIndicator(),
            )

                : filteredUsers.isEmpty

                ? const Center(
              child: Text(
                "لا يوجد مستخدمون",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )

                : RefreshIndicator(

              onRefresh:
              loadUsers,

              child:
              ListView.builder(

                padding:
                const EdgeInsets
                    .all(10),

                itemCount:
                filteredUsers
                    .length,

                itemBuilder:
                    (context, index) {

                  final user =
                  filteredUsers[
                  index];

                  return Card(

                    margin:
                    const EdgeInsets
                        .only(
                      bottom: 10,
                    ),

                    child: ListTile(

                      leading:
                      CircleAvatar(

                        backgroundColor:
                        statusColor(
                          user.active,
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
                        user.fullName
                            .isEmpty
                            ? "بدون اسم"
                            : user.fullName,
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

                        children: [

                          Text(
                            "اسم المستخدم: ${user.username}",
                          ),

                          Text(
                            "الدور: ${user.role}",
                          ),

                          if (user.branchName
                              .isNotEmpty)
                            Text(
                              "الفرع: ${user.branchName}",
                            ),

                          if (user.stationName
                              .isNotEmpty)
                            Text(
                              "المحطة: ${user.stationName}",
                            ),

                          Text(
                            user.active
                                ? "الحالة: فعال"
                                : "الحالة: غير فعال",
                            style:
                            TextStyle(
                              color:
                              statusColor(
                                user.active,
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
                            (value) {

                          if (value == 1) {

                            // تعديل
                            ScaffoldMessenger
                                .of(context)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                Text(
                                  "سنضيف شاشة التعديل في الخطوة التالية",
                                ),
                              ),
                            );

                          } else if (value == 2) {

                            // حذف
                            ScaffoldMessenger
                                .of(context)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                Text(
                                  "سنضيف الحذف في الخطوة التالية",
                                ),
                              ),
                            );
                          }
                        },

                        itemBuilder:
                            (context) {

                          return [

                            const PopupMenuItem(
                              value: 1,
                              child:
                              Text(
                                "تعديل",
                              ),
                            ),

                            const PopupMenuItem(
                              value: 2,
                              child:
                              Text(
                                "حذف",
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
    );
  }

  @override
  void dispose() {

    searchController.dispose();

    super.dispose();
  }
}