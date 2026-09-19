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

  final Set<String> localReadIds = {};
  final Set<String> deletedNotificationIds = {};

  final DatabaseReference rootRef =
  FirebaseDatabase.instance.ref("notifications");

  // =========================================================
  // جلب الإشعارات كشريط حي وآمن
  // =========================================================

  Stream<List<Map<String, dynamic>>> notificationsStream() {
    return rootRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return <Map<String, dynamic>>[];
      }

      final List<Map<String, dynamic>> list = [];

      void parseNode(dynamic nodeData, String parentPath) {
        if (nodeData is Map) {
          nodeData.forEach((key, val) {
            if (val is Map) {
              final item = Map<String, dynamic>.from(val);
              item["id"] = key.toString();
              item["_path"] = "$parentPath/${key.toString()}";
              list.add(item);
            }
          });
        } else if (nodeData is List) {
          for (int i = 0; i < nodeData.length; i++) {
            if (nodeData[i] != null && nodeData[i] is Map) {
              final item = Map<String, dynamic>.from(nodeData[i] as Map);
              item["id"] = i.toString();
              item["_path"] = "$parentPath/$i";
              list.add(item);
            }
          }
        }
      }

      if (value is Map) {
        // إذا توفرت عقدة public الإشعارات العامة
        if (value.containsKey("public")) {
          parseNode(value["public"], "notifications/public");
        }
        // إذا توفرت عقدة خاصة بالمستخدم
        if (widget.userId.isNotEmpty && value.containsKey(widget.userId)) {
          parseNode(value[widget.userId], "notifications/${widget.userId}");
        }
        // قراءة الإشعارات المباشرة في جذر العقدة
        value.forEach((key, val) {
          if (key != "public" && key != widget.userId && val is Map) {
            final item = Map<String, dynamic>.from(val);
            item["id"] = key.toString();
            item["_path"] = "notifications/${key.toString()}";
            final uId = (item["userId"] ?? "").toString();
            if (uId == "public" || uId == "all" || uId == widget.userId || widget.userId == "citizen" || uId.isEmpty) {
              list.add(item);
            }
          }
        });
      }

      // إزالة التكرار حسب المعرف ID
      final Map<String, Map<String, dynamic>> uniqueItems = {};
      for (final item in list) {
        final id = item["id"] ?? "";
        if (id.isNotEmpty) {
          uniqueItems[id] = item;
        }
      }

      final resultList = uniqueItems.values.toList();

      resultList.removeWhere((item) => deletedNotificationIds.contains((item["id"] ?? "").toString()));

      // Filter out financial / payment / commercial publishing notifications for citizens
      resultList.removeWhere((item) {
        final type = (item["type"] ?? "").toString().toLowerCase();
        final title = (item["title"] ?? "").toString();
        final msg = (item["message"] ?? "").toString();

        if (type == 'payment' ||
            title.contains('إيصال دفع') ||
            title.contains('دفع ونشر') ||
            msg.contains('استقطاع') ||
            msg.contains('ماستر كارد') ||
            msg.contains('المبلغ')) {
          if (widget.userId.isEmpty || widget.userId == 'citizen' || widget.userId == 'anonymous') {
            return true;
          }
        }
        return false;
      });

      resultList.sort((a, b) {
        return (b["createdAt"] ?? "")
            .toString()
            .compareTo(
          (a["createdAt"] ?? "").toString(),
        );
      });

      return resultList;
    });
  }

  // =========================================================
  // جعل الإشعار مقروء
  // =========================================================

  Future<void> markNotificationRead(Map<String, dynamic> item) async {
    final String path = item["_path"] ?? "notifications/public/${item["id"]}";
    await FirebaseDatabase.instance.ref(path).update({
      "read": true,
    });
  }

  // =========================================================
  // حذف الإشعار
  // =========================================================

  Future<void> deleteNotification(Map<String, dynamic> item) async {
    final String path = item["_path"] ?? "notifications/public/${item["id"]}";
    await FirebaseDatabase.instance.ref(path).remove();
  }

  // =========================================================
  // واجهة الشاشة
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // خلفية ثابتة فاخرة باللون الكحلي
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0B132B)],
                ),
              ),
            ),
            Positioned(
              right: -40,
              top: 80,
              child: Opacity(
                opacity: 0.05,
                child: const Icon(
                  Icons.local_gas_station_rounded,
                  size: 320,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // شريط العنوان
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Text(
                          'الإشعارات والتنبيهات',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: notificationsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                "حدث خطأ في تحميل الإشعارات:\n${snapshot.error}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                              ),
                            ),
                          );
                        }

                        final notifications = snapshot.data ?? [];

                        if (notifications.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_off_rounded, size: 70, color: Color(0xFF94A3B8)),
                                SizedBox(height: 15),
                                Text(
                                  "لا توجد إشعارات حالياً",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final item = notifications[index];
                            final String id = (item["id"] ?? "").toString();
                            final bool read = item["read"] == true || localReadIds.contains(id);
                            final String title = (item["title"] ?? "إشعار").toString();
                            final String body = (item["body"] ?? item["message"] ?? "").toString();
                            final String createdAt = (item["createdAt"] ?? "").toString();
                            final String stationName = (item["stationName"] ?? "").toString();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFDFBF7), Color(0xFFF4EFE6)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: () async {
                                    if (id.isNotEmpty) {
                                      setState(() {
                                        deletedNotificationIds.add(id);
                                      });
                                    }
                                    try {
                                      await deleteNotification(item);
                                    } catch (_) {}
                                  },
                                  onLongPress: () async {
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (dialogContext) {
                                        return AlertDialog(
                                          title: const Text("حذف الإشعار"),
                                          content: const Text("هل تريد حذف هذا الإشعار؟"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(dialogContext, false),
                                              child: const Text("إلغاء"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () => Navigator.pop(dialogContext, true),
                                              child: const Text("حذف"),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (result != true) return;

                                    try {
                                      await deleteNotification(item);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("تم حذف الإشعار"), backgroundColor: Colors.green),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      final err = e.toString();
                                      final String msg = err.contains("Permission denied") || err.contains("permission")
                                          ? "عفواً، الإشعارات العامة لا يمكن حذفها من قبل المواطن"
                                          : "تعذر حذف الإشعار: $e";
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(msg), backgroundColor: Colors.red),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // أيقونة دائرية مذهبة
                                        Container(
                                          padding: const EdgeInsets.all(9),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFD4AF37), Color(0xFF8A6D1C)],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            read ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title.isEmpty ? "إشعار" : title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 16,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                              if (stationName.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.local_gas_station_rounded, size: 14, color: Color(0xFF8A6D1C)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      stationName,
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                              const SizedBox(height: 6),
                                              Text(
                                                body,
                                                style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                                              ),
                                              if (createdAt.isNotEmpty) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  createdAt,
                                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}