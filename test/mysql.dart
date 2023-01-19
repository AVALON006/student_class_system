import 'package:mysql1/mysql1.dart';

void main() async {
  var settings = new ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'flutter',
      password: 'flutter',
      db: 'scsys');
  var conn = await MySqlConnection.connect(settings);
  await Future.delayed(Duration(seconds: 1));
  Results rownum = await conn.query('select count(*) from People');
  if (rownum.isEmpty) {
    await conn.query(
        'create table Student(Sno char(9) primary key,Sname char(20),Ssex char(2),Sage smallint)');
  }
  print(rownum);
  return;
}
