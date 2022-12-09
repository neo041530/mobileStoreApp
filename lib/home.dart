import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:mobilestore/Login.dart';
import 'package:mobilestore/datalist.dart';
import 'package:mobilestore/page/CardsList.dart';
import 'package:mobilestore/page/MyFolder.dart';
import 'package:mobilestore/sqflite.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';

class home extends StatefulWidget {
  final bool havelogin;
  home(this.havelogin);
  @override
  _home createState() => _home(this.havelogin);
}
class _home extends State<home> {
  final bool havelogin;
  _home(this.havelogin);
  int bottombarindex = 0;
  var page = [];
  var size;
  List<Version> version = [];
  QueryBuilder<ParseObject> VersionParse = QueryBuilder<ParseObject>(ParseObject('Version'));
  String VID ='';
  bool updateAPP = false;
  bool downloadAPP = false;
  final Dio  dio = Dio();
  void initState(){
    CKVID();
    page =[
      CardsList(havelogin),
      MyFolder()
    ];
    GetVersion();
  }
  void GetVersion()async{
    if(Platform.isAndroid){
      VersionParse.whereEqualTo('System','Android');
      final ParseResponse apiResponse = await VersionParse.query();
      if(apiResponse.result.toString() =='null'){

      }else{
        jsonVersion(apiResponse.result.toString());
      }
    }else if(Platform.isIOS){

    }
  }
  //要求檔案權限
  Future<bool> checkPermissionStorage() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }
  void jsonVersion(String string)async{
    var tagsjson = jsonDecode(string) as List;
    version =  tagsjson.map((data) => Version.fromJson(data)).toList();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if(version.isNotEmpty){
      String localVersion = packageInfo.buildNumber;
      log('本機版本: '+localVersion);
      log('最新版本: '+version[0].number);
      if(version[0].number != localVersion){//需更新
        setState(() {
          updateAPP = true;
        });
      }else{//最新版本
        showToast("目前為最新版本",context:context);
      }
    }

  }
  void DownloadAPP()async{
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage
    ].request();
    final isPermissionStatusGranted = await checkPermissionStorage();
    if (isPermissionStatusGranted) {
      final savePath = path.join('/storage/emulated/0/Download', 'mobilestore.apk');
      final response = await dio.download(
        version[0].File.split(':')[3].trim()+':'+version[0].File.split(':')[4].replaceAll('}', '').trim(),
        savePath,
      );
      if(response.statusCode == 200){
        OpenFile.open(savePath);
      }
    } else {

    }
  }
  Future<String> CKVID ()async{
    return await UserManager.instance.CKVID().then((value) => VID = value);
  }
  List<BottomNavigationBarItem> bottombar(){
    return[
      BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.list),
          backgroundColor: Colors.green,
          label: '總覽'
      ),
      BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.folderOpen),
          backgroundColor: Colors.green,
          label: '名片夾'
      ),
    ];
  }
  @override
  Widget ShowUpdate(double width,double height){
    return GestureDetector(
      onTap: (){
      },
      child: Container(
        width: width,
        height: height,
        color: Colors.black.withOpacity(0.5),
        child: GestureDetector(
          onTap: (){
          },
          child: Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                constraints: BoxConstraints.tightFor(width: 300,height: 200),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          '新版本通知',
                          style: TextStyle(
                              fontSize: 20
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '立即點擊「更新」\n我們將提供更好的服務',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey
                        ),
                      ),
                    ),
                    Divider(
                      height: 5,
                      color: Colors.grey,
                      indent: 0.0,
                      endIndent: 0.0,
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: (){
                          log(version[0].File.split(':')[3].trim()+':'+version[0].File.split(':')[4].replaceAll('}', '').trim());
                          setState(() {
                            DownloadAPP();
                            updateAPP = false;
                            downloadAPP = true;
                          });
                        },
                        child: Center(
                            child: Text(
                              '更新',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blueAccent
                              ),
                            )
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  Widget ShowDownload(double width,double height){
    return GestureDetector(
      onTap: (){
      },
      child: Container(
        width: width,
        height: height,
        color: Colors.black.withOpacity(0.5),
        child: GestureDetector(
          onTap: (){
          },
          child: Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                constraints: BoxConstraints.tightFor(width: 300,height: 200),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          '下載中請稍候',
                          style: TextStyle(
                              fontSize: 20
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(Colors.green),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          '請勿關閉程式',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: bottombarindex == 0?Text('流動攤販'):Text('最愛'),
        centerTitle: true,
        actions: [
          havelogin?IconButton(
            icon: Icon(Icons.person),
            onPressed: (){
              log(VID);
              if(VID.length == 2){//沒有創建攤販

              }else{

              }
            },
          ):Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              child: Text('登入',style: TextStyle(color: Colors.white),),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      width: 1,
                      color: Colors.white
                  )
              ),
              onPressed: (){
                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) =>Login())
                );
              },
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              page[bottombarindex],
            ],
          ),
          if(updateAPP)
            ShowUpdate(size.width,size.height),
          if(downloadAPP)
            ShowDownload(size.width,size.height)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: bottombar(),
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[350],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: bottombarindex,
        onTap: (index){
          setState(() {
            if(havelogin){
              bottombarindex = index;
            }else{
              if(index==1){
                showToast('請先登入',context:context);
              }
            }
          });
        },
      ),
    );
  }
}
