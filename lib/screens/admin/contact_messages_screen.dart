import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ContactMessagesScreen extends StatelessWidget {
  const ContactMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference ref =
    FirebaseDatabase.instance.ref('contactMessages');

    return Scaffold(
      appBar: AppBar(
        title: const Text('رسائل التواصل'),
        centerTitle: true,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          // ==================================================
          // خطأ في القراءة
          // ==================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'حدث خطأ أثناء قراءة رسائل التواصل:\n\n'
                      '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // ==================================================
          // جاري التحميل
          // ==================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final DatabaseEvent? event = snapshot.data;

          if (event == null) {
            return const Center(
              child: Text('لا توجد بيانات'),
            );
          }

          final DataSnapshot dataSnapshot =
              event.snapshot;

          // ==================================================
          // لا توجد رسائل
          // ==================================================

          if (!dataSnapshot.exists ||
              dataSnapshot.children.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد رسائل تواصل حالياً',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          // ==================================================
          // قراءة الرسائل من children
          // ==================================================

          final List<DataSnapshot> messages =
          dataSnapshot.children.toList();

          // ==================================================
          // ترتيب الأحدث أولاً
          // ==================================================

          messages.sort((a, b) {
            final Object? aCreated =
                a.child('createdAt').value;

            final Object? bCreated =
                b.child('createdAt').value;

            final String aDate =
                aCreated?.toString() ?? '';

            final String bDate =
                bCreated?.toString() ?? '';

            return bDate.compareTo(aDate);
          });

          // ==================================================
          // عرض الرسائل
          // ==================================================

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final DataSnapshot messageSnapshot =
              messages[index];

              final String messageId =
                  messageSnapshot.key ?? '';

              final String subject =
                  messageSnapshot
                      .child('subject')
                      .value
                      ?.toString() ??
                      'بدون موضوع';

              final String message =
                  messageSnapshot
                      .child('message')
                      .value
                      ?.toString() ??
                      '';

              final String phone =
                  messageSnapshot
                      .child('phone')
                      .value
                      ?.toString() ??
                      '';

              final String userId =
                  messageSnapshot
                      .child('userId')
                      .value
                      ?.toString() ??
                      '';

              final String status =
                  messageSnapshot
                      .child('status')
                      .value
                      ?.toString() ??
                      'new';

              final String createdAt =
                  messageSnapshot
                      .child('createdAt')
                      .value
                      ?.toString() ??
                      '';

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // العنوان
                      // ==================================================

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            child: Icon(
                              Icons.message,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Text(
                              subject.isEmpty
                                  ? 'بدون موضوع'
                                  : subject,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),

                          if (status == 'new')
                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration:
                              BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                BorderRadius.circular(
                                  20,
                                ),
                              ),
                              child: const Text(
                                'جديد',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // ==================================================
                      // نص الرسالة
                      // ==================================================

                      Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                          Colors.grey.shade100,
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: Text(
                          message.isEmpty
                              ? 'لا يوجد نص للرسالة'
                              : message,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // ==================================================
                      // الهاتف
                      // ==================================================

                      if (phone.isNotEmpty)
                        Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 7,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 18,
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Expanded(
                                child: Text(
                                  'الهاتف: $phone',
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ==================================================
                      // المستخدم
                      // ==================================================

                      if (userId.isNotEmpty)
                        Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 7,
                          ),
                          child: Text(
                            'المستخدم: $userId',
                            style: TextStyle(
                              color:
                              Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      // ==================================================
                      // التاريخ
                      // ==================================================

                      if (createdAt.isNotEmpty)
                        Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Text(
                            'تاريخ الإرسال: $createdAt',
                            style: TextStyle(
                              color:
                              Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const Divider(),

                      // ==================================================
                      // أزرار الإدارة
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.end,
                        children: [
                          // تمت المعالجة
                          if (status == 'new')
                            TextButton.icon(
                              onPressed: () async {
                                try {
                                  await ref
                                      .child(messageId)
                                      .update({
                                    'status':
                                    'processed',
                                  });

                                  if (!context
                                      .mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger
                                      .of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'تمت معالجة الرسالة',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context
                                      .mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger
                                      .of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'فشل تحديث الرسالة: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              label: const Text(
                                'تمت المعالجة',
                              ),
                            ),

                          // حذف
                          IconButton(
                            tooltip:
                            'حذف الرسالة',
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              final bool?
                              confirmed =
                              await showDialog<
                                  bool>(
                                context: context,
                                builder:
                                    (dialogContext) {
                                  return AlertDialog(
                                    title:
                                    const Text(
                                      'حذف الرسالة',
                                    ),
                                    content:
                                    const Text(
                                      'هل أنت متأكد من حذف هذه الرسالة؟',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () {
                                          Navigator.pop(
                                            dialogContext,
                                            false,
                                          );
                                        },
                                        child:
                                        const Text(
                                          'إلغاء',
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            () {
                                          Navigator.pop(
                                            dialogContext,
                                            true,
                                          );
                                        },
                                        child:
                                        const Text(
                                          'حذف',
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmed !=
                                  true) {
                                return;
                              }

                              try {
                                await ref
                                    .child(messageId)
                                    .remove();

                                if (!context
                                    .mounted) {
                                  return;
                                }

                                ScaffoldMessenger
                                    .of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تم حذف الرسالة بنجاح',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!context
                                    .mounted) {
                                  return;
                                }

                                ScaffoldMessenger
                                    .of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'فشل حذف الرسالة: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}