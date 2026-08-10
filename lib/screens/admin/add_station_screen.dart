import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:oil_distribution_app/models/station.dart';
import 'package:oil_distribution_app/services/station_service.dart';
import '../map_picker_screen.dart';



class AddStationScreen extends StatefulWidget {


  const AddStationScreen({

    super.key,

  });



  @override
  State<AddStationScreen> createState() =>
      _AddStationScreenState();


}






class _AddStationScreenState
    extends State<AddStationScreen> {



final formKey =
GlobalKey<FormState>();



final StationService stationService =
StationService.instance;





final stationName =
TextEditingController();



final stationLicense =
TextEditingController();



final governorate =
TextEditingController();



final district =
TextEditingController();



final address =
TextEditingController();



final phone =
TextEditingController();



final managerName =
TextEditingController();



final managerPhone =
TextEditingController();



final latitude =
TextEditingController();



final longitude =
TextEditingController();





String stationType =
"حكومية";



String workingStatus =
"مفتوحة";






Future<void> pickLocation() async {



final LatLng? result =
await Navigator.push(


context,


MaterialPageRoute(


builder:(_)=>

const MapPickerScreen(),


),


);





if(result != null){


setState((){


latitude.text =
result.latitude.toString();



longitude.text =
result.longitude.toString();



});


}



}









Future<void> saveStation() async {



if(!formKey.currentState!.validate()){

return;

}






final id =

DateTime.now()
.millisecondsSinceEpoch
.toString();







final station = Station(



id:id,



name:
stationName.text.trim(),




stationLicense:
stationLicense.text.trim(),




stationType:
stationType,




governorate:
governorate.text.trim(),




district:
district.text.trim(),




branchId:
"",




branchName:
"",





latitude:

double.tryParse(
latitude.text
) ?? 0,




longitude:

double.tryParse(
longitude.text
) ?? 0,






phone:
phone.text.trim(),




address:
address.text.trim(),






managerUid:
"",




managerName:
managerName.text.trim(),




managerPhone:
managerPhone.text.trim(),






regular95:
0,



improved95:
0,



super95:
0,



diesel:
0,



whiteOil:
0,



lpg:
0,




workingStatus:
workingStatus,




status:
"active",





approved:
false,



active:
true,





workingHours:
"",




notes:
"",





licenseNumber:
"",




licenseIssuer:
"",




licenseIssueDate:
"",




licenseExpiryDate:
"",





createdAt:
DateTime.now()
.toIso8601String(),





updatedAt:
DateTime.now()
.toIso8601String(),



);





await stationService.addPendingStation(
  station.toMap(),
);




if(!mounted)
return;




ScaffoldMessenger.of(context)
.showSnackBar(


const SnackBar(

content:

Text(
"تم إرسال طلب إضافة المحطة",
),


backgroundColor:
Colors.green,

),


);



Navigator.pop(context);



}
@override
Widget build(BuildContext context) {


  return Scaffold(


    appBar:

    AppBar(

      title:

      const Text(
        "إضافة محطة جديدة",
      ),

      centerTitle:true,

    ),





    body:

    Form(


      key:
      formKey,



      child:

      ListView(


        padding:

        const EdgeInsets.all(16),



        children: [





          field(

            "اسم المحطة",

            stationName,

          ),






          field(

            "إجازة المحطة",

            stationLicense,

          ),






          field(

            "المحافظة",

            governorate,

          ),






          field(

            "القضاء",

            district,

          ),






          field(

            "العنوان",

            address,

            maxLines:2,

          ),





          field(

            "رقم الهاتف",

            phone,

          ),






          field(

            "اسم المدير",

            managerName,

          ),






          field(

            "هاتف المدير",

            managerPhone,

          ),





          const SizedBox(
            height:15,
          ),





          Row(

            children: [



              Expanded(

                child:

                field(

                  "Latitude",

                  latitude,

                ),

              ),




              const SizedBox(
                width:10,
              ),





              Expanded(

                child:

                field(

                  "Longitude",

                  longitude,

                ),

              ),



            ],


          ),






          const SizedBox(
            height:15,
          ),






          ElevatedButton.icon(



            onPressed:

            pickLocation,



            icon:

            const Icon(
              Icons.map,
            ),




            label:

            const Text(
              "اختيار الموقع من الخريطة",
            ),



          ),





          const SizedBox(
            height:25,
          ),





          DropdownButtonFormField<String>(



            value:

            stationType,



            decoration:

            const InputDecoration(

              labelText:

              "نوع المحطة",

              border:

              OutlineInputBorder(),

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




            onChanged:(value){



              if(value != null){


                setState((){


                  stationType =
                      value;



                });


              }



            },



          ),






          const SizedBox(
            height:15,
          ),






          DropdownButtonFormField<String>(



            value:

            workingStatus,



            decoration:

            const InputDecoration(

              labelText:

              "حالة المحطة",

              border:

              OutlineInputBorder(),

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

                "نفاد الوقود",

                child:

                Text(
                  "⛔ نفاد الوقود",
                ),

              ),




              DropdownMenuItem(

                value:

                "قيد التجهيز",

                child:

                Text(
                  "🚚 قيد التجهيز",
                ),

              ),



            ],





            onChanged:(value){



              if(value != null){


                setState((){


                  workingStatus =
                      value;



                });


              }



            },



          ),






          const SizedBox(
            height:30,
          ),





          SizedBox(


            width:

            double.infinity,



            height:

            55,



            child:

            ElevatedButton.icon(



              onPressed:

              saveStation,



              icon:

              const Icon(
                Icons.save,
              ),



              label:

              const Text(
                "حفظ المحطة",
              ),



            ),



          ),





        ],



      ),



    ),



  );


}








Widget field(

    String title,

    TextEditingController controller,

    {

      int maxLines = 1,

    }

    ){



  return Padding(



    padding:

    const EdgeInsets.only(

      bottom:15,

    ),




    child:

    TextFormField(



      controller:

      controller,



      maxLines:

      maxLines,



      decoration:

      InputDecoration(


        labelText:

        title,



        border:

        const OutlineInputBorder(),


      ),




      validator:(value){



        if(value == null ||

            value.trim().isEmpty){


          return "الحقل مطلوب";


        }



        return null;



      },



    ),



  );


}









@override
void dispose(){



  stationName.dispose();


  stationLicense.dispose();


  governorate.dispose();


  district.dispose();


  address.dispose();


  phone.dispose();


  managerName.dispose();


  managerPhone.dispose();


  latitude.dispose();


  longitude.dispose();



  super.dispose();


}



}