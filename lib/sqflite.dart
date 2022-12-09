import 'dart:developer';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
class member {
  final String mid;
  final String mname;
  final String vid;

  member(this.mid, this.mname,this.vid);

  Map<String, dynamic> toMap() {
    return {
      "MID": mid,
      "MName": mname,
      "VID" : vid
    };
  }
}
class DatabaseHelper {
  static final _databaseName = "Userdata_Database.db";
  static final _databaseVersion = 1;

  static final table = 'USERDATA';

  //Singleton 單例模式，確保一個類別只有一個實例
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE USERDATA(
                MID TEXT PRIMARY KEY,
                MName TEXT,
                VID TEXT)
          ''');
  }
  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database? db = await instance.database;
    return await db!.query(table);
  }
  Future<String> LoginID () async{
    Database? db = await instance.database;
    var sql = await "SELECT MID FROM USERDATA";
    var res = await db!.rawQuery(sql);
    return res.toString();
  }
  Future<String> UserID () async{
    Database? db = await instance.database;
    var sql = await "SELECT MID FROM USERDATA";
    var res = await db!.rawQuery(sql);
    String workid = res.toString().substring(7);
    workid = workid.substring(0,workid.length-2);
    return workid.toString();
  }
  Future<String> getVID () async{
    Database? db = await instance.database;
    var sql = await "SELECT VID FROM USERDATA";
    var res = await db!.rawQuery(sql);
    String workid = res.toString().substring(7);
    workid = workid.substring(0,workid.length-2);
    return res.toString();
  }
  Future<String> CKVID () async{
    Database? db = await instance.database;
    var sql = await "SELECT VID FROM USERDATA";
    var res = await db!.rawQuery(sql);
    return res.toString();
  }
  Future<dynamic> Delete () async{
    Database? db = await instance.database;
    var res = await db!.delete(table);
    return res;
  }
}

class UserManager {
  final dbHelper = DatabaseHelper.instance;

  //Singleton 單例模式，確保一個類別只有一個實例
  UserManager._privateConstructor();

  static final UserManager instance = UserManager._privateConstructor();

  void insert(String M_ID,String M_Name,String V_ID) async {
    var student = member(
        M_ID,
        M_Name,
        V_ID
    );
    dbHelper.insert(student.toMap());
    print('--- insert 執行結束---');
  }
  void query() async {
    final rows = await dbHelper.queryAllRows();
    print('查詢結果:');
    rows.forEach((row) => print(row));
    print('--- query 執行結束---');
  }
  Future<dynamic> Delete () async{
    return dbHelper.Delete().then((value) => value);
  }
  Future<String> UserID() async{
    return dbHelper.UserID().then((value) => value);
  }
  Future<String> LoginID() async{
    return dbHelper.LoginID().then((value) => value);
  }
  Future<String> getVID() async{
    return dbHelper.getVID().then((value) => value);
  }
  Future<String> CKVID() async{
    return dbHelper.CKVID().then((value) => value);
  }
}