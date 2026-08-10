import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/station.dart';
import '../../../services/station_service.dart';



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





  GoogleMapController?
  mapController;




  Position?
  currentPosition;




  final Set<Marker> markers = {};



  List<Station> stations = [];



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


      ].reduce((a,b)=>a>b?a:b);








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

            station.address,



          ),







          onTap:(){


            showStation(station);



          },




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






    final distanceKm =

    (distance / 1000)

        .toStringAsFixed(2);









    showModalBottomSheet(



      context:

      context,





      builder:(_){



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







              const SizedBox(height:10),






              Text(

                "📍 يبعد عنك $distanceKm كم",

              ),






              const Divider(),






              Text(

                "المحافظة: ${station.governorate}",

              ),





              Text(

                "القضاء: ${station.district}",

              ),





              Text(

                "العنوان: ${station.address}",

              ),






              const SizedBox(height:10),





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






              const SizedBox(height:20),







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




              )





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

          "&destination=${station.latitude},${station.longitude}"

          "&travelmode=driving",




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



        myLocationButtonEnabled:

        true,



        markers:

        markers,








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



          if(mapController == null ||
              currentPosition == null)

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