import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../services/request_service.dart';

class SupplyRequestsScreen extends StatefulWidget {
  const SupplyRequestsScreen({super.key});

  @override
  State<SupplyRequestsScreen> createState() =>
      _SupplyRequestsScreenState();
}

class _SupplyRequestsScreenState
    extends State<SupplyRequestsScreen> {

  final RequestService _service =
      RequestService.instance;

  final TextEditingController _searchController =
  TextEditingController();

  String _selectedStatus = "الكل";

  final List<String> statuses = [
    "الكل",
    "pending",
    "approved",
    "rejected",
    "in_progress",
    "delivered",
    "received",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff0B3C6D),
        title: const Text("طلبات التزويد"),
        centerTitle: true,
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        backgroundColor:
        const Color(0xff0B3C6D),
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text("طلب جديد"),
      ),

      body: Column(
        children: [

          Padding(
            padding:
            const EdgeInsets.all(12),

            child: Row(
              children: [

                Expanded(
                  flex: 3,
                  child: TextField(
                    controller:
                    _searchController,

                    decoration:
                    InputDecoration(
                      hintText:
                      "بحث باسم المحطة",

                      prefixIcon:
                      const Icon(
                        Icons.search,
                      ),

                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(12),
                      ),
                    ),

                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  flex: 2,
                  child:
                  DropdownButtonFormField<
                      String>(
                    value:
                    _selectedStatus,

                    decoration:
                    InputDecoration(
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(12),
                      ),
                    ),

                    items: statuses
                        .map(
                          (e) =>
                          DropdownMenuItem(
                            value: e,
                            child:
                            Text(e),
                          ),
                    )
                        .toList(),

                    onChanged: (value) {
                      setState(() {
                        _selectedStatus =
                        value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child:
            StreamBuilder<List<RequestModel>>(
              stream:
              _service.requestsStream(),

              builder:
                  (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child:
                    Text("لا توجد بيانات"),
                  );
                }

                List<RequestModel> requests =
                snapshot.data!;

                if (_selectedStatus !=
                    "الكل") {
                  requests = requests
                      .where(
                        (e) =>
                    e.status ==
                        _selectedStatus,
                  )
                      .toList();
                }

                if (_searchController
                    .text
                    .isNotEmpty) {
                  requests = requests
                      .where(
                        (e) => e.stationName
                        .toLowerCase()
                        .contains(
                      _searchController
                          .text
                          .toLowerCase(),
                    ),
                  )
                      .toList();
                }

                if (requests.isEmpty) {
                  return const Center(
                    child:
                    Text("لا توجد طلبات"),
                  );
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.all(12),

                  itemCount:
                  requests.length,

                  itemBuilder:
                      (context, index) {

                    final request =
                    requests[index];

                    return _buildRequestCard(
                      request,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
//========================================
// بطاقة الطلب
//========================================

  Widget _buildRequestCard(
      RequestModel request,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                Expanded(
                  child: Text(
                    request.stationName,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                Chip(
                  backgroundColor:
                  _statusColor(
                    request.status,
                  ).withOpacity(.15),

                  label: Text(
                    _statusText(
                      request.status,
                    ),
                    style: TextStyle(
                      color: _statusColor(
                        request.status,
                      ),
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              "عدد المنتجات : ${request.items.length}",
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "تاريخ الإنشاء : ${request.createdAt}",
              style: const TextStyle(
                fontSize: 14,
              ),
            ),

            if (request.notes.isNotEmpty)
              Padding(
                padding:
                const EdgeInsets.only(
                  top: 8,
                ),
                child: Text(
                  request.notes,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

            const SizedBox(height: 15),

            Row(
              children: [

                Expanded(
                  child:
                  OutlinedButton.icon(
                    onPressed: () {
                      _showDetails(
                        request,
                      );
                    },

                    icon: const Icon(
                      Icons.visibility,
                    ),

                    label: const Text(
                      "التفاصيل",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                if (request.status ==
                    "pending")
                  Expanded(
                    child:
                    ElevatedButton.icon(
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.green,
                      ),

                      onPressed: () {

                        _service
                            .approveRequest(
                          requestId:
                          request.id,

                          approvedBy:
                          "مدير التوزيع",

                          items:
                          request.items,
                        );
                      },

                      icon: const Icon(
                        Icons.check,
                      ),

                      label:
                      const Text(
                        "اعتماد",
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

//========================================
// لون الحالة
//========================================

  Color _statusColor(
      String status,
      ) {

    switch (status) {

      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      case "pending":
        return Colors.orange;

      case "in_progress":
        return Colors.blue;

      case "delivered":
        return Colors.deepPurple;

      case "received":
        return Colors.teal;

      default:
        return Colors.grey;
    }
  }

//========================================
// اسم الحالة
//========================================

  String _statusText(
      String status,
      ) {

    switch (status) {

      case "approved":
        return "تمت الموافقة";

      case "rejected":
        return "مرفوض";

      case "pending":
        return "قيد المراجعة";

      case "in_progress":
        return "قيد التجهيز";

      case "delivered":
        return "تم الإرسال";

      case "received":
        return "تم الاستلام";

      default:
        return status;
    }
  }
//========================================
// نافذة إنشاء طلب جديد
//========================================

  void _showCreateDialog() {
    final stationController = TextEditingController();
    final stationIdController = TextEditingController();
    final notesController = TextEditingController();

    final List<RequestItem> items = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialog) {
            return AlertDialog(
              title: const Text("إنشاء طلب تزويد"),

              content: SizedBox(
                width: 650,
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      TextField(
                        controller: stationController,
                        decoration: const InputDecoration(
                          labelText: "اسم المحطة",
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: stationIdController,
                        decoration: const InputDecoration(
                          labelText: "رقم المحطة",
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "ملاحظات",
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [

                          ElevatedButton.icon(
                            onPressed: () async {

                              final item =
                              await _showAddItemDialog();

                              if (item != null) {
                                setDialog(() {
                                  items.add(item);
                                });
                              }
                            },

                            icon: const Icon(Icons.add),

                            label: const Text("إضافة منتج"),
                          ),

                          const Spacer(),

                          Text(
                            "عدد المنتجات : ${items.length}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      if (items.isEmpty)
                        const Text(
                          "لا توجد منتجات",
                        ),

                      ...items.map(
                            (item) => Card(
                          child: ListTile(
                            title: Text(item.productName),

                            subtitle: Text(
                              "المطلوب : ${item.requestedQuantity}",
                            ),

                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),

                              onPressed: () {
                                setDialog(() {
                                  items.remove(item);
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("إلغاء"),
                ),

                ElevatedButton(
                  onPressed: () async {

                    if (stationController.text.isEmpty ||
                        items.isEmpty) {
                      return;
                    }

                    final request =
                    RequestModel(
                      id: "",

                      stationId:
                      stationIdController.text,

                      stationName:
                      stationController.text,

                      managerId: "manager",

                      status: "pending",

                      notes:
                      notesController.text,

                      approvedBy: "",

                      approvedAt: null,

                      rejectedBy: "",

                      rejectReason: "",

                      received: false,

                      deliveredAt: null,

                      updatedAt: null,

                      createdAt: DateTime.now(),

                      items: items,
                    );

                    await _service.createRequest(
                      request,
                    );

                    if (mounted) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "تم إرسال الطلب بنجاح",
                          ),
                        ),
                      );
                    }
                  },

                  child: const Text("إرسال"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  //========================================
  // نافذة إضافة منتج
  //========================================

  Future<RequestItem?> _showAddItemDialog() async {

    final productController =
    TextEditingController();

    final currentController =
    TextEditingController();

    final requestedController =
    TextEditingController();

    return await showDialog<RequestItem>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "إضافة منتج",
          ),

          content: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [

              TextField(
                controller:
                productController,

                decoration:
                const InputDecoration(
                  labelText:
                  "اسم المنتج",
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              TextField(
                controller:
                currentController,

                keyboardType:
                TextInputType.number,

                decoration:
                const InputDecoration(
                  labelText:
                  "الكمية الحالية",
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              TextField(
                controller:
                requestedController,

                keyboardType:
                TextInputType.number,

                decoration:
                const InputDecoration(
                  labelText:
                  "الكمية المطلوبة",
                ),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("إلغاء"),
            ),

            ElevatedButton(

              onPressed: () {

                Navigator.pop(

                  context,

                  RequestItem(

                    id: DateTime.now()
                        .millisecondsSinceEpoch
                        .toString(),

                    productName:
                    productController.text,

                    currentQuantity:
                    double.tryParse(
                      currentController.text,
                    ) ??
                        0,

                    requestedQuantity:
                    double.tryParse(
                      requestedController.text,
                    ) ??
                        0,

                    approvedQuantity: 0,
                  ),
                );
              },

              child: const Text(
                "إضافة",
              ),
            ),
          ],
        );
      },
    );
  }

  //========================================
  // تفاصيل الطلب
  //========================================

  void _showDetails(
      RequestModel request,
      ) {

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: Text(
            request.stationName,
          ),

          content: SizedBox(

            width: 600,

            child: SingleChildScrollView(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    "الحالة : ${_statusText(request.status)}",
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "الملاحظات : ${request.notes}",
                  ),

                  const Divider(),

                  const Text(
                    "المنتجات",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  ...request.items.map(

                        (item) => Card(

                      child: ListTile(

                        title: Text(
                          item.productName,
                        ),

                        subtitle: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                              "الكمية الحالية : ${item.currentQuantity}",
                            ),

                            Text(
                              "الكمية المطلوبة : ${item.requestedQuantity}",
                            ),

                            Text(
                              "الكمية المعتمدة : ${item.approvedQuantity}",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (request.approvedBy
                      .isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.only(
                        top: 15,
                      ),
                      child: Text(
                        "اعتمد بواسطة : ${request.approvedBy}",
                      ),
                    ),

                  if (request.rejectReason
                      .isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.only(
                        top: 15,
                      ),
                      child: Text(
                        "سبب الرفض : ${request.rejectReason}",
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          actions: [

            if (request.status ==
                "delivered")

              ElevatedButton.icon(

                onPressed: () async {

                  await _service.receiveRequest(
                    request.id,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                  }
                },

                icon: const Icon(
                  Icons.check_circle,
                ),

                label: const Text(
                  "تأكيد الاستلام",
                ),
              ),

            TextButton(

              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "إغلاق",
              ),
            ),
          ],
        );
      },
    );
  }
}