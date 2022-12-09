import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobilestore/Carddetail.dart';
import 'package:mobilestore/datalist.dart';
import 'package:mobilestore/sqflite.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class CardsList extends StatefulWidget {
  final bool havelogin;
  CardsList(this.havelogin);
  @override
  _CardsList createState() => _CardsList(this.havelogin);
}
class _CardsList extends State<CardsList> {
  QueryBuilder<ParseObject> VenderParse = QueryBuilder<ParseObject>(ParseObject('Vender'));
  final bool havelogin;
  List<Totalcards> totalcards = [];
  List<Totalcards> searchtotalcards = [];
  _CardsList(this.havelogin);
  bool card = false;
  String MID ='';
  var search_text = TextEditingController();
  void initState(){
    print(havelogin);
    SetTotalCard();
    getMID().then((value) => MID = value);
  }
  Future<String> getMID ()async{
    return await UserManager.instance.UserID().then((value) =>MID= value);
  }
  void SetTotalCard() async{
    final ParseResponse apiResponse = await VenderParse.query();
    if(apiResponse.result.toString() =='null'){

    }else{
      json(apiResponse.result.toString());
    }
  }
  void json(String string)async{
    var tagsjson = jsonDecode(string) as List;
    totalcards =  tagsjson.map((data) => Totalcards.fromJson(data)).toList();
    if(totalcards.isNotEmpty){
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
                builder: (context) =>Carddetail(MID,vid,name,havelogin))
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
                    searchtotalcards = totalcards
                        .where((element) => element.name.contains(value))
                        .toList();
                  });
                },
              ),
            ),
          ),
          Expanded(
              child: card ? ListView.builder(
                itemCount: search_text.text.isNotEmpty?searchtotalcards.length:totalcards.length,
                itemBuilder: search_text.text.isNotEmpty? (context,i){
                  final list = searchtotalcards[i];
                  return Carsd(list.vid,list.name,list.place,list.phone,list.photo.trim());
                }:(context,i){
                  final list = totalcards[i];
                  return Carsd(list.vid,list.name,list.place,list.phone,list.photo.trim());
                },
              ):Container(
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(Colors.green),
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }

}
