import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:mobilestore/datalist.dart';
import 'package:mobilestore/detailpage/map.dart';
import 'package:mobilestore/home.dart';
import 'package:weather/weather.dart';

import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class Carddetail extends StatefulWidget {
  final String mid;
  final String vid;
  final String vname;
  final bool havelogin;
  const Carddetail(this.mid,this.vid,this.vname,this.havelogin);
  @override
  _Carddetail createState() => _Carddetail(this.mid,this.vid,this.vname,this.havelogin);
}
class _Carddetail extends State<Carddetail> {
  final String mid;
  final String vid;
  final String vname;
  final bool havelogin;
  _Carddetail(this.mid,this.vid,this.vname,this.havelogin);
  bool havefavorite = false;
  bool loading = false;
  int detailindex = 0;
  WeatherFactory weather = WeatherFactory('44eee383bcef13cc60deaa9113cdc160');
  var celsius;
  List<Favoriteobjectid> objectId = [];
  QueryBuilder<ParseObject> favoriteParse = QueryBuilder<ParseObject>(ParseObject('favorite'));
  QueryBuilder<ParseObject> venderParse = QueryBuilder<ParseObject>(ParseObject('Vender'));
  QueryBuilder<ParseObject> menuParse = QueryBuilder<ParseObject>(ParseObject('Menu'));
  String getobjectId = '';
  String photo = '';
  List<ckFavorite> favorite =[];
  List<cardsdetail> detail = [];
  List<Menu> menu = [];
  void initState(){
    ckfavorite(mid, vid);
    carddetail(vid);

  }
  void getMenu(objectId) async{
    menuParse.whereEqualTo('M_ID', objectId);
    final ParseResponse apiResponse = await menuParse.query();
    if(apiResponse.result.toString() =='null'){
    }else{
      log(apiResponse.result.toString());
      jsonmenu(apiResponse.result.toString());
    }
  }
  void jsonmenu(String string){
    var tagsjson = jsonDecode(string) as List;
    menu = tagsjson.map((data) => Menu.fromJson(data)).toList();
    if(menu.isNotEmpty){
      setState(() {
        loading = true;
        //havemenu = true;
      });
    }
  }
  void carddetail(objectId) async{
    venderParse.whereEqualTo('objectId', objectId);
    final ParseResponse apiResponse = await venderParse.query();
    if(apiResponse.result.toString() =='null'){
    }else{
      jsonvender(apiResponse.result.toString());
      log(apiResponse.result.toString());
    }
  }
  void jsonvender(String string) async{
    var tagsjson = jsonDecode(string) as List;
    detail = tagsjson.map((data) => cardsdetail.fromJson(data)).toList();
    if(detail.isNotEmpty){
      double lng = double.parse(detail[0].lng);
      double lat = double.parse(detail[0].lat);
      Weather w = await weather.currentWeatherByLocation(lng,lat);
      getMenu(vid);
      setState(() {
        photo = detail[0].photo.split(':')[3]+':'+detail[0].photo.split(':')[4];
        photo = photo.replaceAll('}', '');
        celsius = w.temperature!.celsius;
      });
    }
  }
  void ckfavorite(MID,VID)async{
    favoriteParse.whereEqualTo('M_ID', MID);
    favoriteParse.whereEqualTo('V_ID', VID);
    final ParseResponse apiResponse = await favoriteParse.query();
    setState(() {
      if(apiResponse.result.toString() =='null'){
        havefavorite = false;
      }else{
        json(apiResponse.result.toString());
        havefavorite = true;
      }
    });
  }
  void json(String string){
    var tagsjson = jsonDecode(string) as List;
    objectId = tagsjson.map((data) => Favoriteobjectid.fromJson(data)).toList();
  }
  void addFavorite(MID,VID)async{
    var add = ParseObject('favorite')
      ..set('M_ID', MID)
      ..set('V_ID', VID);
    await add.save();
    getobjectId = await add.get('objectId');
    log('getobjectId' +getobjectId);
    setState(() {
      havefavorite = true;
    });
    Navigator.pop(context);
    showToast('加入最愛成功',context:context);
  }
  void removeFavorite(objectId) async{
    var remove = ParseObject('favorite')
      ..objectId = objectId;
    await remove.delete();
    setState(() {
      havefavorite = false;
    });
    Navigator.pop(context);
    showToast('移出最愛成功',context:context);
  }
  addfavorite(String name){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('將$name加入最愛'),
            actions: [
              ElevatedButton(
                child: Text('確定'),
                style: ElevatedButton.styleFrom(
                    primary: Colors.green
                ),
                onPressed: (){
                  addFavorite(mid, vid);
                },
              )
            ],
          );
        }
    );
  }
  removefavorite(String name){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('將$name移出最愛'),
            actions: [
              ElevatedButton(
                child: Text('確定'),
                style: ElevatedButton.styleFrom(
                    primary: Colors.green
                ),
                onPressed: (){
                  if(getobjectId == ''){
                    log(objectId[0].objectId);
                    removeFavorite(objectId[0].objectId);
                  }else{
                    log(getobjectId);
                    removeFavorite(getobjectId);
                  }

                },
              )
            ],
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading?CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.green,
            floating: false,
            pinned: true,
            expandedHeight: 230,
            //title: loading?Container(color : Colors.white,child: Text(detail[0].name)):Text('加載中'),
            leading:TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                shape: CircleBorder(),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                    home(havelogin)), (Route<dynamic> route) => false);
              },
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: CircleBorder(),
                ),
                child: havefavorite?Icon(Icons.star,color: Colors.white,):Icon(Icons.star_border_outlined,color: Colors.white),
                onPressed: () {
                  if(havelogin){
                    if(havefavorite){
                      removefavorite(vname);
                    }else{
                      addfavorite(vname);
                    }
                  }else{
                    showToast('請先登入',context:context);
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
                background:Container(
                  color: Colors.grey[50],
                  child: ClipPath(
                      clipper: CustomClipPath(),
                      child: Image.network(
                        photo.trim(),
                        fit: BoxFit.cover,
                      )
                  ),
                )
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(detail[0].name,style: TextStyle(fontSize: 25),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10,),
                      child: Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('一'),
                                  Checkbox(
                                    value: detail[0].weektime1 == '1'? true:false,
                                    activeColor: Colors.green,
                                    onChanged: (value){
                                    },
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('二'),
                                  Checkbox(
                                    value: detail[0].weektime2 == '1'?true:false,
                                    activeColor: Colors.green,
                                    onChanged: (value){
                                    },
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('三'),
                                  Checkbox(
                                    value: detail[0].weektime3 == '1'?true:false,
                                    activeColor: Colors.green,
                                    onChanged: (value){
                                    },
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('四'),
                                  Checkbox(
                                    value: detail[0].weektime4 == '1'?true:false,
                                    activeColor: Colors.green,
                                    onChanged: (value){
                                    },
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('五'),
                                  Checkbox(
                                    value: detail[0].weektime5 == '1'?true:false,
                                    activeColor: Colors.green,
                                    onChanged: (value){
                                    },
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('六'),
                                  Checkbox(
                                    value: detail[0].weektime6 == '1'?true:false,
                                    activeColor: Colors.green,
                                    onChanged: (value){
                                    },
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('日'),
                                  Checkbox(
                                    value: detail[0].weektime7 == '1'?true:false,
                                    activeColor: Colors.green,
                                    onChanged: (value){
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text('連絡電話: '+detail[0].phone,style: TextStyle(fontSize: 18),),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text('營業時間: '+detail[0].daytime,style: TextStyle(fontSize: 18),),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text('地區溫度: '+celsius.toStringAsFixed(1) + '°C',style: TextStyle(fontSize: 18),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8,top: 8,right: 8,bottom: 20),
                      child: Container(
                        height: 80,
                        child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: InkWell(
                              onTap: (){
                                Navigator.push(
                                    context, MaterialPageRoute(
                                    builder: (context) =>map(detail[0].vid,detail[0].name))
                                );
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    child: Opacity(
                                      opacity: 0.5,
                                      child: Container(
                                          width: double.infinity,
                                          child: Image.asset('assets/mapbackground.jpg',fit: BoxFit.fill)
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.location_on,size: 35,),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(detail[0].place,style: TextStyle(fontSize: 15),),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('地圖',style: TextStyle(fontSize: 15)),
                                            Icon(Icons.arrow_right_alt,size: 30,)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                        ),
                      ),
                    ),
                  ]
              )
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                return ShowMenu(menu[index].name,menu[index].price, menu[index].photo);//menu[index].photo
              },
                  childCount: menu.length
              )
          )
        ],
      ):Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation(Colors.green),
        ),
      ),
    );
  }
  Widget ShowMenu (name,price,photo){
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(name,style: TextStyle(fontSize: 18),),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: Text(price,style: TextStyle(color: Colors.grey[600]),),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: 80,
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20,top: 5,bottom: 5),
                  child: photo != 'null'? ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      photo.split(':')[3].trim()+':'+photo.split(':')[4].replaceAll('}', ''),
                      fit: BoxFit.fill,
                    ),
                  ):null,
                ),
              ),
            ),
          ],
        ),
        Divider(
          height: 2,
          color: Colors.grey,
          indent:20,
          endIndent: 20,
        )
      ],
    );
  }
}
class CustomClipPath extends CustomClipper<Path>{
  @override
  Path getClip (Size size){
    double w = size.width;
    double h = size.height;

    final path = Path();
    path.lineTo(0, h-35);
    path.quadraticBezierTo(w*0.5, h, w, h-35);
    path.lineTo(w, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper){
    return false;
  }
}
