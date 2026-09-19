import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/governorate_model.dart';
import '../models/branch_model.dart';

import '../services/governorate_service.dart';
import '../services/branch_service.dart';
import '../services/storage_service.dart';
import '../services/station_service.dart';

import 'map_picker_screen.dart';



class RegisterStationScreen extends StatefulWidget {

  const RegisterStationScreen({
    super.key,
  });


  @override
  State<RegisterStationScreen> createState() =>
      _RegisterStationScreenState();

}





class _RegisterStationScreenState
    extends State<RegisterStationScreen> {


  bool loading = false;


  String stationType = "حكومية";



  final formKey =
  GlobalKey<FormState>();



  final name =
  TextEditingController();


  final managerName =
  TextEditingController();


  final phone =
  TextEditingController();


  final address =
  TextEditingController();





  final GovernorateService governorateService =
      GovernorateService.instance;


  final branchService =
      BranchService.instance;


  final stationService =
      StationService.instance;


  final storage =
      StorageService.instance;





  List<GovernorateModel> governorates=[];

  List<BranchModel> branches=[];



  GovernorateModel? selectedGovernorate;

  BranchModel? selectedBranch;



  LatLng? location;



  File? managerImage;

  File? stationImage;
  String workSystem = "24 ساعة";

  TimeOfDay openTime = const TimeOfDay(
    hour: 6,
    minute: 0,
  );

  TimeOfDay closeTime = const TimeOfDay(
    hour: 18,
    minute: 0,
  );
  String formatTime12(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod;

    final minute =
    time.minute.toString().padLeft(2, '0');

    final period =
    time.period == DayPeriod.am
        ? "صباحاً"
        : "مساءً";

    return "$hour:$minute $period";
  }
  Future<void> selectOpenTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: openTime,
    );

    if (selected != null) {
      setState(() {
        openTime = selected;
        // حساب وقت الإغلاق تلقائياً بعد 12 ساعة مباشر بدون الحاجة لاختياره يدوياً
        closeTime = TimeOfDay(
          hour: (selected.hour + 12) % 24,
          minute: selected.minute,
        );
      });
    }
  }

  Future<void> selectCloseTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: closeTime,
    );

    if (selected != null) {
      setState(() {
        closeTime = selected;
      });
    }
  }

  @override
  void initState(){

    super.initState();

    loadGovernorates();

  }






  Future<void> loadGovernorates() async{


    governorates =
    await governorateService
        .getForRegister();



    setState((){});


  }







  Future<void> loadBranches(String governorateId) async {

    final result =
    await branchService.getGovernorateBranches(
      governorateId,
    );


    debugPrint(
      "المحافظة المختارة: $governorateId",
    );


    debugPrint(
      "عدد الفروع الموجودة: ${result.length}",
    );


    setState(() {

      branches = result;

      selectedBranch = null;

    });

  }







  Future<void> pickLocation() async{


    final result =
    await Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=>
        const MapPickerScreen(),

      ),

    );



    if(result!=null){

      setState((){

        location=result;

      });

    }


  }








  Future<void> pickImage(
      bool manager
      ) async{


    final picker =
    ImagePicker();


    final image =
    await picker.pickImage(

      source:
      ImageSource.gallery,

    );



    if(image==null) {
      return;
    }



    setState((){


      if(manager){

        managerImage =
            File(image.path);


      }else{


        stationImage =
            File(image.path);


      }


    });



  }









  Future<void> save() async{


    if(!formKey.currentState!.validate()) {
      return;
    }



    if(selectedBranch==null){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
          Text("اختر الفرع"),
        ),

      );

      return;

    }



    if(location==null){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
          Text("حدد موقع المحطة من الخريطة"),
        ),

      );

      return;

    }




    setState((){

      loading=true;

    });



    try{


      String managerPhoto="";

      String stationPhoto="";



      // رفع الصورتين بالتوازي بدلاً من انتظار الأولى ثم الثانية.
      final uploadResults =
      await Future.wait<String>([
        if (managerImage != null)
          storage.uploadManagerPhoto(
            managerImage!,
          )
        else
          Future.value(""),

        if (stationImage != null)
          storage.uploadStationPhoto(
            stationImage!,
          )
        else
          Future.value(""),
      ]);

      managerPhoto =
      uploadResults[0];

      stationPhoto =
      uploadResults[1];






      final request = {
        "name": name.text.trim(),

        "stationType": stationType,

        "managerName":
        managerName.text.trim(),



        "phone":
        phone.text.trim(),



        "address":
        address.text.trim(),



        "governorateId":
        selectedGovernorate!.id,



        "governorateName":
        selectedGovernorate!.name,



        "branchId":
        selectedBranch!.id,



        "branchName":
        selectedBranch!.name,



        "latitude":
        location!.latitude,



        "longitude":
        location!.longitude,



        "managerPhoto":
        managerPhoto,



        "stationPhoto":
        stationPhoto,

        "workingHours": workSystem == "24 ساعة"
            ? "24 ساعة"
            : "12 ساعة | ${formatTime12(openTime)} - ${formatTime12(closeTime)}",

        "approved":
        false,



        "active":
        false,



        "status":
        "pending",



        "createdAt":
        DateTime.now()
            .toIso8601String(),



      };



      // ============================================================
// فحص التكرار قبل إرسال طلب تسجيل المحطة
// ============================================================

      final duplicates =
      await stationService.checkRegistrationDuplicates(
        stationName: name.text.trim(),
        managerName: managerName.text.trim(),
        phone: phone.text.trim(),
      );

// ============================================================
// إذا توجد بيانات مكررة
// ============================================================

      if (duplicates.isNotEmpty) {
        if (!mounted) {
          return;
        }

        final duplicateText =
        duplicates.map((item) => "• $item").join("\n");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 6),
            content: Text(
              "⚠️ لا يمكن إرسال الطلب\n\n"
                  "تم العثور على بيانات مكررة:\n"
                  "$duplicateText\n\n"
                  "يرجى تعديل البيانات ثم المحاولة مرة أخرى.",
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

        return;
      }

      await stationService.addPendingStation(request);






      if(!mounted) {
        return;
      }



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
              "تم إرسال طلب تسجيل المحطة بانتظار موافقة مدير الفرع"
          ),

          backgroundColor:
          Colors.green,

        ),

      );




      Navigator.pop(context);



    }

    catch(e){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
          Text(e.toString()),
        ),

      );


    }


    finally{


      if(mounted){

        setState((){

          loading=false;

        });


      }


    }


  }









  Widget field(
      String title,
      TextEditingController controller,
      ){

    return Padding(

      padding:
      const EdgeInsets.only(bottom:15),


      child:
      TextFormField(

        controller:controller,


        validator:(v){

          if(v==null || v.isEmpty){

            return "الحقل مطلوب";

          }

          return null;

        },


        decoration:

        InputDecoration(

          labelText:title,

          border:
          const OutlineInputBorder(),

        ),


      ),


    );

  }









  @override
  Widget build(BuildContext context){


    return Scaffold(


      appBar:

      AppBar(

        title:
        const Text(
            "تسجيل محطة جديدة"
        ),

        centerTitle:true,

      ),




      body:


      Form(

        key:formKey,


        child:

        ListView(

          padding:
          const EdgeInsets.all(16),


          children:[




            DropdownButtonFormField<GovernorateModel>(

              initialValue: selectedGovernorate,

              decoration:
              const InputDecoration(

                labelText: "المحافظة",

                border:
                OutlineInputBorder(),

              ),


              items:

              governorates.map((g){

                return DropdownMenuItem(

                  value: g,

                  child:
                  Text(g.name),

                );

              }).toList(),


              onChanged:(v){

                if(v == null) return;


                setState((){

                  selectedGovernorate = v;

                  branches = [];

                  selectedBranch = null;

                });


                loadBranches(
                  v.id,
                );

              },
            ),


            const SizedBox(height:15),
            DropdownButtonFormField<BranchModel>(

              initialValue:selectedBranch,


              decoration:
              const InputDecoration(

                labelText:
                "الفرع",

                border:
                OutlineInputBorder(),

              ),


              items:

              branches.map((b){

                return DropdownMenuItem(

                  value:b,

                  child:
                  Text(b.name),

                );

              }).toList(),



              onChanged:(v){

                setState((){

                  selectedBranch=v;

                });

              },


            ),



            field(
              "اسم المحطة",
              name,
            ),

            const SizedBox(
              height:15,
            ),




            DropdownButtonFormField<String>(

              initialValue: stationType,


              decoration: const InputDecoration(

                labelText: "نوع المحطة",

                prefixIcon:
                Icon(Icons.local_gas_station),

                border:
                OutlineInputBorder(),

              ),


              items: const [

                DropdownMenuItem(

                  value: "حكومية",

                  child:
                  Text("حكومية"),

                ),


                DropdownMenuItem(

                  value: "أهلية",

                  child:
                  Text("أهلية"),

                ),

              ],


              onChanged:(value){

                setState((){

                  stationType = value!;

                });

              },


            ),

            field(
              "اسم مدير المحطة",
              managerName,
            ),



            field(
              "رقم الهاتف",
              phone,
            ),



            const SizedBox(height:20),

            ElevatedButton.icon(

              onPressed:
              pickLocation,

              icon:
              const Icon(Icons.map),

              label:
              Text(

                location==null

                    ?

                "تحديد موقع المحطة"

                    :

                "تم تحديد الموقع",

              ),

            ),




            const SizedBox(height:15),




            ElevatedButton.icon(

              onPressed:(){

                pickImage(true);

              },

              icon:
              const Icon(Icons.person),

              label:
              Text(

                  managerImage==null

                      ?

                  "صورة مدير المحطة"

                      :

                  "تم اختيار صورة المدير"

              ),

            ),





            ElevatedButton.icon(

              onPressed:(){

                pickImage(false);

              },

              icon:
              const Icon(Icons.local_gas_station),

              label:
              Text(

                  stationImage==null

                      ?

                  "صورة المحطة"

                      :

                  "تم اختيار صورة المحطة"

              ),

            ),


            const SizedBox(height: 15),

            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "مدة عمل المحطة",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: workSystem,
              decoration: const InputDecoration(
                labelText: "نظام ساعات العمل",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
              items: const [
                DropdownMenuItem(
                  value: "12 ساعة",
                  child: Text("12 ساعة"),
                ),
                DropdownMenuItem(
                  value: "24 ساعة",
                  child: Text("24 ساعة"),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  workSystem = value;
                });
              },
            ),

            if (workSystem == "12 ساعة") ...[
              const SizedBox(height: 15),

              Row(
                children: [

                  Expanded(
                    child: InkWell(
                      onTap: selectOpenTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "وقت الفتح",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.login),
                        ),
                        child: Text(
                          formatTime12(openTime),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: InkWell(
                      onTap: selectCloseTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "وقت الإغلاق",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.logout),
                        ),
                        child: Text(
                          formatTime12(closeTime),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (workSystem == "24 ساعة") ...[
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "المحطة تعمل 24 ساعة",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],


            const SizedBox(height:30),




            SizedBox(

              height:55,

              width:
              double.infinity,


              child:

              ElevatedButton(

                onPressed:

                loading
                    ?
                null
                    :
                save,


                child:

                Text(

                  loading
                      ?
                  "جاري الإرسال..."
                      :
                  "إرسال الطلب",

                ),


              ),

            ),





          ],


        ),


      ),


    );


  }




  @override
  void dispose(){


    name.dispose();

    managerName.dispose();

    phone.dispose();

    address.dispose();


    super.dispose();


  }


}