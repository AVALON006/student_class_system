import 'package:flutter/material.dart';
import 'global.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 33, 150, 243)),
            child: Align(
              alignment: Alignment.center,
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  width: 100,
                  height: 100,
                  child: Center(
                    child: Text(
                      Global.account!.name[0].toUpperCase(),
                      style: TextStyle(color: Colors.blue, fontSize: 40),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('个人信息'),
            onTap: () => Navigator.pushNamed(context, 'per_info'),
          ),
          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: Text("设置"),
          // ),
          ListTile(
              leading: Icon(Icons.logout),
              title: Text("退出登录"),
              onTap: () =>
                  Navigator.popUntil(context, ModalRoute.withName('login')))
        ],
      ),
    );
  }
}
