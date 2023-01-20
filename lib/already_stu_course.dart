import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:student_class_system/global.dart';

class AlreadyStuCoursePage extends StatefulWidget {
  const AlreadyStuCoursePage({super.key});

  @override
  State<AlreadyStuCoursePage> createState() => _AlreadyStuCoursePageState();
}

class TeaCourseItem {
  String course_no;
  String course_name;
  String course_credit;
  List<String> course_tea = [];
  TeaCourseItem(this.course_no, this.course_name, this.course_credit);

  Future<void> getCourseTea() async {
    Results res = await Global.conn.query(
        'select Pname from People where Pno in ('
        'select Tno from TC where Cno = ?)',
        [course_no]);
    for (var row in res) {
      course_tea.add(row[0]);
    }
  }
}

class _AlreadyStuCoursePageState extends State<AlreadyStuCoursePage> {
  List<TeaCourseItem> items = [];

  void loadItems() async {
    Results res = await Global.conn.query(
        'select Cno,Cname,Ccredit from Course where Cno in ('
        'select Cno from SC where Sno = ?)',
        [Global.account!.no]);
    for (var row in res) {
      TeaCourseItem elem = TeaCourseItem(row[0], row[1], row[2].toString());
      await elem.getCourseTea();
      items.add(elem);
    }
    setState(() {});
  }

  Widget itembuilder(BuildContext context, int index) {
    if (index == items.length) {
      return Container();
    }
    return ListTile(
      title: Text(items[index].course_name),
      subtitle: Text('任课教师：' + items[index].course_tea.join("  ")),
      trailing: SizedBox(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              items[index].course_credit + "学分",
              style: TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: Icon(
                Icons.remove,
                color: Colors.blue,
                size: 28,
              ),
              onPressed: () async {
                await Global.conn.query(
                    'delete from SC where Cno = ?', [items[index].course_no]);
                items.removeAt(index);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: itembuilder,
      itemCount: items.length + 1,
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: Colors.blue,
        );
      },
      shrinkWrap: true,
    );
  }
}
