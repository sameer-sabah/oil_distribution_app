import 'package:flutter/material.dart';

import '../../services/user_service.dart';
import 'add_user_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({
    super.key,
  });

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserService userService = UserService.instance;

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  final TextEditingController searchController =
  TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  //====================================
  // جلب المستخدمين
  //====================================

  Future<void> loadUsers() async {
    try {
      final result = await userService.getUsers();

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
            "حدث خطأ في جلب المستخدمين: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //====================================
  // البحث
  //====================================

  void search(String value) {
    final searchValue = value.toLowerCase().trim();

    setState(() {
      filteredUsers = users.where((user) {
        final name = (user["fullName"] ??
            user["name"] ??
            "")
            .toString()
            .toLowerCase();

        final username = (user["username"] ?? "")
            .toString()
            .toLowerCase();

        final stationName = (user["stationName"] ?? "")
            .toString()
            .toLowerCase();

        return name.contains(searchValue) ||
            username.contains(searchValue) ||
            stationName.contains(searchValue);
      }).toList();
    });
  }

  //====================================
  // حذف المستخدم
  //====================================

  Future<void> deleteUser(String uid) async {
    try {
      await userService.deleteUser(uid);

      await loadUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "تم حذف المستخدم بنجاح",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "حدث خطأ أثناء حذف المستخدم: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //====================================
  // بطاقة المستخدم
  //====================================

  Widget userCard(
      Map<String, dynamic> user,
      ) {
    final role = user["role"] ?? "";

    String roleName = role.toString();

    if (role == "stationManager") {
      roleName = "مدير محطة";
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      elevation: 3,
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(
            Icons.person,
          ),
        ),

        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              user["stationName"] ??
                  "بدون اسم محطة",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              user["fullName"] ??
                  user["name"] ??
                  "",
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              "اسم المستخدم: ${user["username"] ?? ""}",
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              "الصلاحية: $roleName",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),

        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: "delete",
              child: Text(
                "حذف",
              ),
            ),
          ],

          onSelected: (value) async {
            if (value != "delete") {
              return;
            }

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
              final uid =
              user["uid"]?.toString();

              if (uid != null &&
                  uid.isNotEmpty) {
                await deleteUser(uid);
              }
            }
          },
        ),
      ),
    );
  }

  //====================================
  // الواجهة
  //====================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "إدارة المستخدمين",
        ),
        centerTitle: true,
      ),

      //================================
      // زر إضافة مستخدم
      //================================

      floatingActionButton:
      FloatingActionButton(
        child: const Icon(
          Icons.add,
        ),

        onPressed: () async {
          final result =
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const AddUserScreen(),
            ),
          );

          if (result == true) {
            await loadUsers();
          }
        },
      ),

      body: Column(
        children: [
          //================================
          // البحث
          //================================

          Padding(
            padding:
            const EdgeInsets.all(10),
            child: TextField(
              controller:
              searchController,
              onChanged: search,
              decoration:
              const InputDecoration(
                hintText: "بحث...",
                prefixIcon:
                Icon(Icons.search),
                border:
                OutlineInputBorder(),
              ),
            ),
          ),

          //================================
          // المستخدمون
          //================================

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
              ),
            )
                : RefreshIndicator(
              onRefresh: loadUsers,
              child:
              ListView.builder(
                itemCount:
                filteredUsers
                    .length,
                itemBuilder:
                    (context, index) {
                  return userCard(
                    filteredUsers[
                    index],
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