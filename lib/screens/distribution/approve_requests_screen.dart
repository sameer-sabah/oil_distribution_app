import 'package:flutter/material.dart';

import '../../core/constants/user_roles.dart';
import '../../models/request_model.dart';
import '../../services/auth_service.dart';
import '../../services/request_service.dart';

class ApproveRequestsScreen extends StatefulWidget {
  const ApproveRequestsScreen({super.key});

  @override
  State<ApproveRequestsScreen> createState() =>
      _ApproveRequestsScreenState();
}

class _ApproveRequestsScreenState
    extends State<ApproveRequestsScreen> {

final RequestService requestService =
RequestService.instance;

final AuthService auth =
AuthService.instance;

final TextEditingController searchController =
TextEditingController();

String filter = "الكل";

final List<String> filters = [
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

backgroundColor:
const Color(0xffF4F7FC),

appBar: AppBar(

backgroundColor:
const Color(0xff0B3C6D),

title: const Text(
"اعتماد طلبات التزويد",
),

centerTitle: true,
),

body: Column(

children: [

_buildHeader(),

Expanded(

child: StreamBuilder<List<RequestModel>>(

stream:
requestService.requestsStream(),

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

if (auth.isStationManager) {

requests = requests.where(

(e) =>
e.stationId ==
auth.currentUser!.stationId,

).toList();
}

if (filter != "الكل") {

requests = requests.where(

(e) => e.status == filter,

).toList();
}

if (searchController.text.isNotEmpty) {

requests = requests.where(

(e) => e.stationName
.toLowerCase()
.contains(
searchController.text
.toLowerCase(),
),

).toList();
}

if (requests.isEmpty) {

return const Center(
child:
Text("لا توجد طلبات"),
);
}

return ListView.builder(

padding:
const EdgeInsets.all(15),

itemCount:
requests.length,

itemBuilder:
(context, index) {

final request =
requests[index];

return _requestCard(
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
//====================================================
// Header
//====================================================

Widget _buildHeader() {
return Container(
margin: const EdgeInsets.all(15),

child: Column(
children: [

Row(
children: [

Expanded(
child: _statCard(
"إجمالي الطلبات",
Icons.assignment,
Colors.blue,
),
),

const SizedBox(width: 10),

Expanded(
child: _statCard(
"قيد المراجعة",
Icons.hourglass_bottom,
Colors.orange,
),
),

const SizedBox(width: 10),

Expanded(
child: _statCard(
"تمت الموافقة",
Icons.check_circle,
Colors.green,
),
),

const SizedBox(width: 10),

Expanded(
child: _statCard(
"مرفوض",
Icons.cancel,
Colors.red,
),
),
],
),

const SizedBox(height: 20),

Row(
children: [

Expanded(
flex: 3,
child: TextField(
controller: searchController,

decoration: InputDecoration(
hintText: "بحث باسم المحطة",

prefixIcon:
const Icon(Icons.search),

border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(12),
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
DropdownButtonFormField<String>(

value: filter,

decoration: InputDecoration(
border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(12),
),
),

items: filters.map((e) {
return DropdownMenuItem(
value: e,
child: Text(e),
);
}).toList(),

onChanged: (v) {
setState(() {
filter = v!;
});
},
),
),
],
),
],
),
);
}

//====================================================
// Statistic Card
//====================================================

Widget _statCard(
String title,
IconData icon,
Color color,
) {
return Card(
elevation: 4,

child: Padding(
padding:
const EdgeInsets.symmetric(
vertical: 18,
horizontal: 10,
),

child: Column(
children: [

Icon(
icon,
color: color,
size: 34,
),

const SizedBox(height: 10),

Text(
title,
textAlign: TextAlign.center,
style: const TextStyle(
fontWeight:
FontWeight.bold,
),
),
],
),
),
);
}
//====================================================
// بطاقة الطلب
//====================================================

Widget _requestCard(RequestModel request) {
return Card(
margin: const EdgeInsets.only(bottom: 15),
elevation: 5,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
child: Padding(
padding: const EdgeInsets.all(16),
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
_statusColor(request.status)
.withOpacity(.15),

label: Text(
_statusText(request.status),
style: TextStyle(
color:
_statusColor(request.status),
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
),

Text(
"مدير المحطة : ${request.managerId}",
),

Text(
"الملاحظات : ${request.notes}",
),

const Divider(),

...request.items.map(
(item) => Padding(
padding:
const EdgeInsets.symmetric(
vertical: 4,
),
child: Row(
children: [

Expanded(
flex: 3,
child: Text(
item.productName,
style: const TextStyle(
fontWeight:
FontWeight.bold,
),
),
),

Expanded(
child: Text(
"${item.requestedQuantity.toStringAsFixed(0)} لتر",
textAlign:
TextAlign.center,
),
),
],
),
),
),

const SizedBox(height: 15),

Row(
children: [

Expanded(
child: OutlinedButton.icon(
icon: const Icon(
Icons.visibility,
),
label: const Text(
"التفاصيل",
),
onPressed: () {
_showDetails(request);
},
),
),

if (auth.isDistributionManager &&
request.status == "pending") ...[

const SizedBox(width: 10),

Expanded(
child: ElevatedButton.icon(
style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.green,
),

icon: const Icon(
Icons.check,
),

label: const Text(
"اعتماد",
),

onPressed: () {
_approveDialog(
request,
);
},
),
),

const SizedBox(width: 10),

Expanded(
child: ElevatedButton.icon(
style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.red,
),

icon: const Icon(
Icons.close,
),

label: const Text(
"رفض",
),

onPressed: () {
_rejectDialog(
request,
);
},
),
),
],
],
),
],
),
),
);
}
//====================================================
// اعتماد الطلب
//====================================================

void _approveDialog(
RequestModel request,
) {
final List<TextEditingController> controllers = [];

for (final item in request.items) {
controllers.add(
TextEditingController(
text: item.requestedQuantity.toString(),
),
);
}

showDialog(
context: context,
barrierDismissible: false,
builder: (context) {
return AlertDialog(
title: const Text("اعتماد الطلب"),

content: SizedBox(
width: 650,
child: SingleChildScrollView(
child: Column(
children: [

...List.generate(
request.items.length,
(index) {

final item =
request.items[index];

return Card(
margin: const EdgeInsets.only(
bottom: 10,
),
child: Padding(
padding:
const EdgeInsets.all(12),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

Text(
item.productName,
style: const TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 17,
),
),

const SizedBox(height: 10),

Text(
"الكمية المطلوبة : ${item.requestedQuantity}",
),

const SizedBox(height: 10),

TextField(
controller:
controllers[index],

keyboardType:
TextInputType.number,

decoration:
const InputDecoration(
labelText:
"الكمية المعتمدة",
border:
OutlineInputBorder(),
),
),
],
),
),
);
},
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

ElevatedButton.icon(
style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.green,
),

icon: const Icon(
Icons.check,
),

label: const Text(
"اعتماد",
),

onPressed: () async {

final List<RequestItem>
approvedItems = [];

for (int i = 0;
i < request.items.length;
i++) {

final item =
request.items[i];

approvedItems.add(
item.copyWith(
approvedQuantity:
double.tryParse(
controllers[i].text,
) ??
item.requestedQuantity,
),
);
}

await requestService.approveRequest(
requestId: request.id,
approvedBy:
auth.currentUser!.fullName,
items: approvedItems,
);

if (mounted) {
Navigator.pop(context);

ScaffoldMessenger.of(context)
.showSnackBar(
const SnackBar(
content: Text(
"تم اعتماد الطلب بنجاح",
),
),
);
}
},
),
],
);
},
);
}
  //====================================================
  // رفض الطلب
  //====================================================

  void _rejectDialog(RequestModel request) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("رفض الطلب"),
          content: TextField(
            controller: reasonController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "سبب الرفض",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) {
                  return;
                }

                await requestService.rejectRequest(
                  requestId: request.id,
                  rejectedBy: auth.currentUser!.fullName,
                  reason: reasonController.text.trim(),
                );

                if (mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم رفض الطلب"),
                    ),
                  );
                }
              },
              child: const Text("رفض"),
            ),
          ],
        );
      },
    );
  }

  //====================================================
  // تفاصيل الطلب
  //====================================================

  void _showDetails(RequestModel request) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(request.stationName),
          content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Text(
                    "الحالة : ${_statusText(request.status)}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "مدير المحطة : ${request.managerId}",
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "الملاحظات : ${request.notes}",
                  ),

                  const Divider(),

                  const Text(
                    "المنتجات",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...request.items.map(
                        (item) => ListTile(
                      title: Text(item.productName),
                      subtitle: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "الحالي : ${item.currentQuantity}",
                          ),
                          Text(
                            "المطلوب : ${item.requestedQuantity}",
                          ),
                          Text(
                            "المعتمد : ${item.approvedQuantity}",
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (request.approvedBy.isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 15),
                      child: Text(
                        "اعتمد بواسطة : ${request.approvedBy}",
                      ),
                    ),

                  if (request.rejectReason.isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 10),
                      child: Text(
                        "سبب الرفض : ${request.rejectReason}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("إغلاق"),
            ),
          ],
        );
      },
    );
  }

  //====================================================
  // لون الحالة
  //====================================================

  Color _statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;

      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      case "in_progress":
        return Colors.blue;

      case "delivered":
        return Colors.indigo;

      case "received":
        return Colors.teal;

      default:
        return Colors.grey;
    }
  }

  //====================================================
  // اسم الحالة
  //====================================================

  String _statusText(String status) {
    switch (status) {
      case "pending":
        return "قيد المراجعة";

      case "approved":
        return "تمت الموافقة";

      case "rejected":
        return "مرفوض";

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
}