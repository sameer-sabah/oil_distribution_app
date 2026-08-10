import 'package:flutter/material.dart';

import '../services/station_service.dart';
import '../services/branch_service.dart';
import '../services/user_service.dart';

import 'admin/users_screen.dart';
import 'admin/branches_screen.dart';


import 'products_screen.dart';
import 'reports_screen.dart';

import 'notifications_screen.dart';



class AdminScreen extends StatefulWidget {


  const AdminScreen({
    super.key,
  });


  @override
  State<AdminScreen> createState() =>
      _AdminScreenState();

}




class _AdminScreenState
    extends State<AdminScreen> {



  final StationService stationService =
      StationService.instance;


  final BranchService branchService =
      BranchService.instance;


  final UserService userService =
      UserService.instance;





  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(


        title:
        const Text(
          "لوحة الإدارة",
        ),


        centerTitle:true,


      ),





      body:

      ListView(


        padding:
        const EdgeInsets.all(16),


        children: [



          const Text(

            "لوحة المتابعة",

            style:
            TextStyle(

              fontSize:24,

              fontWeight:
              FontWeight.bold,

            ),

          ),




          const SizedBox(
            height:20,
          ),







          Row(

            children: [


              Expanded(

                child:

                FutureBuilder<int>(

                  future:
                  stationService
                      .getStationsCount(),


                  builder:
                      (context,snapshot){


                    return _infoCard(

                      "المحطات",

                      snapshot.data ?? 0,

                      Icons.local_gas_station,

                    );


                  },

                ),

              ),






              const SizedBox(
                width:10,
              ),






              Expanded(

                child:

                FutureBuilder<int>(

                  future:
                  branchService
                      .getBranchesCount(),


                  builder:
                      (context,snapshot){


                    return _infoCard(

                      "الفروع",

                      snapshot.data ?? 0,

                      Icons.account_balance,

                    );


                  },

                ),

              ),



            ],

          ),







          const SizedBox(
            height:10,
          ),






          FutureBuilder<int>(

            future:
            userService.getUsersCount(),


            builder:
                (context,snapshot){


              return _infoCard(

                "المستخدمون",

                snapshot.data ?? 0,

                Icons.people,

              );


            },


          ),
          const SizedBox(
            height:25,
          ),
          _menuCard(

            title:
            "إدارة الفروع",

            subtitle:
            "إضافة وتعديل وحذف الفروع وإنشاء حساب مدير الفرع",

            icon:
            Icons.account_tree,
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_)=>
                  const BranchesScreen(
                      governorateId: "anbar",
                      governorateName: "الأنبار",
                ),
                    ),
              );

            },

          ),



          _menuCard(

            title:
            "إدارة المستخدمين",


            subtitle:
            "الحسابات والصلاحيات",


            icon:
            Icons.people,


            onTap: (){


              Navigator.push(

                context,

                MaterialPageRoute(

                  builder:(_)=>

                      UsersScreen(),

                ),

              );


            },


          ),







          _menuCard(

            title:
            "إدارة المنتجات",


            subtitle:
            "إضافة وتعديل المنتجات",


            icon:
            Icons.inventory,


            onTap: (){


              Navigator.push(

                context,

                MaterialPageRoute(

                  builder:(_)=>

                  const ProductsScreen(),

                ),

              );


            },


          ),







          _menuCard(

            title:
            "التقارير",


            subtitle:
            "الإحصائيات والتقارير",


            icon:
            Icons.bar_chart,


            onTap: (){


              Navigator.push(

                context,

                MaterialPageRoute(

                  builder:(_)=>

                  const ReportsScreen(),

                ),

              );


            },


          ),







          const SizedBox(
            height:30,
          ),





          ElevatedButton.icon(


            icon:
            const Icon(
              Icons.logout,
            ),



            label:
            const Text(
              "تسجيل الخروج",
            ),




            onPressed:(){


              Navigator.pushNamedAndRemoveUntil(

                context,

                "/login",

                    (route)=>false,

              );


            },


          ),



        ],



      ),


    );


  }









  Widget _infoCard(

      String title,

      int value,

      IconData icon,

      ){


    return Card(

      child:

      Padding(

        padding:
        const EdgeInsets.all(15),


        child:

        Column(

          children: [


            Icon(

              icon,

              size:35,

            ),



            const SizedBox(
              height:10,
            ),



            Text(

              value.toString(),

              style:
              const TextStyle(

                fontSize:25,

                fontWeight:
                FontWeight.bold,

              ),

            ),



            Text(title),


          ],


        ),


      ),


    );


  }









  Widget _menuCard({

    required String title,

    required String subtitle,

    required IconData icon,

    required VoidCallback onTap,


  }){


    return Card(

      child:

      ListTile(

        leading:

        Icon(icon),



        title:

        Text(

          title,

          style:
          const TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),



        subtitle:

        Text(subtitle),



        trailing:

        const Icon(
          Icons.arrow_forward_ios,
        ),



        onTap:
        onTap,


      ),


    );


  }



}