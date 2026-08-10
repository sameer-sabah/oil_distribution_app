import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/station.dart';
import '../services/database_service.dart';

class ReportsScreen extends StatelessWidget {
const ReportsScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xffF4F6FA),
appBar: AppBar(
elevation: 0,
centerTitle: true,
title: const Text(
"التقارير والإحصائيات",
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),
body: FutureBuilder<List<Station>>(
future: DatabaseService.instance.getStations(),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: Text(snapshot.error.toString()),
);
}

if (!snapshot.hasData ||
snapshot.data!.isEmpty) {
return const Center(
child: Text(
"لا توجد بيانات",
style: TextStyle(fontSize: 22),
),
);
}

final stations = snapshot.data!
    .where((station) => station.active)
    .toList();

final totalStations = stations.length;

final active =
stations.where((e) => e.active).length;

final inactive =
stations.where((e) => !e.active).length;

final approved =
stations.where((e) => e.approved).length;

final notApproved =
stations.where((e) => !e.approved).length;

final regular =
stations.fold(0, (a, b) => a + b.regular95);

final improved =
stations.fold(0, (a, b) => a + b.improved95);

final diesel =
stations.fold(0, (a, b) => a + b.diesel);

final white =
stations.fold(0, (a, b) => a + b.whiteOil);

final totalFuel =
regular +
improved +
diesel +
white;

stations.sort((a, b) {

final fuelA =
a.regular95 +
a.improved95 +
a.diesel +
a.whiteOil;

final fuelB =
b.regular95 +
b.improved95 +
b.diesel +
b.whiteOil;

return fuelB.compareTo(fuelA);

});

return ListView(
padding: const EdgeInsets.all(16),
children: [

const Text(
"لوحة التحكم",
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height:20),

GridView.count(
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
crossAxisCount: 2,
crossAxisSpacing: 12,
mainAxisSpacing: 12,
childAspectRatio: 1.1,
children: [

reportCard(
"عدد المحطات",
"$totalStations",
Icons.local_gas_station,
Colors.blue,
),

reportCard(
"المحطات العاملة",
"$active",
Icons.check_circle,
Colors.green,
),

reportCard(
"المحطات المتوقفة",
"$inactive",
Icons.cancel,
Colors.red,
),

reportCard(
"الموافق عليها",
"$approved",
Icons.verified,
Colors.orange,
),

reportCard(
"غير الموافق عليها",
"$notApproved",
Icons.warning,
Colors.deepOrange,
),

reportCard(
"إجمالي الوقود",
"$totalFuel لتر",
Icons.oil_barrel,
Colors.indigo,
),
],
),

const SizedBox(height:35),

const Text(
"توزيع المنتجات النفطية",
style: TextStyle(
fontSize:20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height:20),

SizedBox(
height:280,
child: PieChart(
PieChartData(
centerSpaceRadius:45,
sectionsSpace:4,
sections: [

PieChartSectionData(
color: Colors.green,
value: regular.toDouble(),
title: "عادي",
radius:75,
),

PieChartSectionData(
color: Colors.blue,
value: improved.toDouble(),
title: "محسن",
radius:75,
),

PieChartSectionData(
color: Colors.orange,
value: diesel.toDouble(),
title: "كاز",
radius:75,
),

PieChartSectionData(
color: Colors.red,
value: white.toDouble(),
title: "أبيض",
radius:75,
),

],
),
),
),              const SizedBox(height: 30),

const Text(
"مقارنة كميات الوقود",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

SizedBox(
height: 300,
child: BarChart(
BarChartData(
alignment: BarChartAlignment.spaceAround,
maxY: [
regular.toDouble(),
improved.toDouble(),
diesel.toDouble(),
white.toDouble(),
].reduce((a, b) => a > b ? a : b) *
1.2,

borderData: FlBorderData(show: false),

gridData: const FlGridData(show: true),

titlesData: FlTitlesData(
rightTitles: const AxisTitles(
sideTitles: SideTitles(showTitles: false),
),
topTitles: const AxisTitles(
sideTitles: SideTitles(showTitles: false),
),
leftTitles: const AxisTitles(
sideTitles: SideTitles(showTitles: true),
),
bottomTitles: AxisTitles(
sideTitles: SideTitles(
showTitles: true,
getTitlesWidget: (value, meta) {
switch (value.toInt()) {
case 0:
return const Text("عادي");
case 1:
return const Text("محسن");
case 2:
return const Text("كاز");
case 3:
return const Text("أبيض");
}

return const SizedBox();
},
),
),
),

barGroups: [

BarChartGroupData(
x: 0,
barRods: [
BarChartRodData(
toY: regular.toDouble(),
color: Colors.green,
width: 28,
borderRadius:
BorderRadius.circular(8),
)
],
),

BarChartGroupData(
x: 1,
barRods: [
BarChartRodData(
toY: improved.toDouble(),
color: Colors.blue,
width: 28,
borderRadius:
BorderRadius.circular(8),
)
],
),

BarChartGroupData(
x: 2,
barRods: [
BarChartRodData(
toY: diesel.toDouble(),
color: Colors.orange,
width: 28,
borderRadius:
BorderRadius.circular(8),
)
],
),

BarChartGroupData(
x: 3,
barRods: [
BarChartRodData(
toY: white.toDouble(),
color: Colors.red,
width: 28,
borderRadius:
BorderRadius.circular(8),
)
],
),
],
),
),
),

const SizedBox(height: 35),

const Text(
"أفضل 5 محطات من حيث المخزون",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

...stations.take(5).map((station) {

final fuel =
station.regular95 +
station.improved95 +
station.diesel +
station.whiteOil;

return Card(
elevation: 3,
child: ListTile(

leading: const CircleAvatar(
child: Icon(Icons.local_gas_station),
),

title: Text(station.name),

subtitle: Text(
"${station.governorate} - ${station.district}",
),

trailing: Text(
"$fuel لتر",
style: const TextStyle(
fontWeight: FontWeight.bold,
color: Colors.green,
),
),
),
);

}).toList(),

const SizedBox(height: 30),

const Text(
"كميات الوقود",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

fuelTile(
"البنزين العادي",
regular,
Colors.green,
),

fuelTile(
"البنزين المحسن",
improved,
Colors.blue,
),

fuelTile(
"زيت الغاز",
diesel,
Colors.orange,
),

fuelTile(
"النفط الأبيض",
white,
Colors.red,
),              const SizedBox(height: 35),

const Text(
"أقل 5 محطات من حيث المخزون",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

...stations.reversed.take(5).map((station) {

final fuel =
station.regular95 +
station.improved95 +
station.diesel +
station.whiteOil;

return Card(
elevation: 3,
child: ListTile(

leading: const CircleAvatar(
backgroundColor: Colors.red,
child: Icon(
Icons.warning,
color: Colors.white,
),
),

title: Text(station.name),

subtitle: Text(
"${station.governorate} - ${station.district}",
),

trailing: Text(
"$fuel لتر",
style: const TextStyle(
color: Colors.red,
fontWeight: FontWeight.bold,
),
),
),
);

}).toList(),

const SizedBox(height: 35),

const Text(
"إحصائيات حسب المحافظة",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

..._governorateStatistics(stations),

const SizedBox(height: 35),

Row(
children: [

Expanded(
child: ElevatedButton.icon(

onPressed: () {

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"سيتم إضافة تصدير PDF قريباً",
),
),
);

},

icon: const Icon(Icons.picture_as_pdf),

label: const Text("PDF"),

style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
foregroundColor: Colors.white,
minimumSize: const Size.fromHeight(55),
),
),
),

const SizedBox(width: 12),

Expanded(
child: ElevatedButton.icon(

onPressed: () {

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"سيتم إضافة Excel قريباً",
),
),
);

},

icon: const Icon(Icons.table_chart),

label: const Text("Excel"),

style: ElevatedButton.styleFrom(
backgroundColor: Colors.green,
foregroundColor: Colors.white,
minimumSize: const Size.fromHeight(55),
),
),
),

],
),

const SizedBox(height: 15),

SizedBox(
height: 55,
child: ElevatedButton.icon(

onPressed: () {

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"ميزة الطباعة سيتم إضافتها قريباً",
),
),
);

},

