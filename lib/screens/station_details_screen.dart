import 'package:flutter/material.dart';

import '../models/station.dart';



class StationDetailsScreen extends StatelessWidget {


  final Station station;



  const StationDetailsScreen({

    super.key,

    required this.station,

  });







  @override
  Widget build(BuildContext context) {


    return Scaffold(



      appBar: AppBar(


        title:

        Text(

          station.name,

        ),


        centerTitle: true,


      ),






      body:


      SingleChildScrollView(


        padding:

        const EdgeInsets.all(16),



        child:


        Column(



          children: [






            _card(

              icon:

              Icons.local_gas_station,


              title:

              "معلومات المحطة",



              children: [



                _row(
                  "اسم المحطة",
                  station.name,
                ),




                _row(
                  "نوع المحطة",
                  station.stationType,
                ),




                _row(
                  "المحافظة",
                  station.governorate,
                ),




                _row(
                  "القضاء",
                  station.district,
                ),




                _row(
                  "الفرع",
                  station.branchName,
                ),




                _row(
                  "حالة النشاط",
                  station.active
                      ? "فعالة"
                      : "غير فعالة",
                ),




                _row(
                  "حالة الاعتماد",
                  station.approved
                      ? "معتمدة"
                      : "غير معتمدة",
                ),



              ],


            ),







            const SizedBox(height:15),







            _card(

              icon:

              Icons.person,


              title:

              "بيانات المدير",



              children: [



                _row(
                  "اسم المدير",
                  station.managerName,
                ),





                _row(
                  "هاتف المدير",
                  station.managerPhone,
                ),





                _row(
                  "هاتف المحطة",
                  station.phone,
                ),



              ],



            ),







            const SizedBox(height:15),







            _card(

              icon:

              Icons.location_on,


              title:

              "الموقع",



              children: [



                _row(
                  "العنوان",
                  station.address,
                ),





                _row(
                  "Latitude",
                  station.latitude.toString(),
                ),





                _row(
                  "Longitude",
                  station.longitude.toString(),
                ),



              ],


            ),







            const SizedBox(height:15),







            _card(

              icon:

              Icons.inventory,


              title:

              "الكميات المتوفرة",



              children: [



                _row(
                  "بنزين عادي",
                  "${station.regular95} لتر",
                ),





                _row(
                  "بنزين محسن",
                  "${station.improved95} لتر",
                ),





                _row(
                  "بنزين سوبر",
                  "${station.super95} لتر",
                ),





                _row(
                  "زيت الغاز",
                  "${station.diesel} لتر",
                ),





                _row(
                  "النفط الأبيض",
                  "${station.whiteOil} لتر",
                ),





                _row(
                  "الغاز السائل",
                  "${station.lpg} لتر",
                ),



              ],



            ),







            const SizedBox(height:15),







            _card(

              icon:

              Icons.description,


              title:

              "بيانات الرخصة",



              children: [



                _row(
                  "رقم الرخصة",
                  station.licenseNumber,
                ),





                _row(
                  "جهة الإصدار",
                  station.licenseIssuer,
                ),



              ],


            ),







            const SizedBox(height:15),







            _card(

              icon:

              Icons.note,


              title:

              "معلومات إضافية",



              children: [



                _row(
                  "ساعات العمل",
                  station.workingHours.isEmpty
                      ? "غير محددة"
                      : station.workingHours,
                ),





                _row(
                  "ملاحظات",
                  station.notes.isEmpty
                      ? "لا يوجد"
                      : station.notes,
                ),



              ],



            ),




          ],


        ),


      ),



    );


  }









  Widget _card({

    required IconData icon,

    required String title,

    required List<Widget> children,

  }){


    return Card(


      elevation:4,


      child:


      Padding(

        padding:

        const EdgeInsets.all(15),



        child:


        Column(



          crossAxisAlignment:

          CrossAxisAlignment.start,



          children: [



            Row(

              children: [



                Icon(icon),



                const SizedBox(width:10),



                Text(

                  title,

                  style:

                  const TextStyle(

                    fontSize:18,

                    fontWeight:

                    FontWeight.bold,

                  ),

                ),



              ],

            ),




            const Divider(),



            ...children,



          ],



        ),


      ),


    );

  }









  Widget _row(

      String title,

      String value,

      ){



    return Padding(



      padding:

      const EdgeInsets.symmetric(

        vertical:5,

      ),



      child:


      Row(



        mainAxisAlignment:

        MainAxisAlignment.spaceBetween,



        children: [



          Text(

            title,

            style:

            const TextStyle(

              fontWeight:

              FontWeight.bold,

            ),

          ),




          Flexible(

            child:

            Text(value),

          ),



        ],


      ),


    );

  }


}