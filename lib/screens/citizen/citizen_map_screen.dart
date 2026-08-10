import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/station.dart';
import '../../services/station_service.dart';



class CitizenMapScreen extends StatefulWidget {

  const CitizenMapScreen({
    super.key,
  });


  @override
  State<CitizenMapScreen> createState() =>
      _CitizenMapScreenState();

}







class _CitizenMapScreenState
    extends State<CitizenMapScreen> {



  final StationService stationService =
      StationService.instance;



  GoogleMapController?
  mapController;



  final Set<Marker> markers = {};

  final Set<Polyline> polylines = {};



  List<Station> stations = [];



  Position?
  currentPosition;



  bool loading = true;









  @override
  void initState(){

    super.initState();

    loadData();

  }









  Future<void> loadData() async {



    final enabled =
    await Geolocator.isLocationServiceEnabled();



    if(!enabled){

      setLoading(false);

      return;

    }







    LocationPermission permission =

    await Geolocator.checkPermission();






    if(permission ==
        LocationPermission.denied){



      permission =
      await Geolocator.requestPermission();


    }







    if(permission ==
        LocationPermission.deniedForever){


      setLoading(false);

      return;

    }








    currentPosition =

    await Geolocator.getCurrentPosition(

      desiredAccuracy:
      LocationAccuracy.high,

    );






    stations =
    await stationService.getApprovedStations();




    createMarkers();




    setLoading(false);



  }









  void setLoading(bool value){


    if(!mounted)
      return;


    setState(() {


      loading = value;


    });


  }









  void createMarkers(){



    markers.clear();




    for(final station in stations){





      final quantity = [

        station.regular95,

        station.improved95,

        station.super95,

        station.diesel,

        station.whiteOil,

        station.lpg,


      ].reduce((a,b)=> a > b ? a : b);







      BitmapDescriptor color;





      if(quantity > 10000){


        color =
            BitmapDescriptor.defaultMarkerWithHue(

              BitmapDescriptor.hueGreen,

            );



      }

      else if(quantity > 3000){


        color =
            BitmapDescriptor.defaultMarkerWithHue(

              BitmapDescriptor.hueYellow,

            );


      }

      else if(quantity > 0){


        color =
            BitmapDescriptor.defaultMarkerWithHue(

              BitmapDescriptor.hueOrange,

            );


      }

      else{


        color =
            BitmapDescriptor.defaultMarkerWithHue(

              BitmapDescriptor.hueRed,

            );


      }









      markers.add(



        Marker(



          markerId:

          MarkerId(

              station.id

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


              showStation(station);


            },


          ),



        ),



      );



    }



  }









  void showStation(Station station){



    if(currentPosition == null)
      return;





    final distance =

    Geolocator.distanceBetween(


      currentPosition!.latitude,


      currentPosition!.longitude,


      station.latitude,


      station.longitude,


    );





    final km =

    (distance / 1000)

        .toStringAsFixed(2);








    showModalBottomSheet(



      context:

      context,



      shape:

      const RoundedRectangleBorder(



        borderRadius:

        BorderRadius.vertical(

          top:

          Radius.circular(25),

        ),

      ),




      builder:(context){



        return Padding(



          padding:

          const EdgeInsets.all(20),





          child:



          Column(



            mainAxisSize:

            MainAxisSize.min,




            crossAxisAlignment:

            CrossAxisAlignment.start,




            children:[





              Text(

                station.name,


                style:

                const TextStyle(

                  fontSize:22,

                  fontWeight:

                  FontWeight.bold,

                ),


              ),






              Text(

                "الموقع: ${station.governorate} - ${station.district}",

              ),





              Text(

                "المسافة: $km كم",

              ),




              const Divider(),




              Text(
                "بنزين عادي: ${station.regular95} لتر",
              ),



              Text(
                "بنزين محسن: ${station.improved95} لتر",
              ),



              Text(
                "بنزين سوبر: ${station.super95} لتر",
              ),



              Text(
                "ديزل: ${station.diesel} لتر",
              ),



              Text(
                "نفط أبيض: ${station.whiteOil} لتر",
              ),



              Text(
                "غاز: ${station.lpg} لتر",
              ),






              const SizedBox(height:15),





              SizedBox(

                width:

                double.infinity,



                child:

                ElevatedButton.icon(



                  icon:

                  const Icon(
                      Icons.navigation
                  ),




                  label:

                  const Text(
                      "ابدأ الملاحة"
                  ),




                  onPressed:(){

                    openNavigation(station);

                  },



                ),



              ),




            ],




          ),




        );



      },


    );



  }









  Future<void> openNavigation(
      Station station
      ) async {



    final uri = Uri.parse(


      "https://www.google.com/maps/dir/?api=1"

          "&destination=${station.latitude},${station.longitude}",



    );





    if(await canLaunchUrl(uri)){


      await launchUrl(

        uri,

        mode:

        LaunchMode.externalApplication,

      );


    }


  }









  @override
  Widget build(BuildContext context){



    if(loading){



      return const Scaffold(



        body:

        Center(

          child:

          CircularProgressIndicator(),

        ),


      );


    }






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




        myLocationEnabled:

        true,



        markers:

        markers,



        polylines:

        polylines,




        onMapCreated:(controller){


          mapController = controller;


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




        onPressed:(){



          if(currentPosition == null ||
              mapController == null)

            return;






          mapController!.animateCamera(



            CameraUpdate.newLatLngZoom(



              LatLng(

                currentPosition!.latitude,

                currentPosition!.longitude,

              ),



              15,


            ),



          );



        },



      ),




    );



  }









  @override
  void dispose(){


    mapController?.dispose();


    super.dispose();


  }



}