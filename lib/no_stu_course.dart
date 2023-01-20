import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:student_class_system/global.dart';
import 'package:student_class_system/already_stu_course.dart';

class NoStuCoursePage extends StatefulWidget {
  const NoStuCoursePage({super.key});

  @override
  State<NoStuCoursePage> createState() => _NoStuCoursePageState();
}

class _NoStuCoursePageState extends State<NoStuCoursePage> {
  List<TeaCourseItem> items = [];

  void loadItems() async {
    Results res = await Global.conn.query(
        'select Cno,Cname,Ccredit from Course where Cno not in ('
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
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.blue,
                size: 28,
              ),
              onPressed: () async {
                await Global.conn.query(
                    'insert into SC (Sno,Cno) values( ? , ? )',
                    [Global.account!.no, items[index].course_no]);
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
