import 'package:flutter/material.dart';

import '../../../models/station.dart';
import '../../../services/database_service.dart';



class EditStationScreen extends StatefulWidget {


  final Station station;



  const EditStationScreen({

    super.key,

    required this.station,

  });



  @override
  State<EditStationScreen> createState() =>
      _EditStationScreenState();

}






class _EditStationScreenState
    extends State<EditStationScreen> {


  final formKey =
  GlobalKey<FormState>();


  late TextEditingController nameController;

  late TextEditingController stationLicenseController;

  late TextEditingController managerController;

  late TextEditingController phoneController;

  late TextEditingController governorateController;

  late TextEditingController districtController;

  late TextEditingController addressController;

  late TextEditingController workingHoursController;


  late TextEditingController regularController;

  late TextEditingController improvedController;

  late TextEditingController dieselController;

  late TextEditingController whiteOilController;

  late TextEditingController superController;

  late TextEditingController lpgController;


  late TextEditingController licenseNumberController;

  late TextEditingController licenseIssuerController;

  late TextEditingController licenseIssueDateController;

  late TextEditingController licenseExpiryDateController;


  late String stationType;

  late String workingStatus;


  bool saving = false;


  @override
  void initState() {
    super.initState();


    final station =
        widget.station;


    nameController =
        TextEditingController(
          text: station.name,
        );


    stationLicenseController =
        TextEditingController(
          text: station.stationLicense,
        );


    managerController =
        TextEditingController(
          text: station.managerName,
        );


    phoneController =
        TextEditingController(
          text: station.phone,
        );


    governorateController =
        TextEditingController(
          text: station.governorate,
        );


    districtController =
        TextEditingController(
          text: station.district,
        );


    addressController =
        TextEditingController(
          text: station.address,
        );


    workingHoursController =
        TextEditingController(
          text: station.workingHours,
        );


    regularController =
        TextEditingController(
          text: station.regular95.toString(),
        );


    improvedController =
        TextEditingController(
          text: station.improved95.toString(),
        );


    superController =
        TextEditingController(
          text: station.super95.toString(),
        );


    dieselController =
        TextEditingController(
          text: station.diesel.toString(),
        );


    whiteOilController =
        TextEditingController(
          text: station.whiteOil.toString(),
        );


    lpgController =
        TextEditingController(
          text: station.lpg.toString(),
        );


    licenseNumberController =
        TextEditingController(
          text: station.licenseNumber,
        );


    licenseIssuerController =
        TextEditingController(
          text: station.licenseIssuer,
        );


    licenseIssueDateController =
        TextEditingController(
          text: station.licenseIssueDate,
        );


    licenseExpiryDateController =
        TextEditingController(
          text: station.licenseExpiryDate,
        );


    stationType =
        station.stationType;


    workingStatus =
        station.workingStatus;
  }


  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }


    setState(() {
      saving = true;
    });


    final updatedStation = Station(


      id:
      widget.station.id,


      name:
      nameController.text.trim(),


      stationLicense:
      stationLicenseController.text.trim(),


      stationType:
      stationType,


      governorate:
      governorateController.text.trim(),


      district:
      districtController.text.trim(),


      branchId:
      widget.station.branchId,


      branchName:
      widget.station.branchName,


      latitude:
      widget.station.latitude,


      longitude:
      widget.station.longitude,


      phone:
      phoneController.text.trim(),


      address:
      addressController.text.trim(),


      managerUid:
      widget.station.managerUid,


      managerName:
      managerController.text.trim(),


      managerPhone:
      phoneController.text.trim(),


      regular95:
      int.tryParse(
          regularController.text
      ) ?? 0,


      improved95:
      int.tryParse(
          improvedController.text
      ) ?? 0,


      super95:
      int.tryParse(
          superController.text
      ) ?? 0,


      diesel:
      int.tryParse(
          dieselController.text
      ) ?? 0,


      whiteOil:
      int.tryParse(
          whiteOilController.text
      ) ?? 0,


      lpg:
      int.tryParse(
          lpgController.text
      ) ?? 0,


      workingStatus:
      workingStatus,


      status:
      widget.station.status,


      approved:
      widget.station.approved,


      active:
      widget.station.active,


      workingHours:
      workingHoursController.text.trim(),


      notes:
      widget.station.notes,


      licenseNumber:
      licenseNumberController.text.trim(),


      licenseIssuer:
      licenseIssuerController.text.trim(),


      licenseIssueDate:
      licenseIssueDateController.text.trim(),


      licenseExpiryDate:
      licenseExpiryDateController.text.trim(),


      createdAt:
      widget.station.createdAt,


      updatedAt:
      DateTime.now().toIso8601String(),


    );


    await DatabaseService.instance.updateStation(
      updatedStation,
    );


    if (!mounted) return;


    setState(() {
      saving = false;
    });


    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        content:

        Text(
          "تم تحديث بيانات المحطة بنجاح",
        ),

        backgroundColor:
        Colors.green,

      ),

    );


    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      appBar:

      AppBar(

        title:

        const Text(
          "تعديل المحطة",
        ),

        centerTitle: true,

      ),


      body:

      Form(


        key: formKey,


        child:

        ListView(


          padding:

          const EdgeInsets.all(16),


          children: [


            TextFormField(

              controller:
              nameController,

              decoration:
              input(

                "اسم المحطة",

                Icons.local_gas_station,

              ),


              validator: (v) {
                if (v == null ||
                    v
                        .trim()
                        .isEmpty) {
                  return "أدخل اسم المحطة";
                }

                return null;
              },

            ),


            const SizedBox(
              height: 15,
            ),


            TextFormField(

              controller:
              stationLicenseController,

              decoration:
              input(

                "إجازة المحطة",

                Icons.card_membership,

              ),

            ),


            const SizedBox(
              height: 15,
            ),


            TextFormField(

              controller:
              managerController,

              decoration:
              input(

                "مدير المحطة",

                Icons.person,

              ),

            ),


            const SizedBox(
              height: 15,
            ),


            TextFormField(

              controller:
              phoneController,

              keyboardType:
              TextInputType.phone,


              decoration:
              input(

                "هاتف المحطة",

                Icons.phone,

              ),

            ),


            const SizedBox(
              height: 15,
            ),


            TextFormField(

              controller:
              governorateController,

              decoration:
              input(

                "المحافظة",

                Icons.location_city,

              ),

            ),


            const SizedBox(
              height: 15,
            ),


            TextFormField(

              controller:
              districtController,

              decoration:
              input(

                "القضاء",

                Icons.map,

              ),

            ),


            const SizedBox(
              height: 15,
            ),


            TextFormField(

              controller:
              addressController,

              maxLines:
              2,


              decoration:
              input(

                "العنوان",

                Icons.home,

              ),

            ),


            const SizedBox(
              height: 15,
            ),


            TextFormField(

              controller:
              workingHoursController,

              decoration:
              input(

                "ساعات العمل",

                Icons.access_time,

              ),

            ),


            const SizedBox(
              height: 25,
            ),


            const Text(

              "كميات المنتجات",

              style:

              TextStyle(

                fontSize: 20,

                fontWeight:
                FontWeight.bold,

              ),

            ),


            const SizedBox(
              height: 15,
            ),


            fuelField(

              "بنزين عادي",

              regularController,

            ),


            fuelField(

              "بنزين محسن",

              improvedController,

            ),


            fuelField(

              "بنزين سوبر",

              superController,

            ),


            fuelField(

              "زيت الغاز",

              dieselController,

            ),


            fuelField(

              "النفط الأبيض",

              whiteOilController,

            ),


            fuelField(

              "الغاز السائل",

              lpgController,

            ),


            const SizedBox(
              height: 25,
            ),


            const Text(

              "بيانات الرخصة",

              style:

              TextStyle(

                fontSize: 20,

                fontWeight:
                FontWeight.bold,

              ),

            ),


            const SizedBox(
              height: 15,
            ),


            TextFormField(

              controller:
              licenseNumberController,

              decoration:
              input(

                "رقم الرخصة",

                Icons.numbers,

              ),

            ),


            const SizedBox(
              height: 15,
            ),


            TextFormField(

              controller:
              licenseIssuerController,

              decoration:
              input(

                "جهة إصدار الرخصة",

                Icons.business,

              ),

            ),


            const SizedBox(
              height: 15,
            ),


            TextFormField(

              controller:
              licenseIssueDateController,

              decoration:
              input(

                "تاريخ إصدار الرخصة",

                Icons.date_range,

              ),

            ),


            const SizedBox(
              height: 15,
            ),


            TextFormField(

              controller:
              licenseExpiryDateController,

              decoration:
              input(

                "تاريخ انتهاء الرخصة",

                Icons.event_busy,

              ),

            ),


            const SizedBox(
              height: 25,
            ),


            DropdownButtonFormField<String>(


              value:
              stationType,


              decoration:
              input(

                "نوع المحطة",

                Icons.business,

              ),


              items:

              const [


                DropdownMenuItem(

                  value:
                  "حكومية",

                  child:
                  Text(
                    "🏛 حكومية",
                  ),

                ),


                DropdownMenuItem(

                  value:
                  "أهلية",

                  child:
                  Text(
                    "🏢 أهلية",
                  ),

                ),


              ],


              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    stationType = v;
                  });
                }
              },


            ),


            const SizedBox(
              height: 15,
            ),


            DropdownButtonFormField<String>(


              value:
              workingStatus,


              decoration:
              input(

                "حالة المحطة",

                Icons.circle,

              ),


              items:

              const [


                DropdownMenuItem(

                  value:
                  "مفتوحة",

                  child:
                  Text(
                    "🟢 مفتوحة",
                  ),

                ),


                DropdownMenuItem(

                  value:
                  "مغلقة",

                  child:
                  Text(
                    "🔴 مغلقة",
                  ),

                ),


                DropdownMenuItem(

                  value:
                  "يوجد تجهيز",

                  child:
                  Text(
                    "🟠 يوجد تجهيز",
                  ),

                ),


                DropdownMenuItem(

                  value:
                  "نفاد الوقود",

                  child:
                  Text(
                    "⛔ نفاد الوقود",
                  ),

                ),


              ],


              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    workingStatus = v;
                  });
                }
              },


            ),


            const SizedBox(
              height: 30,
            ),


            ElevatedButton.icon(


              onPressed:

              saving
                  ?
              null
                  :
              save,


              icon:

              saving

                  ?

              const SizedBox(

                width: 20,

                height: 20,

                child:

                CircularProgressIndicator(

                  strokeWidth: 2,

                  color: Colors.white,

                ),

              )


                  :

              const Icon(
                Icons.save,
              ),


              label:

              Text(

                saving

                    ?

                "جاري الحفظ..."

                    :

                "حفظ التعديلات",

              ),


              style:

              ElevatedButton.styleFrom(

                minimumSize:

                const Size(

                  double.infinity,

                  55,

                ),

              ),


            ),


          ],


        ),


      ),


    );
  }


  InputDecoration input(String title,

      IconData icon,) {
    return InputDecoration(

      labelText: title,


      border:

      const OutlineInputBorder(),


      prefixIcon:

      Icon(icon),


    );
  }


  Widget fuelField(String title,

      TextEditingController controller,) {
    return Padding(


      padding:

      const EdgeInsets.only(
        bottom: 15,
      ),


      child:

      TextFormField(


        controller:
        controller,


        keyboardType:
        TextInputType.number,


        decoration:
        input(

          title,

          Icons.local_gas_station,

        ),


      ),


    );
  }
  @override
  void dispose() {


    nameController.dispose();


    stationLicenseController.dispose();


    managerController.dispose();


    phoneController.dispose();


    governorateController.dispose();


    districtController.dispose();


    addressController.dispose();


    workingHoursController.dispose();




    regularController.dispose();


    improvedController.dispose();


    superController.dispose();


    dieselController.dispose();


    whiteOilController.dispose();


    lpgController.dispose();




    licenseNumberController.dispose();


    licenseIssuerController.dispose();


    licenseIssueDateController.dispose();


    licenseExpiryDateController.dispose();




    super.dispose();

  }



}