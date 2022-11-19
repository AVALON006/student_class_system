import 'package:flutter/material.dart';
import 'package:student_class_system/add_page/add_account.dart';
import 'package:student_class_system/cross_global.dart';
import 'package:student_class_system/left_drawer.dart';
import 'package:student_class_system/login.dart';
import 'package:window_size/window_size.dart';
import 'package:provider/provider.dart';
import 'package:student_class_system/teacher_manage.dart';
import 'package:student_class_system/add_page/add_teacher.dart';
import 'package:student_class_system/teacourse_manage.dart';
import 'package:student_class_system/person_info.dart';
import 'package:student_class_system/global.dart';
import 'package:student_class_system/account_manage.dart';
import 'package:student_class_system/add_page/add_tea_course.dart';

import 'dart:io';

const double windowHeight = 600;
//const double windowWidth = windowHeight * 1.618;
const double windowWidth = 800;

void setupWindow() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('选课系统');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: windowWidth,
        height: windowHeight,
      ));
    });
  }
}

void main() async {
  setupWindow();
  // if (identical(0, 0.0)) {
  //   print("不支持web端");
  // }
  //identical(0, 0.0)表明是Web端
  await Global.initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CrossGlobalModel()),
      ],
      child: MaterialApp(
        title: '选课系统',
        initialRoute: "login",
        routes: {
          "login": (context) => LoginPage(),
          "home": (context) => MyHomePage(),
          "per_info": (context) => PersonInfoPage(),
          "add_acc": (context) => AddAccountPage(),
          "add_tea": (context) => AddTeacherPage(),
          'add_tea_course': (context) => AddTeaCoursePage(),
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> title = ["管理界面", "选课信息", "教学课程"];
  final List<List<String>> tabtext = [
    ["账户管理", "教师信息管理", "学生信息管理", "选课信息管理", "教学信息管理"],
    ["已选课程", "未选课程"],
    ["课程管理", "学生管理"]
  ];
  List<List<Widget>> tabpage = [
    [
      AccountManagePage(),
      TeacherManagePage(),
      //TODO 添加其它页面的内容
    ],
    [
      Scaffold(
        appBar: AppBar(title: Text('学生第一页')),
      ),
      Scaffold(
        appBar: AppBar(title: Text('学生第二页')),
      ),
    ],
    [
      TeaCourseManagePage(),
      Scaffold(
        appBar: AppBar(title: Text('老师第二页')),
      ),
    ],
  ];
  List<Tab> tabs = [];

  @override
  void initState() {
    for (String str in tabtext[Global.account!.role]) {
      tabs.add(Tab(
        text: str,
      ));
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var global = context.watch<CrossGlobalModel>();
    if (Global.account == null) {
      Navigator.popAndPushNamed(context, 'login');
    }
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title[Global.account!.role]),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                global.switchMulti();
              },
              icon: Icon(global.multi
                  ? Icons.check_box
                  : Icons.check_box_outline_blank),
              color: Colors.white,
            ),
            SizedBox(
              width: 50,
            ),
          ],
          bottom: TabBar(isScrollable: true, tabs: tabs),
        ),
        drawer: LeftDrawer(),
        body: TabBarView(
          children: tabs.map((Tab tab) {
            String label = tab.text!;
            int index = tabs.indexOf(tab);
            if (index < 2) {
              return tabpage[Global.account!.role][index];
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "This is the $label tab",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  const Text(
                    'You have pushed the button this many times:',
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
