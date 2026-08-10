import 'package:flutter/material.dart';

import '../../services/user_service.dart';
import 'add_user_screen.dart';


class UsersScreen extends StatefulWidget {

  const UsersScreen({
    super.key,
  });


  @override
  State<UsersScreen> createState() =>
      _UsersScreenState();

}



class _UsersScreenState
    extends State<UsersScreen> {


  final UserService userService =
      UserService.instance;


  List<Map<String,dynamic>> users = [];


  List<Map<String,dynamic>> filteredUsers = [];


  final searchController =
  TextEditingController();


  @override
  void initState(){

    super.initState();

    loadUsers();

  }


  Future<void> loadUsers() async {

    users =
    await userService.getUsers();


    if(!mounted)
      return;


    setState((){

      filteredUsers = users;

    });

  }


  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(

        title:
        const Text(
            "إدارة المستخدمين"
        ),

      ),


      body:
      const Center(

        child:
        Text(
            "شاشة المستخدمين"
        ),

      ),


      floatingActionButton:

      FloatingActionButton(

        child:
        const Icon(Icons.add),


        onPressed:() {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder:(_)=>

              const AddUserScreen(),

            ),

          );

        },

      ),

    );

  }


  @override
  void dispose(){

    searchController.dispose();

    super.dispose();

  }


}