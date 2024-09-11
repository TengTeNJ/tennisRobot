import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tennis_robot/constant/constants.dart';
import 'package:tennis_robot/models/pickup_ball_model.dart';
import 'package:tennis_robot/models/robot_data_model.dart';

class DataBaseHelper {
   static final DataBaseHelper _instance = DataBaseHelper._internal();

   factory DataBaseHelper() {
     return _instance;
   }

   DataBaseHelper._internal();
   Database? _database;
   // Database? _videoDatabase;
   Future<Database> get database async {
     if (_database != null) {
       return _database!;
     }
     _database = await initDatabase();
     return _database!;
   }

   Future<Database> initDatabase() async {
     String path = join(await getDatabasesPath(), kDataBaseTableName);
     return openDatabase(path, version: 1, onCreate: _onCreate);
   }

   Future<void> _onCreate(Database db,int version) async{
     await db.execute('''
       CREATE TABLE ${kDataBaseTableName} (
          id INTERGER PRIMARYKEY,
          pickupBallNumber TEXT,
          time TEXT
       )
     ''');
   }

   Future<int> updateData( String table, Map<String, dynamic> data, String time) async {
     Database db = await database;
     return await db.update(table, data,where: 'time = ?', whereArgs: [time]);
   }

   Future<int> insertData(String table,PickupBallModel data) async {
     Database db = await database;
     return await db.insert(table, data.toJson());
   }

   Future<List<PickupBallModel>> getData(String table) async {
     Database db = await database;
     final _datas  = await db.rawQuery('SELECT * FROM ${table}');
     List<PickupBallModel> array = [];
     _datas.asMap().forEach((index,element){
       PickupBallModel model = PickupBallModel.modelFromJson(element);
       array.add(model);
     });
     return array;
   }

   Future<void> saveData(int useTime) async {
     final prefs = await SharedPreferences.getInstance();
     prefs.setInt('useTime', useTime);
   }

   Future<int> fetchData() async {
     final prefs = await SharedPreferences.getInstance();
     return prefs.getInt('useTime') ?? 0;
   }

}