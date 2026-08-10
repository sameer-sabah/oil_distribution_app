import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;

  const NotificationsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {

  final DatabaseReference notificationsRef =
  FirebaseDatabase.instance.ref("notifications/public");

  // =========================================================
  // جلب الإشعارات العامة
  // =========================================================

  Stream<List<Map<String, dynamic>>> notificationsStream() {
    return notificationsRef.onValue.map((event) {
      if (event.snapshot.value == null) {
        return <Map<String, dynamic>>[];
      }

      final data = Map<dynamic, dynamic>.from(
        event.snapshot.value as Map,
      );

      final List<Map<String, dynamic>> list = [];

      data.forEach((key, value) {
        final item = Map<String, dynamic>.from(
          value as Map,
        );

        item["id"] = key.toString();

        list.add(item);
      });

      list.sort((a, b) {
        return (b["createdAt"] ?? "")
            .toString()
            .compareTo(
          (a["createdAt"] ?? "").toString(),
        );
      });

      return list;
    });
  }

  // =========================================================
  // جعل الإشعار مقروء
  // =========================================================

  Future<void> markNotificationRead(
      String id,
      ) async {
    await notificationsRef
        .child(id)
        .update({
      "read": true,
    });
  }

  // =========================================================
  // حذف الإشعار
  // =========================================================

  Future<void> deleteNotification(
      String id,
      ) async {
    await notificationsRef
        .child(id)
        .remove();
  }

  // =========================================================
  // واجهة الشاشة
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "الإشعارات",
          ),
          centerTitle: true,
        ),

        body: StreamBuilder<
            List<Map<String, dynamic>>>(
          stream: notificationsStream(),

          builder: (
              context,
              snapshot,
              ) {
            // تحميل
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // خطأ
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "حدث خطأ في تحميل الإشعارات:\n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            }

            final notifications =
                snapshot.data ?? [];

            // لا توجد إشعارات
            if (notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 70,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 15),

                    Text(
                      "لا توجد إشعارات",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            // عرض الإشعارات
            return ListView.builder(
              padding: const EdgeInsets.all(10),

              itemCount:
              notifications.length,

              itemBuilder: (
                  context,
                  index,
                  ) {
                final item =
                notifications[index];

                final bool read =
                    item["read"] == true;

                final String title =
                (item["title"] ?? "")
                    .toString();

                final String body =
                (item["body"] ?? "")
                    .toString();

                final String createdAt =
                (item["createdAt"] ?? "")
                    .toString();

                final String stationName =
                (item["stationName"] ?? "")
                    .toString();

                final String id =
                (item["id"] ?? "")
                    .toString();

                return Card(
                  margin:
                  const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),

                  elevation: 3,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),
                  ),

                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.all(
                      12,
                    ),

                    leading: CircleAvatar(
                      radius: 25,

                      backgroundColor:
                      read
                          ? Colors.grey
                          .shade400
                          : Colors.green
                          .shade600,

                      child: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                    ),

                    title: Text(
                      title.isEmpty
                          ? "إشعار"
                          : title,

                      style: const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    subtitle: Padding(
                      padding:
                      const EdgeInsets.only(
                        top: 7,
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          if (stationName
                              .isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons
                                      .local_gas_station,
                                  size: 16,
                                  color:
                                  Colors.blue,
                                ),

                                const SizedBox(
                                  width: 5,
                                ),

                                Expanded(
                                  child: Text(
                                    stationName,
                                    style:
                                    const TextStyle(
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          if (stationName
                              .isNotEmpty)
                            const SizedBox(
                              height: 6,
                            ),

                          Text(
                            body,
                            style:
                            const TextStyle(
                              fontSize: 14,
                            ),
                          ),

                          if (createdAt
                              .isNotEmpty)
                            const SizedBox(
                              height: 8,
                            ),

                          Text(
                            createdAt,
                            style:
                            const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    trailing: Icon(
                      read
                          ? Icons.done_all
                          : Icons.fiber_new,
                      color: read
                          ? Colors.blue
                          : Colors.red,
                    ),

                    // الضغط على الإشعار
                    onTap: () async {
                      try {
                        await markNotificationRead(
                          id,
                        );
                      } catch (e) {
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              "تعذر تحديث الإشعار: $e",
                            ),
                            backgroundColor:
                            Colors.red,
                          ),
                        );
                      }
                    },

                    // الضغط المطول للحذف
                    onLongPress: () async {
                      final result =
                      await showDialog<bool>(
                        context: context,

                        builder: (
                            dialogContext,
                            ) {
                          return AlertDialog(
                            title: const Text(
                              "حذف الإشعار",
                            ),

                            content:
                            const Text(
                              "هل تريد حذف هذا الإشعار؟",
                            ),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    dialogContext,
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
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  Colors.red,
                                  foregroundColor:
                                  Colors.white,
                                ),

                                onPressed: () {
                                  Navigator.pop(
                                    dialogContext,
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

                      if (result != true) {
                        return;
                      }

                      try {
                        await deleteNotification(
                          id,
                        );

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "تم حذف الإشعار",
                            ),
                            backgroundColor:
                            Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              "تعذر حذف الإشعار: $e",
                            ),
                            backgroundColor:
                            Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}