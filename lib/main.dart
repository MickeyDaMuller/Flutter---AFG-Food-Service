import 'package:flutter/material.dart';
import 'package:afg_service/login_page.dart';
import 'package:afg_service/select_location.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

//void main() => runApp(MyApp());

Future<void> main() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  var password = prefs.getString('password');


  //below make the app orientation portrait
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);


  //var id = prefs.getString('id');

  //int id_id = int.parse(id);

  print(email);
  print(password);
  // print(id);
  runApp(MaterialApp(home: email == null ? MyLoginPage() : SelectLocationPage(),debugShowCheckedModeBanner: false,));
}



