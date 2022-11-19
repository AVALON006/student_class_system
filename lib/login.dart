import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import './global.dart';
import 'account.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode usernamefocusnode = FocusNode();
  FocusNode passwordfocusnode = FocusNode();
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  void login() async {
    String name = usernamecontroller.text;
    String pass = passwordcontroller.text;
    Results res = await Global.conn.query(
        'select count(*) from Account where '
        'Aname = ? and Apass = ?',
        [name, pass]);
    bool success = false;
    for (var row in res) {
      success = row[0] == 1 ? true : false;
      break;
    }
    if (success) {
      res = await Global.conn.query(
          'select Aname,Apass,Arole,Ano from Account '
          'where Aname = ? and Apass = ?',
          [name, pass]);
      for (var row in res) {
        Global.account = Account(row[0], row[1], row[2], row[3]);
        break;
      }
      Navigator.pushNamed(context, "home");
    } else {
      Global.ShowAlert("登陆失败", "用户名或密码错误！",context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "选课系统",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 30,
                ),
              ),
              SizedBox(
                height: 70,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: TextField(
                  autofocus: true,
                  controller: usernamecontroller,
                  decoration: InputDecoration(
                    labelText: "用户名",
                    prefixIcon: Icon(Icons.person),
                  ),
                  focusNode: usernamefocusnode,
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(passwordfocusnode),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: TextField(
                  obscureText: true,
                  autofocus: true,
                  controller: passwordcontroller,
                  decoration: InputDecoration(
                    labelText: "密码",
                    prefixIcon: Icon(Icons.lock),
                  ),
                  focusNode: passwordfocusnode,
                  onEditingComplete: login,
                ),
              ),
              SizedBox(
                height: 70,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(100, 50)),
                onPressed: login,
                child: Text(
                  "登录",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ]),
      ),
    );
  }
}
