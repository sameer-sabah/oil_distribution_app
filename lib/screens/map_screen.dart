import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../models/station.dart';
import '../services/station_service.dart';
import '../services/navigation_service.dart';



class MapScreen extends StatefulWidget {

  const MapScreen({
    super.key,
  });


  @override
  State<MapScreen> createState() =>
      _MapScreenState();

}






class _MapScreenState
    extends State<MapScreen> {



  final StationService stationService =
      StationService.instance;



  final NavigationService navigationService =
  const NavigationService();



  GoogleMapController?
  mapController;



  final TextEditingController searchController =
  TextEditingController();



  Position?
  currentPosition;



  final Set<Marker> markers = {};



  List<Station> stations = [];



  bool loading = true;







  @override
  void initState(){

    super.initState();

    initialize();

  }







  Future<void> initialize() async {

    await getCurrentLocation();

    await loadStations();

  }







  Future<void> getCurrentLocation() async {



    bool enabled =
    await Geolocator.isLocationServiceEnabled();



    if(!enabled)
      return;




    LocationPermission permission =
    await Geolocator.checkPermission();




    if(permission ==
        LocationPermission.denied){


      permission =
      await Geolocator.requestPermission();


    }




    if(permission ==
        LocationPermission.deniedForever){


      return;


    }





    currentPosition =
    await Geolocator.getCurrentPosition(

      desiredAccuracy:
      LocationAccuracy.high,

    );



  }








  Future<void> loadStations() async {



    stations =
    await stationService.getStations();




    markers.clear();




    for(final station in stations){



      BitmapDescriptor color;



      if(!station.active){


        color =
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            );


      }

      else if(station.workingStatus ==
          "تعمل"){


        color =
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            );


      }

      else{


        color =
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            );


      }







      markers.add(



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

          color,



          infoWindow:


          InfoWindow(


            title:

            station.name,



            snippet:

            "${station.governorate} - ${station.district}",



            onTap:(){


              showStation(
                station,
              );


            },

          ),


        ),


      );



    }





    if(!mounted)
      return;




    setState(() {


      loading = false;


    });



  }









  void searchStation(String value){



    if(value.trim().isEmpty)
      return;




    try{


      final station =

      stations.firstWhere(


            (e)=>

            e.name
                .toLowerCase()
                .contains(
              value.toLowerCase(),
            ),


      );





      mapController?.animateCamera(



        CameraUpdate.newLatLngZoom(



          LatLng(

            station.latitude,

            station.longitude,

          ),


          16,


        ),



      );




      showStation(
        station,
      );



    }

    catch(e){



      ScaffoldMessenger.of(context)
          .showSnackBar(



        const SnackBar(

          content:

          Text(
              "المحطة غير موجودة"
          ),


        ),


      );



    }


  }









  double calculateDistance(



      double lat1,

      double lon1,

      double lat2,

      double lon2,


      ){



    return Geolocator.distanceBetween(

      lat1,

      lon1,

      lat2,

      lon2,


    ) / 1000;



  }









  Station?
  nearestStation(){



    if(currentPosition == null ||
        stations.isEmpty){


      return null;


    }




    Station nearest =
        stations.first;



    double minDistance =

    calculateDistance(


      currentPosition!.latitude,


      currentPosition!.longitude,


      nearest.latitude,


      nearest.longitude,


    );







    for(final station in stations){



      final distance =

      calculateDistance(


        currentPosition!.latitude,


        currentPosition!.longitude,


        station.latitude,


        station.longitude,


      );





      if(distance < minDistance){



        minDistance =
            distance;



        nearest =
            station;


      }


    }




    return nearest;


  }









  void goToNearestStation(){



    final station =
    nearestStation();




    if(station == null){



      ScaffoldMessenger.of(context)
          .showSnackBar(



        const SnackBar(

          content:

          Text(
              "لا توجد محطة قريبة"
          ),


        ),


      );



      return;


    }






    mapController?.animateCamera(



      CameraUpdate.newLatLngZoom(



        LatLng(

          station.latitude,

          station.longitude,

        ),



        16,


      ),


    );




    showStation(
      station,
    );



  }









  void showStation(
      Station station
      ){


    showModalBottomSheet(


      context:
      context,



      builder:(_){



        return Padding(


          padding:
          const EdgeInsets.all(16),



          child:


          Column(


            mainAxisSize:
            MainAxisSize.min,



            crossAxisAlignment:
            CrossAxisAlignment.start,



            children: [



              Text(

                station.name,


                style:
                const TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),




              Text(

                "المحافظة: ${station.governorate}",

              ),




              Text(

                "القضاء: ${station.district}",

              ),




              Text(

                "بنزين: ${station.regular95}",

              ),



              Text(

                "ديزل: ${station.diesel}",

              ),




            ],


          ),


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


      loading


          ?


      const Center(

        child:

        CircularProgressIndicator(),

      )



          :



      GoogleMap(



        initialCameraPosition:

        CameraPosition(



          target:

          currentPosition == null

              ?

          const LatLng(

            33.3152,

            44.3661,

          )


              :

          LatLng(

            currentPosition!.latitude,

            currentPosition!.longitude,

          ),



          zoom:

          12,


        ),



        markers:

        markers,



        myLocationEnabled:

        true,



        onMapCreated:(controller){


          mapController =
              controller;


        },


      ),



      floatingActionButton:

      FloatingActionButton(

        onPressed:

        goToNearestStation,


        child:

        const Icon(
            Icons.near_me
        ),


      ),



    );

  }







  @override
  void dispose(){


    searchController.dispose();


    mapController?.dispose();


    super.dispose();


  }





}