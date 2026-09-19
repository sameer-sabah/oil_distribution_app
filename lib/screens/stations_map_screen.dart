import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../models/station.dart';
import '../services/navigation_service.dart';



class StationsMapScreen extends StatefulWidget {


  final List<Station> stations;

  final Position? currentPosition;



  const StationsMapScreen({

    super.key,

    required this.stations,

    required this.currentPosition,

  });



  @override
  State<StationsMapScreen> createState() =>
      _StationsMapScreenState();

}






class _StationsMapScreenState
    extends State<StationsMapScreen> {



  final NavigationService navigationService =
  NavigationService();



  GoogleMapController? controller;

  bool mapReady = false;

  Position? currentPosition;



  Set<Marker> markers = {};




  @override
  void initState(){

    super.initState();

    initialize();

  }






  Future<void> initialize() async {


    await getCurrentLocation();


    loadStations();


  }








  Future<void> getCurrentLocation() async {



    if(widget.currentPosition != null){


      currentPosition =
          widget.currentPosition;


      return;

    }




    bool enabled =
    await Geolocator.isLocationServiceEnabled();



    if(!enabled) return;




    LocationPermission permission =
    await Geolocator.checkPermission();




    if(permission == LocationPermission.denied){


      permission =
      await Geolocator.requestPermission();


    }




    if(permission ==
        LocationPermission.deniedForever){


      return;

    }





    currentPosition =
    await Geolocator.getCurrentPosition(

      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),

    );



    if(mounted){

      setState(() {});

    }

    if(controller != null && currentPosition != null){

      controller!.animateCamera(

        CameraUpdate.newLatLngZoom(

          LatLng(
            currentPosition!.latitude,
            currentPosition!.longitude,
          ),

          16,

        ),

      );

    }
  }









  void loadStations(){



    final Set<Marker> newMarkers = {};




    for(final station in widget.stations){



      BitmapDescriptor icon =
          BitmapDescriptor.defaultMarker;





      if(!station.active){


        icon =
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            );


      }


      else if(station.workingStatus.contains("خاف") || station.workingStatus.contains("خفار") || station.workingStatus == "duty"){


        icon =
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            );


      }


      else if(station.workingStatus == "مفتوحة"){


        icon =
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            );


      }


      else{


        icon =
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            );


      }








      newMarkers.add(


        Marker(


          markerId:

          MarkerId(
            station.id,
          ),




          position:

          LatLng(

            station.latitude,

            station.longitude,

          ),





          icon:
          icon,




          infoWindow:


          InfoWindow(


            title:

            station.name,



            snippet:

            "${station.governorate} - ${station.district}",



            onTap: (){


              showStationDialog(
                  station
              );


            },


          ),



        ),


      );



    }






    if(mounted){


      setState((){


        markers =
            newMarkers;


      });


    }



  }












  void showStationDialog(
      Station station
      ){





    showDialog(


      context: context,


      builder:(context){



        return AlertDialog(



          title:

          Text(

            station.name,

            style:

            const TextStyle(

              fontWeight:
              FontWeight.bold,

            ),

          ),





          content:


          SingleChildScrollView(



            child:


            Column(



              crossAxisAlignment:
              CrossAxisAlignment.start,



              children: [





                Text(

                  "📍 المحافظة: ${station.governorate}",

                ),




                const SizedBox(height:8),





                Text(

                  "📍 القضاء: ${station.district}",

                ),





                const Divider(),






                Text(

                  "🟢 بنزين عادي : ${station.regular95} لتر",

                ),






                Text(

                  "🔵 بنزين محسن : ${station.improved95} لتر",

                ),





                Text(

                  "🟠 زيت الغاز : ${station.diesel} لتر",

                ),





                Text(

                  "🟣 النفط الأبيض : ${station.whiteOil} لتر",

                ),





                Text(

                  "🟡 الغاز السائل : ${station.lpg} لتر",

                ),






                const SizedBox(height:15),





                Text(

                  station.active

                      ? "الحالة : ${station.workingStatus}"

                      : "الحالة : معطلة",



                  style:


                  TextStyle(

                    color:

                    station.active

                        ? Colors.green

                        : Colors.red,


                    fontWeight:
                    FontWeight.bold,

                  ),


                ),




              ],



            ),


          ),








          actions: [





            TextButton(


              onPressed: (){


                Navigator.pop(context);


              },


              child:

              const Text(
                  "إغلاق"
              ),


            ),







            ElevatedButton.icon(



              icon:

              const Icon(
                  Icons.navigation
              ),





              label:

              const Text(
                  "ابدأ الملاحة"
              ),





              onPressed:() async {



                Navigator.pop(context);




                await navigationService
                    .navigateToStation(


                  station.latitude,


                  station.longitude,


                );



              },



            ),





          ],




        );


      },


    );



  }









  @override
  Widget build(BuildContext context){



    return Scaffold(




      appBar:

      AppBar(


        title:

        const Text(
            "خريطة المحطات"
        ),


        centerTitle:
        true,


      ),







      body:


      GoogleMap(



        initialCameraPosition:



        CameraPosition(




          target:

          currentPosition != null


              ? LatLng(

            currentPosition!.latitude,

            currentPosition!.longitude,

          )


              :

          const LatLng(

            33.3152,

            44.3661,

          ),





          zoom:

          currentPosition != null

              ? 13

              : 6,



        ),






        myLocationEnabled:

        currentPosition != null,



        myLocationButtonEnabled:

        true,




        markers:

        markers,






        onMapCreated:(c){

          controller = c;

          if(currentPosition != null){

            controller!.animateCamera(

              CameraUpdate.newLatLngZoom(

                LatLng(

                  currentPosition!.latitude,

                  currentPosition!.longitude,

                ),

                16,

              ),

            );

          }

        },



      ),







      floatingActionButton:


      FloatingActionButton.extended(




        icon:

        const Icon(
            Icons.my_location
        ),




        label:

        const Text(
            "موقعي"
        ),





        onPressed:() async {



          await getCurrentLocation();




          if(currentPosition != null &&
              controller != null){



            controller!.animateCamera(



              CameraUpdate.newLatLngZoom(



                LatLng(

                  currentPosition!.latitude,

                  currentPosition!.longitude,

                ),



                15,



              ),



            );

          }



        },



      ),





    );


  }



}