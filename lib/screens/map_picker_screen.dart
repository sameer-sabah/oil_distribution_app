import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


class MapPickerScreen extends StatefulWidget {

  const MapPickerScreen({
    super.key,
  });


  @override
  State<MapPickerScreen> createState() =>
      _MapPickerScreenState();

}





class _MapPickerScreenState
    extends State<MapPickerScreen> {


  GoogleMapController? mapController;



  LatLng? selectedLocation;
  bool loading = true;


  LatLng initialLocation =
  const LatLng(
    33.3152,
    44.3661,
  );






  @override
  void initState(){

    super.initState();

    getCurrentLocation();

  }
  Future<void> getCurrentLocation() async {


    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();


    if(!serviceEnabled) return;



    LocationPermission permission =
    await Geolocator.checkPermission();



    if(permission == LocationPermission.denied){

      permission =
      await Geolocator.requestPermission();

    }



    if(permission == LocationPermission.deniedForever){

      return;

    }



    Position position =
    await Geolocator.getCurrentPosition(

      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),

    );



    final location =
    LatLng(
      position.latitude,
      position.longitude,
    );



    setState((){

      selectedLocation =
          location;

    });
    setState((){

      loading = false;

    });


    if(mapController != null){

      mapController!.animateCamera(

        CameraUpdate.newLatLngZoom(

          location,

          16,

        ),

      );

    }

  }






  @override
  Widget build(BuildContext context){


    return Scaffold(



      appBar:

      AppBar(

        title:
        const Text(
          "تحديد موقع المحطة",
        ),

        centerTitle:
        true,

      ),






      body:


        loading

        ?
        const Center(
        child: CircularProgressIndicator(),
    )

        :



      GoogleMap(

        mapType: MapType.hybrid,

        initialCameraPosition:

        CameraPosition(

          target:
          selectedLocation!,

          zoom:
          16,

        ),




        myLocationEnabled:
        true,


        myLocationButtonEnabled:
        true,





        onMapCreated:(controller){

          mapController =
              controller;


          if(selectedLocation != null){

            controller.animateCamera(

              CameraUpdate.newLatLngZoom(

                selectedLocation!,

                16,

              ),

            );

          }

        },






        onTap:(location){


          setState((){


            selectedLocation =
                location;


          });


        },







        markers:


        selectedLocation == null

            ?

        {}

            :

        {


          Marker(

            markerId:
            const MarkerId(
              "station",
            ),


            position:
            selectedLocation!,


          ),


        },




      ),






      floatingActionButton:


      FloatingActionButton.extended(



        onPressed:



        selectedLocation == null

            ?

        null

            :


            (){


          Navigator.pop(

            context,

            selectedLocation,

          );


        },





        icon:

        const Icon(
          Icons.check,
        ),




        label:

        const Text(

          "تأكيد الموقع",

        ),



      ),



    );


  }



}