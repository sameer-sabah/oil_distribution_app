import 'package:flutter/material.dart';
import 'package:oil_distribution_app/services/notification_service.dart';

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
  final NotificationService notificationService =
      NotificationService.instance;



  List<Map<String, dynamic>> notifications = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {

    try {
      final result =
      await notificationService.getUserNotifications(
        widget.userId,
      );

      // ترتيب الأحدث أولاً
      result.sort((a, b) {
        final dateA = DateTime.tryParse(
          a["createdAt"]?.toString() ?? "",
        ) ??
            DateTime(2000);

        final dateB = DateTime.tryParse(
          b["createdAt"]?.toString() ?? "",
        ) ??
            DateTime(2000);

        return dateB.compareTo(dateA);
      });

      if (!mounted) return;

      setState(() {
        notifications = result;
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
            "تعذر تحميل الإشعارات: $e",
          ),
        ),
      );
    }
  }

  IconData getNotificationIcon(String type) {
    switch (type) {
      case "product_empty":
        return Icons.error_outline;

      case "low_quantity":
        return Icons.warning_amber_rounded;

      case "quantity_update":
        return Icons.inventory_2;

      default:
        return Icons.notifications;
    }
  }

  Color getNotificationColor(String type) {
    switch (type) {
      case "product_empty":
        return Colors.red;

      case "low_quantity":
        return Colors.orange;

      case "quantity_update":
        return Colors.green;

      default:
        return Colors.blue;
    }
  }

  String formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      appBar: AppBar(
        title: const Text("الإشعارات"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B3C6D),

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "تحديث",
            onPressed: loadNotifications,
          ),
        ],
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : notifications.isEmpty
          ? RefreshIndicator(
        onRefresh: loadNotifications,
        child: ListView(
          children: const [
            SizedBox(height: 180),

            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey,
            ),

            SizedBox(height: 15),

            Center(
              child: Text(
                "لا توجد إشعارات حالياً",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: loadNotifications,

        child: ListView.builder(
          padding: const EdgeInsets.all(16),

          itemCount: notifications.length,

          itemBuilder: (context, index) {
            final item =
            notifications[index];

            final type =
                item["type"]?.toString() ??
                    "station";

            final title =
                item["title"]?.toString() ??
                    "إشعار";

            final message =
                item["message"]?.toString() ??
                    "";

            final createdAt =
                item["createdAt"]
                    ?.toString() ??
                    "";

            final read =
                item["read"] == true;

            final color =
            getNotificationColor(type);

            return Card(
              elevation: read ? 2 : 5,

              margin:
              const EdgeInsets.only(
                bottom: 12,
              ),

              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(18),
              ),

              child: ListTile(
                contentPadding:
                const EdgeInsets.all(14),

                leading: CircleAvatar(
                  radius: 27,

                  backgroundColor:
                  color.withValues(
                    alpha: 0.15,
                  ),

                  child: Icon(
                    getNotificationIcon(
                      type,
                    ),
                    color: color,
                    size: 28,
                  ),
                ),

                title: Text(
                  title,

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                subtitle: Padding(
                  padding:
                  const EdgeInsets.only(
                    top: 8,
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      Text(
                        message,
                        style:
                        const TextStyle(
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        formatDate(
                          createdAt,
                        ),
                        style:
                        const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                trailing: !read
                    ? Container(
                  width: 10,
                  height: 10,
                  decoration:
                  BoxDecoration(
                    color: color,
                    shape:
                    BoxShape.circle,
                  ),
                )
                    : const Icon(
                  Icons.done,
                  color: Colors.grey,
                ),

                onTap: () async {
                  final id =
                  item["id"]
                      ?.toString();

                  if (id == null ||
                      id.isEmpty) {
                    return;
                  }

                  await notificationService
                      .markAsRead(id);

                  await loadNotifications();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}