icon: const Icon(Icons.print),

label: const Text("طباعة التقرير"),

),
),

const SizedBox(height: 40),

],
);
},
),
);
}Widget reportCard(
String title,
String value,
IconData icon,
Color color,
) {
return Card(
elevation: 6,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(18),
),
child: Container(
padding: const EdgeInsets.all(16),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [

CircleAvatar(
radius: 28,
backgroundColor: color.withValues(alpha:.15),
child: Icon(
icon,
color: color,
size: 30,
),
),

const SizedBox(height: 12),

Text(
title,
textAlign: TextAlign.center,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

Text(
value,
style: TextStyle(
color: color,
fontWeight: FontWeight.bold,
fontSize: 26,
),
),
],
),
),
);
}

Widget fuelTile(
String title,
int value,
Color color,
) {
return Card(
child: ListTile(
leading: CircleAvatar(
backgroundColor: color,
child: const Icon(
Icons.local_gas_station,
color: Colors.white,
),
),
title: Text(title),
trailing: Text(
"$value لتر",
style: TextStyle(
color: color,
fontWeight: FontWeight.bold,
fontSize: 18,
),
),
),
);
}

List<Widget> _governorateStatistics(
List<Station> stations,
) {

final Map<String, int> governorates = {};

for (final station in stations) {

governorates.update(

station.governorate,

(value) => value + 1,

ifAbsent: () => 1,

);

}

return governorates.entries.map((e) {

return Card(

child: ListTile(

leading: const Icon(
Icons.location_city,
color: Colors.indigo,
),

title: Text(e.key),

trailing: Container(
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 8,
),
decoration: BoxDecoration(
color: Colors.indigo.shade100,
borderRadius: BorderRadius.circular(20),
),
child: Text(
"${e.value} محطة",
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
),
),
);

}).toList();
}
}