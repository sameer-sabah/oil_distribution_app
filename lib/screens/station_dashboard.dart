
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/station_service.dart';
import '../models/station.dart';
import 'notifications_screen.dart';


class StationDashboard extends StatefulWidget {


  const StationDashboard({
    super.key,
  });



  @override
  State<StationDashboard> createState() =>
      _StationDashboardState();


}







class _StationDashboardState
    extends State<StationDashboard>
    with SingleTickerProviderStateMixin {



  final AuthService auth =
      AuthService.instance;



  final StationService service =
      StationService.instance;



  Station? station;

  bool loading = true;

  bool stationOpen = true;

  Map<String, bool> supportedProducts = {
    "regular95": true,
    "improved95": true,
    "super95": true,
    "diesel": true,
    "whiteOil": true,
    "lpg": true,
  };

  late AnimationController _productAnimationController;
  late Animation<double> _productScaleAnimation;
  late Animation<double> _productFadeAnimation;

  void _openLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      "/login",
          (route) => false,
    );
  }

  void _handleBack() {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    _openLogin();
  }


  @override
  void initState() {
    super.initState();

    _productAnimationController =
        AnimationController(
          vsync: this,
          duration:
          const Duration(milliseconds: 1100),
        );

    _productScaleAnimation =
        CurvedAnimation(
          parent:
          _productAnimationController,
          curve: Curves.easeOutBack,
        );

    _productFadeAnimation =
        CurvedAnimation(
          parent:
          _productAnimationController,
          curve: Curves.easeOut,
        );

    loadStation();

    Future.delayed(
      const Duration(milliseconds: 250),
          () {
        if (mounted) {
          _productAnimationController
              .forward(from: 0);
        }
      },
    );
  }







  Future<void> loadStation() async {



    final user =
        auth.currentUser;



    if(user == null){

      return;

    }






    final data =
    await service.getStation(

      user.stationId,

    );







    if(!mounted) {
      return;
    }





    if (data == null) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      return;
    }

    setState((){

      station = data;

      supportedProducts =
      Map<String, bool>.from(
        data.supportedProducts,
      );

      stationOpen =
          data.workingStatus == "مفتوحة";

      loading = false;

    });



  }









  Future<void> updateFuel() async {



    if(station == null) {
      return;
    }






    final regular =
    TextEditingController(

      text:
      station!.regular95.toString(),

    );



    final improved =
    TextEditingController(

      text:
      station!.improved95.toString(),

    );

    final super95 =
    TextEditingController(

      text:
      station!.super95.toString(),

    );


    final whiteOil =
    TextEditingController(

      text:
      station!.whiteOil.toString(),

    );


    final lpg =
    TextEditingController(

      text:
      station!.lpg.toString(),

    );

    final diesel =
    TextEditingController(

      text:
      station!.diesel.toString(),

    );





    await showDialog(


      context: context,


      builder:(context){


        return AlertDialog(



          title:

          const Text(
              "تحديث الوقود"
          ),




          content:

          Column(


            mainAxisSize:
            MainAxisSize.min,



            children:[



              field(

                "بنزين عادي",

                regular,

              ),



              field(

                "بنزين محسن",

                improved,

              ),



              field(

                "ديزل",

                diesel,

              ),

              field(
                "بنزين سوبر",
                super95,
              ),

              field(
                "نفط أبيض",
                whiteOil,
              ),

              field(
                "غاز",
                lpg,
              ),

            ],


          ),


          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            0,
          ),






        );


      },


    );



  }









  Widget field(

      String title,

      TextEditingController controller,

      ){


    return Padding(


      padding:

      const EdgeInsets.only(

        bottom:10,

      ),



      child:


      TextField(


        controller:
        controller,



        keyboardType:
        TextInputType.number,



        decoration:

        InputDecoration(



          labelText:
          title,



          border:
          const OutlineInputBorder(),



        ),



      ),


    );


  }










  Future<void> saveSupportedProducts() async {
    if (station == null) return;

    try {
      await service.updateSupportedProducts(
        stationId: station!.id,
        supportedProducts: supportedProducts,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم حفظ المنتجات المعتمدة بنجاح"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("فشل حفظ المنتجات: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    final canPop = Navigator.of(context).canPop();

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _openLogin();
        }
      },
      child: Scaffold(




        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: "رجوع",
            onPressed: _handleBack,
          ),

          title: const Text(
            "لوحة مدير المحطة",
          ),

          centerTitle: true,

          actions: [
// 🔔 الإشعارات
            IconButton(
              icon: const Icon(Icons.notifications),
              tooltip: "الإشعارات",
              onPressed: () {
                final user = auth.currentUser;

                if (user == null) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(
                      userId: user.id,
                    ),
                  ),
                );
              },
            ),

