import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:student_class_system/people.dart';
import 'package:student_class_system/global.dart';

class TeaCourseStuManagePage extends StatefulWidget {
  const TeaCourseStuManagePage({super.key});

  @override
  State<TeaCourseStuManagePage> createState() => _TeaCourseStuManagePageState();
}

class CourseItem {
  String cno;
  String cname;
  List<Student> stus = [];
  bool isExpanded = false;
  CourseItem(this.cno, this.cname);
  Future<void> LoadStus() async {
    Results res = await Global.conn.query(
        'select Pno,Pname,Psex,Page from People where Pno in (select Sno from SC where Cno = ?)',
        [cno]);
    for (var stu in res) {
      stus.add(Student(stu[0], stu[1], stu[2], stu[3]));
    }
  }
}

class _TeaCourseStuManagePageState extends State<TeaCourseStuManagePage> {
  List<CourseItem> items = [];

  void loadItems() async {
    Results res = await Global.conn.query(
        'select tc.Cno,Cname from Course c,TC tc '
        'where c.Cno=tc.Cno and tc.Tno = ?',
        [Global.account!.no]);
    for (var course in res) {
      CourseItem tmp = CourseItem(course[0], course[1]);
      await tmp.LoadStus();
      items.add(tmp);
    }
    setState(() {});
  }

  List<ExpansionPanel> buildPanel() {
    return List.generate(items.length, (index) {
      return ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
            title: Text(items[index].cname),
          );
        },
        body: Wrap(
          spacing: 10,
          children: List.generate(items[index].stus.length, (stuIndex) {
            Student stu = items[index].stus[stuIndex];
            return Chip(
              label: Text(stu.name),
              onDeleted: (() {
                //删除学生
              }),
            );
          }),
        ),
        isExpanded: items[index].isExpanded,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  @override
  Widget build(BuildContext context) {
    if (items.length == 0) {
      return Global.waitMySql;
    } else {
      return SingleChildScrollView(
        child: ExpansionPanelList(
          expansionCallback: ((panelIndex, isExpanded) {
            setState(() {
              items[panelIndex].isExpanded = !isExpanded;
            });
          }),
          children: buildPanel(),
        ),
      );
    }
  }
}
