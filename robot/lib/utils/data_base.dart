import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tennis_robot/constant/constants.dart';
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
     String path = join(await getDatabasesPath(), 'my_table.db');
     return openDatabase(path, version: 1, onCreate: _onCreate);
   }

   Future<void> _onCreate(Database db,int version) async{
     await db.execute('''
       CREATE TABLE ${kDataBaseTableName} (
          id INTERGER PRIMARYKEY,
          time TEXT,
          pickTime TEXT
       )
     ''');
   }

   Future<int> insertData(String table,String data) async {
     Database db = await database;
     return await db.insert(table, {'ballNumber': data});
   }

}