// 🚪 تسجيل الخروج
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "تسجيل الخروج",
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("تسجيل الخروج"),
                      content: const Text(
                        "هل تريد تسجيل الخروج من الحساب؟",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text("إلغاء"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text("تسجيل الخروج"),
                        ),
                      ],
                    );
                  },
                );

                if (confirm != true) {
                  return;
                }

                await auth.logout();

                if (!context.mounted) {
                  return;
                }

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                      (route) => false,
                );
              },
            ),
          ],
        ),






        body:



        loading



            ?



        const Center(

          child:

          CircularProgressIndicator(),

        )



            :



        station == null



            ?



        const Center(

          child:

          Text(

            "لا توجد محطة مرتبطة بالحساب",

          ),


        )



            :



        RefreshIndicator(



          onRefresh:

          loadStation,



          child:

          ListView(



            padding:

            const EdgeInsets.all(16),



            children:[







              Card(


                elevation:4,


                child:

                ListTile(


                  leading:

                  const CircleAvatar(


                    child:

                    Icon(
                      Icons.local_gas_station,
                    ),


                  ),



                  title:

                  Text(

                    station!.name,

                    style:

                    const TextStyle(

                      fontWeight:
                      FontWeight.bold,

                      fontSize:18,

                    ),

                  ),




                  subtitle:

                  Text(

                    "${station!.governorate} - ${station!.district}",

                  ),



                ),



              ),

              const SizedBox(
                height: 10,
              ),

              Card(
                child: ListTile(

                  leading: const Icon(
                    Icons.update,
                    color: Colors.blue,
                  ),

                  title: const Text(
                    "آخر تحديث",
                  ),

                  subtitle: Text(
                    station!.updatedAt.isEmpty
                        ? "لا يوجد تحديث"
                        : station!.updatedAt,
                  ),

                ),
              ),





              const SizedBox(
                height:15,
              ),








              Card(



                child:

                ListTile(


                  leading:

                  Icon(

                    Icons.info,

                    color:

                    station!.workingStatus ==
                        "مفتوحة"

                        ?

                    Colors.green

                        :

                    Colors.red,

                  ),



                  title:

                  const Text(
                      "حالة المحطة"
                  ),



                  trailing:

                  Text(

                    station!.workingStatus,

                  ),



                ),



              ),







              const SizedBox(
                height:20,
              ),






// =====================================================
// اختر المنتوج
// =====================================================

              AnimatedBuilder(
                animation: _productAnimationController,
                builder: (context, child) {
                  final scale = _productScaleAnimation.value;
                  final fade = _productFadeAnimation.value;

                  return Opacity(
                    opacity: fade,
                    child: Transform.scale(
                      scale: 0.72 + (0.28 * scale),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [Colors.white, Colors.blue.shade50],
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                              color: Colors.black.withValues(alpha: 0.12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Center(
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: -0.04, end: 0.04),
                                      duration: const Duration(seconds: 3),
                                      curve: Curves.easeInOut,
                                      builder: (context, value, _) {
                                        return Transform.rotate(
                                          angle: value,
                                          child: Opacity(
                                            opacity: 0.055,
                                            child: Icon(
                                              Icons.local_gas_station,
                                              size: 190,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.local_gas_station, size: 27),
                                        SizedBox(width: 8),
                                        Text(
                                          "اختر المنتوج",
                                          style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(child: productCheck("بنزين عادي", "regular95")),
                                        const SizedBox(width: 7),
                                        Expanded(child: productCheck("بنزين محسن", "improved95")),
                                        const SizedBox(width: 7),
                                        Expanded(child: productCheck("بنزين سوبر", "super95")),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(child: productCheck("ديزل", "diesel")),
                                        const SizedBox(width: 7),
                                        Expanded(child: productCheck("نفط أبيض", "whiteOil")),
                                        const SizedBox(width: 7),
                                        Expanded(child: productCheck("غاز سائل", "lpg")),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton.icon(
                                        onPressed: saveSupportedProducts,
                                        icon: const Icon(Icons.save),
                                        label: const Text(
                                          "حفظ المنتجات",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const Text(

                "المنتجات المتوفرة",

                style:

                TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),






              fuelCard(

                "بنزين عادي",

                station!.regular95,

              ),



              fuelCard(

                "بنزين محسن",

                station!.improved95,

              ),



              fuelCard(

                "بنزين سوبر",

                station!.super95,

              ),



              fuelCard(

                "ديزل",

                station!.diesel,

              ),



              fuelCard(

                "نفط أبيض",

                station!.whiteOil,

              ),



              fuelCard(

                "غاز",

                station!.lpg,

              ),








              const SizedBox(
                height:20,
              ),




              SwitchListTile(
                title: Text(
                  stationOpen
                      ? "المحطة مفتوحة 🟢"
                      : "المحطة مغلقة 🔴",
                ),
                value: stationOpen,
                onChanged: (value){
                  setState(() {
                    stationOpen = value;
                  });
                },
              ),

              const SizedBox(
                height:20,
              ),


              ElevatedButton.icon(



                onPressed:

                updateFuel,



                icon:

                const Icon(
                  Icons.edit,
                ),



                label:

                const Text(

                  "تحديث الكميات",

                ),



                style:

                ElevatedButton.styleFrom(

                  minimumSize:

                  const Size(

                    double.infinity,

                    55,

                  ),

                ),



              )







            ],



          ),



        ),






      ),
    );



  }









  Widget productCheck(
      String title,
      String key,
      ) {
    final selected = supportedProducts[key] ?? false;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          supportedProducts[key] = !selected;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? Colors.blue.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: selected,
                onChanged: (value) {
                  setState(() {
                    supportedProducts[key] = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fuelCard(

      String name,

      int value,

      ){


    return Card(



      child:

      ListTile(



        leading:

        const Icon(

          Icons.local_gas_station,

          color:Colors.blue,

        ),




        title:

        Text(name),




        trailing:

        Text(

          value.toString(),

          style:

          const TextStyle(

            fontSize:20,

            fontWeight:
            FontWeight.bold,

          ),

        ),



      ),


    );


  }

  @override
  void dispose() {
    _productAnimationController.dispose();
    super.dispose();
  }

}
