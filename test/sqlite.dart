import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dart:async';

import 'package:student_class_system/basic_class/account.dart';
import 'package:student_class_system/basic_class/people.dart';

void main() async {
  final database = openDatabase(
    join(await getDatabasesPath(), 'scsys.db'),
    onCreate: (db, version) {
      return db.execute('create table people('
          'no text primary key, '
          'name text, sex text, age int)');
    },
    version: 1,
  );
  // 创建数据库
  Student stu=Student('1', '111', '男', 21);
  final db = await database;
  await db.query()
}
