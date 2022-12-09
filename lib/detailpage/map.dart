import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobilestore/datalist.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class map extends StatefulWidget {
  final String vid;
  final String vname;
  map(this.vid,this.vname);
  @override
  _map createState() => _map(this.vid,this.vname);
}
class _map extends State<map> {
  final String vid;
  final String vname;
  _map(this.vid,this.vname);
  List<latlng> lat=[];
  bool get = false;
  QueryBuilder<ParseObject> memberParse = QueryBuilder<ParseObject>(ParseObject('Vender'));
  var _kGooglePlex;
  final LiveQuery liveQuery = LiveQuery(debug: true);
  late Subscription<ParseObject>? subscription;
  void updatelng() async{
    subscription = await liveQuery.client.subscribe(memberParse..whereEqualTo('objectId', vid));
    subscription!.on(LiveQueryEvent.update, (value){
      getlatlng(vid);
    });
  }
  void initState(){
    getlatlng(vid);
  }
  void dispose() {
    liveQuery.client.unSubscribe(subscription!);
    super.dispose();
  }
  void getlatlng(objectId) async{
    memberParse.whereEqualTo('objectId', objectId);
    final ParseResponse apiResponse = await memberParse.query();
    if(apiResponse.result.toString() =='null'){

    }else{
      json(apiResponse.result.toString());
    }
  }
  void json(String string){
    var tagsjson = jsonDecode(string) as List;
    lat = tagsjson.map((data) => latlng.fromJson(data)).toList();
    if(lat.isNotEmpty){
      log(lat[0].lat);
      log(lat[0].lng);
      updatelng();
      setState(() {
        get = true;
      });
      _kGooglePlex = CameraPosition(
        target: LatLng(double.parse(lat[0].lng),double.parse(lat[0].lat)),
        zoom: 14.4746,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(vname),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: Container(
          child: get?GoogleMap(
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            markers: {
              Marker(
                  markerId: const MarkerId(''),
                  position: LatLng(double.parse(lat[0].lng),double.parse(lat[0].lat)),
                  infoWindow: const InfoWindow(title:'Store')
              )
            },
          ):Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(Colors.green),
            ),
          ),
        )
    );
  }
}