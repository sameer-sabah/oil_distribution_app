import 'package:flutter/material.dart';
import '../../../models/station.dart';
import '../../../services/database_service.dart';
import 'station_details_screen.dart';
import 'edit_station_screen.dart';
import 'send_notification_screen.dart';

class PrivateStationsScreen extends StatefulWidget {

  final String branchId;

  const PrivateStationsScreen({

    super.key,

    required this.branchId,

  });

  @override
  State<PrivateStationsScreen> createState() =>
      _PrivateStationsScreenState();
}

class _PrivateStationsScreenState
    extends State<PrivateStationsScreen> {

  List<Station> stations = [];
  List<Station> filtered = [];

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStations();
  }

  Future<void> loadStations() async {
    final all = await DatabaseService.instance.getStations();

    stations = all
        .where((e) =>
    e.stationType.trim() == "أهلية" &&
        e.branchId == widget.branchId
    )
        .toList();

    filtered = stations;

    setState(() {});
  }

  void search(String value) {
    value = value.toLowerCase();

    filtered = stations.where((e) {
      return e.name.toLowerCase().contains(value) ||
          e.managerName.toLowerCase().contains(value) ||
          e.governorate.toLowerCase().contains(value) ||
          e.district.toLowerCase().contains(value);
    }).toList();

    setState(() {});
  }

  Color statusColor(String status) {
    switch (status) {
      case "مفتوحة":
        return Colors.green;

      case "مغلقة":
        return Colors.red;

      case "يوجد تجهيز":
        return Colors.orange;

      case "نفاد الوقود":
        return Colors.black;

      default:
        return Colors.grey;
    }
  }

  Future<void> deleteStation(Station station) async {

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("حذف المحطة"),
        content: Text("هل تريد حذف ${station.name} ؟"),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("إلغاء"),
          ),

          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("حذف"),
          ),

        ],
      ),
    );

    if (ok != true) return;

    await DatabaseService.instance.deleteStation(station.id);

    loadStations();
  }

  PopupMenuButton menu(Station station) {

    return PopupMenuButton(

      onSelected: (value) async  {

        switch (value) {

          case 1:

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    StationDetailsScreen(
                      station: station,
                    ),
              ),
            );

            break;

          case 2:
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditStationScreen(
                  station: station,
                ),
              ),
            );

            loadStations();
            break;

          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SendNotificationScreen(
                  station: station,
                ),
              ),
            );
            break;

          case 4:

            deleteStation(station);

            break;
        }
      },

      itemBuilder: (_) => const [

        PopupMenuItem(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.visibility),
            title: Text("التفاصيل"),
          ),
        ),

        PopupMenuItem(
          value: 2,
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text("تعديل"),
          ),
        ),

        PopupMenuItem(
          value: 3,
          child: ListTile(
            leading: Icon(Icons.notifications),
            title: Text("تبليغ"),
          ),
        ),

        PopupMenuItem(
          value: 4,
          child: ListTile(
            leading: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: Text("حذف"),
          ),
        ),

      ],
    );
  }

  Widget stationCard(Station station) {

    return Card(

      elevation: 4,

      margin: const EdgeInsets.only(bottom: 10),

      child: ListTile(

        onTap: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  StationDetailsScreen(
                    station: station,
                  ),

            ),

          );

        },

        leading: CircleAvatar(

          backgroundColor:
          statusColor(station.workingStatus),

          child: const Icon(
            Icons.local_gas_station,
            color: Colors.white,
          ),

        ),

        title: Text(

          station.name,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),

        ),

        subtitle: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Text(station.managerName),

            Text(
                "${station.governorate} - ${station.district}"),

            Text(station.workingStatus),

          ],

        ),

        trailing: menu(station),

      ),

    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("المحطات الأهلية"),
      ),

      body: Column(

        children: [

          Padding(

            padding: const EdgeInsets.all(10),

            child: TextField(

              controller: searchController,

              onChanged: search,

              decoration: const InputDecoration(

                prefixIcon: Icon(Icons.search),

                labelText: "بحث عن محطة",

                border: OutlineInputBorder(),

              ),

            ),

          ),

          Expanded(

            child: filtered.isEmpty

                ? const Center(
              child: Text("لا توجد محطات"),
            )

                : ListView.builder(

              itemCount: filtered.length,

              itemBuilder: (_, index) {

                return stationCard(filtered[index]);

              },

            ),

          ),

        ],

      ),

    );

  }

}