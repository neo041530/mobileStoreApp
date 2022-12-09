import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobilestore/Carddetail.dart';
import 'package:mobilestore/datalist.dart';
import 'package:mobilestore/sqflite.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class MyFolder extends StatefulWidget {
  @override
  _MyFolder createState() => _MyFolder();
}
class _MyFolder extends State<MyFolder> {
  List<Totalcards> favoritecards = [];
  List<Totalcards> allfavoritecards = [];
  List<Totalcards> searchallfavoritecards = [];
  List<Favorite> favoriteid = [];
  bool card = false;
  String MID = '';
  QueryBuilder<ParseObject> favoriteParse = QueryBuilder<ParseObject>(ParseObject('favorite'));
  QueryBuilder<ParseObject> favoritecardParse = QueryBuilder<ParseObject>(ParseObject('Vender'));
  var search_text = TextEditingController();
  void initState(){
    getMID().then((value) => ckfavorit(value));
  }
  void ckfavorit(MID)async{
    favoriteParse.whereEqualTo('M_ID', MID);
    final ParseResponse apiResponse = await favoriteParse.query();
    log(apiResponse.results.toString());
    log(MID);
    if(apiResponse.result.toString() =='null'){

    }else{
      jsonVID(apiResponse.result.toString());
    }
  }
  void getfavorite(VID)async{
    favoritecardParse.whereEqualTo('objectId', VID);
    final ParseResponse apiResponse = await favoritecardParse.query();
    log(apiResponse.result.toString());
    if(apiResponse.result.toString() =='null'){

    }else{
      json(apiResponse.result.toString());
    }
  }
  Future<String> getMID ()async{
    return await UserManager.instance.UserID().then((value) => MID = value);
  }
  void jsonVID(string){
    var tagsjson = jsonDecode(string) as List;
    favoriteid =  tagsjson.map((data) => Favorite.fromJson(data)).toList();
    if(favoriteid.isNotEmpty){
      for(int i = 0;i<favoriteid.length;i++){
        getfavorite(favoriteid[i].VID);
      }
    }
  }
  void json(String string){
    var tagsjson = jsonDecode(string) as List;
    favoritecards =  tagsjson.map((data) => Totalcards.fromJson(data)).toList();
    if(favoritecards.isNotEmpty){
      allfavoritecards.addAll(favoritecards);
      setState(() {
        card = true;
      });
    }
  }
  Widget Carsd(vid,name,adress,phone,photo){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 25),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 10,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
        ),
        child: InkWell(
          onTap: (){
            Navigator.push(
                context, MaterialPageRoute(
                builder: (context) =>Carddetail(MID,vid,name,true))
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Ink.image(
                    height: 100,
                    image: NetworkImage(photo.split(':')[3].trim()+':'+photo.split(':')[4].replaceAll('}', '')),//'https://parsefiles.back4app.com/lLzRpVCHuZyNC8fXa0SQz4sGQwmFsRfbzXER7auZ/ee861a6489f46387dfc0b2ea27cba474_store2.jpg'
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10,top: 5,bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 15
                      ),
                    ),
                    Text(
                      '$adress',
                      style: TextStyle(
                          color: Colors.grey[600]
                      ),
                    ),
                    Text(
                      '$phone',
                      style: TextStyle(
                          color: Colors.grey[600]
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.only(left: 25,right: 25,top: 10,bottom: 10),
              child: TextField(
                controller: search_text,
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(Icons.search),
                    hintText: '搜尋店名',
                    enabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    )
                ),
                onChanged: (value){
                  setState(() {
                    searchallfavoritecards = allfavoritecards
                        .where((element) => element.name.contains(value))
                        .toList();
                  });
                },
              ),
            ),
          ),
          Expanded(
              child: card?ListView.builder(
                itemCount: search_text.text.isNotEmpty?searchallfavoritecards.length:allfavoritecards.length,
                itemBuilder: search_text.text.isNotEmpty?(context,i){
                  final favorite = searchallfavoritecards[i];
                  return Carsd(favorite.vid,favorite.name,favorite.place,favorite.phone,favorite.photo);
                }:(context,i){
                  final favorite = allfavoritecards[i];
                  return Carsd(favorite.vid,favorite.name,favorite.place,favorite.phone,favorite.photo);
                },
              ):Container(
                child: Center(
                    child: Text('還未有最愛攤販趕快去逛逛吧！')
                ),
              )
          ),
        ],
      ),
    );
  }
}
