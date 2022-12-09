import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:mobilestore/home.dart';
import 'package:mobilestore/sqflite.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final keyApplicationId = 'lLzRpVCHuZyNC8fXa0SQz4sGQwmFsRfbzXER7auZ';
  final keyClientKey = '99lS93DWrzX5y25ePPdalrb7nHQwlcLzBjzPpVHx';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey,liveQueryUrl:'https://mobilestore.b4a.io');
  runApp(
      MaterialApp(
        home: MyApp(),
        debugShowCheckedModeBanner: false,
      )
  );
}
class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}
class _MyApp extends State<MyApp> {
  bool Login = false;
  String MID ='';
  Future<String> getMID ()async{
    return await UserManager.instance.LoginID().then((value) => MID= value);
  }
  void welcome()async{
    getMID().then((value) => ckLogin(value));
  }
  void ckLogin(String MID) {
    UserManager.instance.query();
    if (MID.length == 2) {
      Login = false;
      Future.delayed(Duration(seconds: 5),(){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
            home(Login)), (Route<dynamic> route) => false);
      });
    } else {
      Login = true;
      Future.delayed(Duration(seconds: 5),(){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
            home(Login)), (Route<dynamic> route) => false);
      });
    }
  }
  void initState(){
    welcome();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Image.asset(
                  'assets/applogo.png'
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: AnimatedTextKit(
                animatedTexts: [
                  //FadeAnimatedText('Mobile', textStyle: TextStyle(fontSize: 30)),
                  WavyAnimatedText('Mobile Store', textStyle: TextStyle(fontSize: 30)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

