import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:student_class_system/account.dart';

class Global {
  static const themes = <MaterialColor>[
    Colors.blue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.pink,
    Colors.grey
  ];
  static ConnectionSettings settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'flutter',
    password: 'flutter',
    db: 'scsys',
  );
  static Account? account;
  static List<String> role = ["管理员", "学生", "老师"];
  static String reg0_20 = ".{1,20}";

  static late MySqlConnection conn;

  static Future<bool> ValidAccName(String name) async {
    Results res = await Global.conn.query(
        'select count(*) from Account '
        'where Aname = ?',
        [name]);
    for (var row in res) {
      if (row[0] != 0) {
        return false;
      }
    }
    if (!RegExp(Global.reg0_20).hasMatch(name)) {
      return false;
    }
    return true;
  }

  static Future<bool> ValidPeopleNo(String no) async {
    Results res = await Global.conn.query(
        'select count(*) from People '
        'where Pno = ?',
        [no]);
    for (var row in res) {
      if (row[0] != 0) {
        return false;
      }
    }
    return true;
  }

  static ValidName(String name) {
    if (!RegExp(Global.reg0_20).hasMatch(name)) {
      return false;
    }
    return true;
  }

  static bool ValidPass(String pass) {
    return RegExp(reg0_20).hasMatch(pass);
  }

  static bool ValidRole(String role) {
    int? newrole = int.tryParse(role);
    if (newrole == null) {
      return false;
    }
    return [0, 1, 2].contains(newrole);
  }

  static bool ValidAge(String age) {
    int? newage = int.tryParse(age);
    if (newage == null) {
      return false;
    }
    if (0 <= newage && newage <= 100) {
      return true;
    } else {
      return false;
    }
  }

  static bool ValidSex(String sex) {
    if (sex.compareTo("男") == 0 || sex.compareTo("女") == 0) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> ValidAccNoRole(String no, String role) async {
    if (!ValidRole(role)) {
      return false;
    }
    Results res = await Global.conn.query(
        'select count(*) from Account '
        'where Ano = ?',
        [no]);
    for (var row in res) {
      if (row[0] != 0) {
        return false;
      }
    }
    res = await Global.conn.query(
        'select count(*) from People '
        'where Pno = ? and Prole = ?',
        [no, int.parse(role)]);
    for (var row in res) {
      if (row[0] == 0) {
        return false;
      }
    }
    return true;
  }

  static Future<bool> ValidCourseNo(String no) async {
    Results res = await Global.conn.query(
        'select count(*) from Course '
        'where Cno = ?',
        [no]);
    for (var row in res) {
      if (row[0] != 0) {
        return false;
      }
    }
    return true;
  }

  static bool ValidCredit(String credit) {
    int? newcredit = int.tryParse(credit);
    if (newcredit == null) {
      return false;
    }
    if (0 <= newcredit && newcredit <= 10) {
      return true;
    } else {
      return false;
    }
  }

  static void ShowAlert(String title, String alert, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("title"),
          content: Text(
            alert,
            style: TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "确定",
                style: TextStyle(fontSize: 15),
              ),
            )
          ],
        );
      },
    );
  }

  Global() {
    initDatabase();
  }

  static initDatabase() async {
    conn = await MySqlConnection.connect(settings);
    await conn.query('create table if not exists People('
        'Pno char(9) primary key,'
        'Pname char(20),'
        'Psex char(2),'
        'Page smallint,'
        'Prole smallint)');
    //1学生2老师
    await Future.delayed(Duration(seconds: 1));
    //bug等待有可用的连接
    Results res = await conn.query(
        'select Pno from People'
        ' where Pno = ?',
        ['0']);
    if (res.isEmpty) {
      await conn.query(
          'insert into People values(?,?,?,?,?)', ['0', 'admin', '未知', 0, 0]);
    }
    await conn.query('create table if not exists Account('
        'Aname char(20) primary key,'
        'Apass char(20),'
        'Arole smallint,'
        'Ano char(9),'
        'foreign key (Ano) references People(Pno))');
    //0管理员1老师2学生
    await conn.query('create table if not exists Course('
        'Cno char(9) primary key,'
        'Cname char(20),'
        'Ccredit smallint)');
    await conn.query('create table if not exists TC('
        'Tno char(9),'
        'Cno char(9),'
        'primary key (Tno,Cno),'
        'foreign key (Tno) references People(Pno),'
        'foreign key (Cno) references Course(Cno))');
    await conn.query('create table if not exists SC('
        'Sno char(9),'
        'Cno char(9),'
        'Grade smallint,'
        'primary key (Sno,Cno),'
        'foreign key (Sno) references People(Pno),'
        'foreign key (Cno) references Course(Cno))');
    res = await conn.query(
        'select Ano from Account'
        ' where Aname = ?',
        ['admin']);

    if (res.isEmpty) {
      await conn.query(
          'insert into Account values(?,?,?,?)', ['admin', 'admin', 0, '0']);
    }
  }

  static closeDatabase() async {
    await conn.close();
  }

  static Future init() async {}
}
