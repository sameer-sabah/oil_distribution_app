import 'package:flutter/material.dart';
import '../../services/governorate_service.dart';
import '../../models/branch_model.dart';
import '../../models/governorate_model.dart';
import '../../services/branch_service.dart';
import 'station_management/government_stations_screen.dart';
import 'station_management/private_stations_screen.dart';
import '../../services/notification_service.dart';



class BranchesScreen extends StatefulWidget {

  final String? governorateId;
  final String? governorateName;


  const BranchesScreen({

    super.key,

    this.governorateId,

    this.governorateName,

  });



  @override
  State<BranchesScreen> createState() =>
      _BranchesScreenState();

}





class _BranchesScreenState
    extends State<BranchesScreen> {


  final BranchService branchService =
      BranchService.instance;

  final NotificationService notificationService =
      NotificationService.instance;

  List<BranchModel> branches = [];
  List<GovernorateModel> governorates = [];

  GovernorateModel? selectedGovernorate;


  final GovernorateService governorateService =
      GovernorateService.instance;
  bool loading = true;




  @override
  void initState() {

    super.initState();

    loadBranches();

    loadGovernorates();

  }
  Future<void> loadGovernorates() async {

    governorates =
    await governorateService
        .getForRegister();

    if(!mounted) return;

    setState(() {});

  }




  Future<void> loadBranches() async {


    setState(() {

      loading = true;

    });



    if(widget.governorateId == null){

      branches =
      await branchService.getBranches();

    }else{

      branches =
      await branchService.getGovernorateBranches(
        widget.governorateId!,
      );

    }



    if(!mounted) return;



    setState(() {

      loading = false;

    });


  }








  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar:

      AppBar(

        title:

        Text(

            widget.governorateName == null
                ?
            "إدارة الفروع"
                :
            "اضافة فرع ${widget.governorateName}"

        ),

        centerTitle:true,

      ),





      floatingActionButton:

      FloatingActionButton(

        onPressed:
        _showAddBranchDialog,


        child:

        const Icon(
          Icons.add,
        ),

      ),





      body:

      loading

          ?

      const Center(

        child:
        CircularProgressIndicator(),

      )


          :

      branches.isEmpty

          ?

      const Center(

        child:
        Text(
          "لا توجد فروع",
        ),

      )

          :

      RefreshIndicator(


        onRefresh:
        loadBranches,



        child:

        ListView.builder(


          itemCount:
          branches.length,



          itemBuilder:
              (context,index){


            final branch =
            branches[index];



            return ExpansionTile(

              leading: const Icon(
                Icons.account_balance,
              ),

              title: Text(
                branch.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),


              trailing: PopupMenuButton<String>(

                icon: const Icon(
                  Icons.more_vert,
                ),


                onSelected: (value) async {



                  if(value == "edit"){

                    _showEditBranchDialog(branch);

                  }


                  if(value == "delete"){


                    final confirm = await showDialog<bool>(

                      context: context,

                      builder: (context){

                        return AlertDialog(

                          title: const Text(
                            "حذف الفرع",
                          ),

                          content: Text(
                            "هل تريد حذف ${branch.name} ؟",
                          ),

                          actions: [

                            TextButton(
                              onPressed: (){
                                Navigator.pop(context,false);
                              },
                              child: const Text("إلغاء"),
                            ),


                            ElevatedButton(

                              onPressed: (){

                                Navigator.pop(context,true);

                              },

                              child: const Text("حذف"),

                            ),

                          ],

                        );

                      },

                    );


                    if(confirm == true){

                      await branchService
                          .deleteBranch(branch.id);


                      loadBranches();

                    }


                  }


                  if(value == "notify"){

                    _showNotifyDialog(branch);

                  }


                },


                itemBuilder: (context)=>[


                  const PopupMenuItem(

                    value: "edit",

                    child: Row(

                      children: [

                        Icon(
                          Icons.edit,
                          color: Colors.orange,
                        ),

                        SizedBox(width:10),

                        Text("تعديل"),

                      ],

                    ),

                  ),



                  const PopupMenuItem(

                    value: "delete",

                    child: Row(

                      children: [

                        Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),

                        SizedBox(width:10),

                        Text("حذف"),

                      ],

                    ),

                  ),



                  const PopupMenuItem(

                    value: "notify",

                    child: Row(

                      children: [

                        Icon(
                          Icons.notifications,
                          color: Colors.blue,
                        ),

                        SizedBox(width:10),

                        Text("تبليغ"),

                      ],

                    ),

                  ),



                ],

              ),



              children: [

                ListTile(

                  leading: const Icon(
                    Icons.account_balance,
                  ),

                  title: const Text(
                    "المحطات الحكومية",
                  ),

                  onTap: (){

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            GovernmentStationsScreen(
                              branchId: branch.id,
                            ),
                      ),

                    );

                  },

                ),


                ListTile(

                  leading: const Icon(
                    Icons.store,
                  ),

                  title: const Text(
                    "المحطات الأهلية",
                  ),

                  onTap: (){

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            PrivateStationsScreen(
                              branchId: branch.id,
                            )
                      ),

                    );

                  },

                ),

              ],

            );

          },


        ),


      ),


    );


  }









  void _showAddBranchDialog(){


    final branchName =
    TextEditingController();



    final managerName =
    TextEditingController();



    final username =
    TextEditingController();



    final password =
    TextEditingController();



    final email =
    TextEditingController();



    final phone =
    TextEditingController();







    showDialog(


      context:
      context,


      builder:
          (dialogContext){


        return AlertDialog(



          title:

          Text(
            "إضافة فرع - ${widget.governorateName}",
          ),




          content:

          SingleChildScrollView(

            child:

            Column(

              children:[
                DropdownButtonFormField<GovernorateModel>(

                  value: selectedGovernorate,

                  decoration: const InputDecoration(

                    labelText: "المحافظة",

                    border: OutlineInputBorder(),

                  ),


                  items:

                  governorates.map((g){

                    return DropdownMenuItem(

                      value:g,

                      child:
                      Text(g.name),

                    );

                  }).toList(),


                  onChanged:(v){

                    setState((){

                      selectedGovernorate = v;

                    });

                  },

                ),


                const SizedBox(height:10),


                field(
                  branchName,
                  "اسم الفرع",
                ),



                field(
                  managerName,
                  "اسم مدير الفرع",
                ),



                field(
                  username,
                  "اسم المستخدم",
                ),



                field(
                  password,
                  "كلمة المرور",
                  password:true,
                ),



                field(
                  email,
                  "البريد الإلكتروني",
                ),



                field(
                  phone,
                  "رقم الهاتف",
                ),



              ],

            ),

          ),




          actions:[



            TextButton(

              onPressed: (){

                Navigator.pop(
                  dialogContext,
                );

              },

              child:
              const Text(
                "إلغاء",
              ),

            ),




            ElevatedButton(


              child:

              const Text(
                "حفظ",
              ),



              onPressed: () async {

                if(selectedGovernorate == null){

                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    const SnackBar(
                      content: Text("اختر المحافظة أولاً"),
                    ),

                  );

                  return;

                }

                await branchService.addBranch(



                  governorateId:
                  selectedGovernorate!.id,

                  governorateName:
                  selectedGovernorate!.name,




                  branchName:

                  branchName.text.trim(),




                  managerName:

                  managerName.text.trim(),




                  username:

                  username.text.trim(),




                  password:

                  password.text.trim(),




                  phone:

                  phone.text.trim(),




                  email:

                  email.text.trim(),




                  address:

                  "",



                );




                if(!mounted) return;



                Navigator.pop(
                  dialogContext,
                );



                loadBranches();



              },


            ),



          ],



        );


      },


    );

  }








  Widget field(

      TextEditingController controller,

      String label,

      {

        bool password=false,

      }

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


        obscureText:
        password,



        decoration:

        InputDecoration(

          labelText:
          label,

          border:
          const OutlineInputBorder(),

        ),


      ),


    );


  }
  void _showEditBranchDialog(BranchModel branch){

    final nameController =
    TextEditingController(
      text: branch.name,
    );

    showDialog(

      context: context,

      builder: (context){

        return AlertDialog(

          title: const Text(
            "تعديل الفرع",
          ),


          content:

          TextField(

            controller: nameController,

            decoration: const InputDecoration(

              labelText: "اسم الفرع",

              border: OutlineInputBorder(),

            ),

          ),



          actions: [


            TextButton(

              onPressed: (){

                Navigator.pop(context);

              },

              child: const Text(
                "إلغاء",
              ),

            ),



            ElevatedButton(

              onPressed: () async {


                final updated =
                branch.copyWith(

                  name:
                  nameController.text.trim(),

                );


                await branchService
                    .updateBranch(
                  updated,
                );


                if(!mounted) return;


                Navigator.pop(context);


                loadBranches();


              },


              child: const Text(
                "حفظ",
              ),

            ),


          ],


        );

      },

    );

  }

  void _showNotifyDialog(BranchModel branch){

    final messageController =
    TextEditingController();


    showDialog(

      context: context,

      builder: (context){

        return AlertDialog(

          title: Text(
            "تبليغ فرع ${branch.name}",
          ),


          content: TextField(

            controller: messageController,

            maxLines: 4,

            decoration: const InputDecoration(

              labelText: "نص التبليغ",

              border: OutlineInputBorder(),

            ),

          ),


          actions: [


            TextButton(

              onPressed: (){

                Navigator.pop(context);

              },

              child:
              const Text("إلغاء"),

            ),



            ElevatedButton(

              onPressed: () async {


                await notificationService.addNotification(

                  userId: branch.managerId,

                  title: "تبليغ من الإدارة",

                  message:
                  messageController.text.trim(),

                  type: "branch",

                );


                Navigator.pop(context);


                ScaffoldMessenger.of(context)
                    .showSnackBar(

                  const SnackBar(

                    content:
                    Text("تم إرسال التبليغ"),

                    backgroundColor:
                    Colors.green,

                  ),

                );


              },

              child:
              const Text("إرسال"),

            ),


          ],

        );

      },

    );

  }
}