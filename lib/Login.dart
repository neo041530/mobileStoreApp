import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:mobilestore/datalist.dart';
import 'package:mobilestore/home.dart';
import 'package:mobilestore/sqflite.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class Login extends StatefulWidget {

  @override
  _Login createState() => _Login();
}
class _Login extends State<Login> {
  int tabindex = 0;
  bool showL = true;//顯示登入密碼
  bool showup = true;//顯示註冊密碼
  bool showupck = true;//顯示註冊確定密碼
  bool mistake = false;//登入帳號密碼錯誤

  var Laccount = TextEditingController();
  var Lpassword = TextEditingController();
  var upaccount = TextEditingController();
  var uppassword = TextEditingController();
  var upckpassword = TextEditingController();
  var LaccountF = FocusNode();
  var LpasswordF = FocusNode();
  var upaccountF = FocusNode();
  var uppasswordF = FocusNode();
  var upckpasswordF = FocusNode();
  List<MemberLogin> member =[];
  QueryBuilder<ParseObject> memberParse = QueryBuilder<ParseObject>(ParseObject('Member'));

  //登入確認
  void json (String string) async{
    var tagsjson = jsonDecode(string) as List;
    member =  tagsjson.map((data) => MemberLogin.fromJson(data)).toList();
    if(member[0].Mid!='null'){
      UserManager.instance.insert(member[0].Mid, member[0].Mname ,member[0].Vid);
      UserManager.instance.query();
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          home(true)), (Route<dynamic> route) => false);
      showToast('登入成功',context:context);
    }
  }
  //登入按鈕事件
  void ckEmpty(String Laccount,String Lpassword){
    if(Laccount.isEmpty | Lpassword.isEmpty){//判斷是否為空的
      showToast("帳號或密碼不能為空",context:context);
    }else{
      memberLogin(Laccount, Lpassword);
    }
  }
  void memberLogin(String account,String password)async{
    memberParse.whereEqualTo('Account',account);
    memberParse.whereEqualTo('Password',password);
    final ParseResponse apiResponse = await memberParse.query();
    print(apiResponse.result.toString());
    if(apiResponse.result.toString() == 'null'){
      setState(() {
        mistake = true;
      });
    }else{
      json(apiResponse.result.toString());
    }
  }
  //註冊密碼與確定密碼不一樣
  void ckpassword(){
    if(upaccount.text.isEmpty|uppassword.text.isEmpty|upckpassword.text.isEmpty){
      showToast("帳號或密碼不能為空",context:context);
    }else{
      if(uppassword.text != upckpassword.text){
        showToast("密碼不一致",context:context);
      }else{//註冊
        Signup(upaccount.text, uppassword.text);
      }
    }
  }
  void Signup(account,password) async{
    memberParse.whereEqualTo('Account',account);
    final ParseResponse apiResponse = await memberParse.query();
    if(apiResponse.result.toString() =='null'){
      var add = ParseObject('Member')
        ..set('Account', account)
        ..set('Password', password);
      await add.save();
      showToast("註冊成功!",context:context);
      upaccount.clear();
      uppassword.clear();
      upckpassword.clear();
      setState(() {
        tabindex = 0;
      });
    }else{
      showToast("帳號重複",context:context);
    }

  }
  Widget signin (){
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 10),
          child: TextFormField(
            controller: Laccount,
            focusNode: LaccountF,
            decoration: InputDecoration(
              //focusColor: Colors.green,
              // focusedBorder: OutlineInputBorder(
              //   borderRadius: BorderRadius.all(Radius.circular(15)),
              //   borderSide: BorderSide(color: Colors.green)
              // ),
                errorText: mistake?'':null,
                labelText: '帳號',
                prefixIcon: Icon(Icons.person,),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))
                )
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
          child: TextFormField(
            controller: Lpassword,
            focusNode: LpasswordF,
            obscureText: showL,
            decoration: InputDecoration(
                labelText: '密碼',
                errorText: mistake?'\u26A0帳號或密碼錯誤':null,
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: showL?Icon(Icons.visibility):Icon(Icons.visibility_off),
                  onPressed: (){
                    setState(() {
                      showL = !showL;
                    });
                  },
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))
                )
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,bottom: 10),
          child: Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              child: Text('登入'),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                    BeveledRectangleBorder(borderRadius: BorderRadius.circular(3))
                ),
                backgroundColor: MaterialStateProperty.all(Colors.green),
                textStyle: MaterialStateProperty.all(TextStyle(fontSize: 20)),
              ),
              onPressed: (){
                ckEmpty(Laccount.text, Lpassword.text);

              },
            ),
          ),
        )
      ],
    );
  }
  Widget signup (){
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 10),
          child: TextFormField(
            controller: upaccount,
            focusNode: upaccountF,
            decoration: InputDecoration(
                labelText: '帳號',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))
                )
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
          child: TextFormField(
            controller: uppassword,
            focusNode: uppasswordF,
            obscureText: showup,
            decoration: InputDecoration(
                labelText: '密碼',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: showup?Icon(Icons.visibility):Icon(Icons.visibility_off),
                  onPressed: (){
                    setState(() {
                      showup = !showup;
                    });
                  },
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))
                )
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
          child: TextFormField(
            controller: upckpassword,
            focusNode: upckpasswordF,
            obscureText: showupck,
            decoration: InputDecoration(
                labelText: '確定密碼',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: showupck?Icon(Icons.visibility):Icon(Icons.visibility_off),
                  onPressed: (){
                    setState(() {
                      showupck = !showupck;
                    });
                  },
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))
                )
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,bottom: 10),
          child: Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              child: Text('註冊'),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                    BeveledRectangleBorder(borderRadius: BorderRadius.circular(3))
                ),
                backgroundColor: MaterialStateProperty.all(Colors.green),
                textStyle: MaterialStateProperty.all(TextStyle(fontSize: 20)),
              ),
              onPressed: (){
                ckpassword();
              },
            ),
          ),
        )
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('登入'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TypewriterAnimatedText('MobileStore',
                        speed: Duration(milliseconds: 500),
                        textStyle: TextStyle(
                            fontSize: 25
                        )
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Center(
                  child: FlutterToggleTab(
                    width: 65,
                    labels: ['登入','註冊'],
                    selectedIndex: tabindex,
                    selectedBackgroundColors: [
                      Colors.green,Colors.green
                    ],
                    selectedLabelIndex: (index){
                      setState(() {
                        tabindex = index;
                      });
                    },
                    selectedTextStyle: TextStyle(
                        color: Colors.white
                    ),
                    unSelectedTextStyle: TextStyle(
                        color: Colors.grey[850]
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(width: 1,color: Colors.grey),
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: tabindex == 0?signin():signup()
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          )
        ],
      ),
    );
  }
}
