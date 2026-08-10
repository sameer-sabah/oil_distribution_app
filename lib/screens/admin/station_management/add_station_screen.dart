import 'package:flutter/material.dart';

import 'package:oil_distribution_app/models/station.dart';
import 'package:oil_distribution_app/services/station_service.dart';



class AddStationScreen extends StatefulWidget {

  final String stationType;


  const AddStationScreen({

    super.key,

    required this.stationType,

  });


  @override
  State<AddStationScreen> createState() =>
      _AddStationScreenState();

}






class _AddStationScreenState
    extends State<AddStationScreen> {



final StationService service =
StationService.instance;



final formKey =
GlobalKey<FormState>();





final name =
TextEditingController();


final stationLicense =
TextEditingController();


final governorate =
TextEditingController();


final district =
TextEditingController();


final branchName =
TextEditingController();



final phone =
TextEditingController();


final address =
TextEditingController();



final managerName =
TextEditingController();


final managerPhone =
TextEditingController();




final latitude =
TextEditingController();


final longitude =
TextEditingController();




final regular95 =
TextEditingController();


final improved95 =
TextEditingController();


final super95 =
TextEditingController();


final diesel =
TextEditingController();


final whiteOil =
TextEditingController();


final lpg =
TextEditingController();





final licenseNumber =
TextEditingController();


final licenseIssuer =
TextEditingController();


final licenseIssueDate =
TextEditingController();


final licenseExpiryDate =
TextEditingController();




final workingHours =
TextEditingController();


final notes =
TextEditingController();





bool loading=false;





Future<void> save() async {


if(!formKey.currentState!.validate()){

return;

}



final station =
Station(


id:
"",


name:
name.text.trim(),



stationLicense:
stationLicense.text.trim(),



stationType:
widget.stationType,



governorate:
governorate.text.trim(),



district:
district.text.trim(),



branchId:
"",



branchName:
branchName.text.trim(),




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
int.tryParse(
regular95.text
) ?? 0,



improved95:
int.tryParse(
improved95.text
) ?? 0,



super95:
int.tryParse(
super95.text
) ?? 0,



diesel:
int.tryParse(
diesel.text
) ?? 0,



whiteOil:
int.tryParse(
whiteOil.text
) ?? 0,



lpg:
int.tryParse(
lpg.text
) ?? 0,




workingStatus:
"مفتوحة",



status:
"active",




approved:
false,



active:
true,




workingHours:
workingHours.text.trim(),



notes:
notes.text.trim(),





licenseNumber:
licenseNumber.text.trim(),



licenseIssuer:
licenseIssuer.text.trim(),



licenseIssueDate:
licenseIssueDate.text.trim(),



licenseExpiryDate:
licenseExpiryDate.text.trim(),




createdAt:
DateTime.now().toIso8601String(),



updatedAt:
DateTime.now().toIso8601String(),


);



setState(() {

loading=true;

});



try{


  await service.addPendingStation(
    station.toMap(),
  );



if(!mounted)return;


Navigator.pop(context,true);



}



finally{


if(mounted){

setState(() {

loading=false;

});

}


}



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

      SingleChildScrollView(


        padding:
        const EdgeInsets.all(16),



        child:

        Column(


          children: [



            field(
              "اسم المحطة",
              name,
            ),



            field(
              "رقم إجازة المحطة",
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
              "الفرع",
              branchName,
            ),





            field(
              "رقم الهاتف",
              phone,
            ),




            field(
              "العنوان",
              address,
            ),





            field(
              "اسم المدير",
              managerName,
            ),





            field(
              "هاتف المدير",
              managerPhone,
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





            const Align(

              alignment:
              Alignment.centerRight,


              child:

              Text(

                "كميات المنتجات",

                style:

                TextStyle(

                  fontSize:18,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),


            ),






            field(
              "بنزين عادي",
              regular95,
              number:true,
            ),



            field(
              "بنزين محسن",
              improved95,
              number:true,
            ),



            field(
              "بنزين سوبر",
              super95,
              number:true,
            ),



            field(
              "زيت الغاز",
              diesel,
              number:true,
            ),



            field(
              "النفط الأبيض",
              whiteOil,
              number:true,
            ),



            field(
              "الغاز السائل",
              lpg,
              number:true,
            ),







            const SizedBox(
              height:15,
            ),





            field(
              "رقم الرخصة",
              licenseNumber,
            ),



            field(
              "جهة إصدار الرخصة",
              licenseIssuer,
            ),



            field(
              "تاريخ إصدار الرخصة",
              licenseIssueDate,
            ),



            field(
              "تاريخ انتهاء الرخصة",
              licenseExpiryDate,
            ),





            field(
              "ساعات العمل",
              workingHours,
            ),





            field(
              "ملاحظات",
              notes,
              maxLines:3,
            ),






            const SizedBox(
              height:25,
            ),







            SizedBox(


              width:
              double.infinity,


              height:
              55,



              child:

              ElevatedButton.icon(



                onPressed:

                loading

                    ? null

                    : save,



                icon:

                loading

                    ?

                const SizedBox(

                  width:20,

                  height:20,

                  child:

                  CircularProgressIndicator(
                    strokeWidth:2,
                  ),

                )


                    :

                const Icon(
                  Icons.save,
                ),




                label:

                Text(

                  loading

                      ?

                  "جاري الحفظ..."

                      :

                  "حفظ المحطة",

                ),



              ),



            ),




          ],


        ),


      ),


    ),


  );


}










Widget field(

    String title,

    TextEditingController controller,

    {

      bool number=false,

      int maxLines=1,

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



      keyboardType:

      number

          ?

      TextInputType.number

          :

      TextInputType.text,



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


        if(value==null ||
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



  name.dispose();

  stationLicense.dispose();

  governorate.dispose();

  district.dispose();

  branchName.dispose();

  phone.dispose();

  address.dispose();

  managerName.dispose();

  managerPhone.dispose();

  latitude.dispose();

  longitude.dispose();

  regular95.dispose();

  improved95.dispose();

  super95.dispose();

  diesel.dispose();

  whiteOil.dispose();

  lpg.dispose();

  licenseNumber.dispose();

  licenseIssuer.dispose();

  licenseIssueDate.dispose();

  licenseExpiryDate.dispose();

  workingHours.dispose();

  notes.dispose();



  super.dispose();


}



}