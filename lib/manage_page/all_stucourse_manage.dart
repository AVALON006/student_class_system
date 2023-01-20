import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:student_class_system/basic_class/people.dart';
import 'package:student_class_system/global.dart';
import 'package:provider/provider.dart';
import 'package:student_class_system/cross_global.dart';
import 'package:student_class_system/basic_class/course.dart';

class AllStuCourseManagePage extends StatefulWidget {
  const AllStuCourseManagePage({super.key});

  @override
  State<AllStuCourseManagePage> createState() => _AllStuCourseManagePageState();
}

class StuCourseItem {
  String stu_no;
  String stu_name;
  String course_no;
  String course_name;
  String? grade;
  StuCourseItem(this.stu_no, this.stu_name, this.course_no, this.course_name);
}

class _AllStuCourseManagePageState extends State<AllStuCourseManagePage> {
  List<StuCourseItem> items = [];
  List<String> colstr = ['学号', '学生姓名', '课程号', '课程名称'];
  List<DataColumn> cols = [];
  List<bool> selected = [];

  TextEditingController controller = TextEditingController();

  void initcols() {
    cols = List.generate(colstr.length, (index) {
      return DataColumn(
        label: Text(
          colstr[index],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    });
  }

  Future<void> loadItems() async {
    items = [];
    Results res = await Global.conn.query('select Sno,Pname,sc.Cno,Cname from '
        'SC sc,People p,Course c where sc.Sno=p.Pno and sc.Cno=c.Cno');
    for (var row in res) {
      StuCourseItem elem = StuCourseItem(row[0], row[1], row[2], row[3]);
      items.add(elem);
      selected.add(false);
    }
    setState(() {});
  }

  void modifyStuCourse(int index, int num) async {
    switch (num) {
      case 1:
      case 2:
        //修改学生
        List<Student> allStus = [];
        Results res = await Global.conn
            .query('select Pno,Pname,Psex,Page from People where Prole = 1');
        for (var row in res) {
          allStus.add(Student(row[0], row[1], row[2], row[3]));
        }
        List<Widget> stuOpts = List.generate(
          allStus.length,
          (i) => SimpleDialogOption(
            onPressed: () async {
              await Global.conn.query(
                  'update SC set Sno = ? where Sno = ? and Cno = ?',
                  [allStus[i].no, items[index].stu_no, items[index].course_no]);
              setState(() {
                items[index].stu_name = allStus[i].name;
                items[index].stu_no = allStus[i].no;
              });
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(allStus[i].name),
            ),
          ),
        );
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text('请选择学生'),
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: stuOpts,
                  ),
                ),
              ],
            );
          },
        );
        return;
      case 3:
      case 4:
        //修改课程
        List<Course> allCourse = [];
        Results res =
            await Global.conn.query('select Cname,Cno,Ccredit from Course');
        for (var row in res) {
          allCourse.add(Course(row[0], row[1], row[2]));
        }
        List<Widget> courseOpts = List.generate(
          allCourse.length,
          (i) => SimpleDialogOption(
            onPressed: () async {
              await Global.conn.query(
                  'update SC set Cno = ? where Sno = ? and Cno = ?', [
                allCourse[i].no,
                items[index].stu_no,
                items[index].course_no
              ]);
              setState(() {
                items[index].course_name = allCourse[i].name;
                items[index].course_no = allCourse[i].no;
              });
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(allCourse[i].name),
            ),
          ),
        );
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text('请选择课程'),
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: courseOpts,
                  ),
                ),
              ],
            );
          },
        );
        return;
      default:
        return;
    }
  }

  void deleteStuCourse() async {
    for (int i = selected.length - 1; i >= 0; i--) {
      if (selected[i]) {
        await Global.conn.query('delete from SC where Sno = ? and Cno = ?',
            [items[i].stu_no, items[i].course_no]);
        selected[i] = false;
        setState(() {
          items.removeAt(i);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initcols();
    loadItems();
  }

  @override
  Widget build(BuildContext context) {
    var global = context.watch<CrossGlobalModel>();
    Widget datatable = SizedBox(
      height: 400, //457
      width: 784, //784
      child: SingleChildScrollView(
        child: DataTable(
          columns: cols,
          rows: List<DataRow>.generate(items.length, (index) {
            return DataRow(
              color: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                // All rows will have the same selected color.
                if (states.contains(MaterialState.selected)) {
                  return Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.08);
                }
                // Even rows will have a grey color.
                if (index.isEven) {
                  return Colors.grey.withOpacity(0.3);
                }
                return null; // Use default value for other states and odd rows.
              }),
              cells: <DataCell>[
                DataCell(
                  Text(items[index].stu_no),
                  onTap: () {
                    modifyStuCourse(index, 1);
                  },
                ),
                DataCell(
                  Text(items[index].stu_name),
                  onTap: () {
                    modifyStuCourse(index, 2);
                  },
                ),
                DataCell(
                  Text(items[index].course_no),
                  onTap: () {
                    modifyStuCourse(index, 3);
                  },
                ),
                DataCell(
                  Text(items[index].course_name),
                  onTap: () {
                    modifyStuCourse(index, 4);
                  },
                ),
              ],
              selected: selected[index],
              onSelectChanged: (bool? value) {
                setState(() {
                  selected[index] = value!;
                });
              },
            );
          }),
          horizontalMargin: 50,
          showCheckboxColumn: global.multi,
        ),
      ),
    );
    Widget delete = SizedBox(
      height: 57,
      width: 784,
      child: Expanded(
          child: ElevatedButton.icon(
        icon: Icon(Icons.delete),
        label: Text("删除"),
        onPressed: () {
          deleteStuCourse();
          global.switchMulti();
        },
      )),
    );
    List<Widget> colchild = [];
    colchild.add(datatable);
    if (global.multi) {
      colchild.add(delete);
    }
    List<Widget> stackchild = [];
    stackchild.add(
      Column(
        children: colchild,
      ),
    );
    Widget add = Positioned(
      right: 30,
      bottom: 30,
      child: FloatingActionButton(
        onPressed: () async {
          List<Student> allStus = [];
          List<Course> allCourse = [];
          Results res = await Global.conn
              .query('select Pno,Pname,Psex,Page from People where Prole = 1');
          for (var row in res) {
            allStus.add(Student(row[0], row[1], row[2], row[3]));
          }
          int? stuindex;
          int? courseindex;
          List<Widget> stuOpts = List.generate(
            allStus.length,
            (i) => SimpleDialogOption(
              onPressed: () async {
                stuindex = i;
                if (courseindex != null && stuindex != null) {
                  Global.conn.query('insert into SC(Sno,Cno) values(?,?)',
                      [allStus[stuindex!].no, allCourse[courseindex!].no]);
                  setState(() {
                    items.add(StuCourseItem(
                        allStus[stuindex!].no,
                        allStus[stuindex!].name,
                        allCourse[courseindex!].no,
                        allCourse[courseindex!].name));
                  });
                }
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(allStus[i].name),
              ),
            ),
          );
          res = await Global.conn.query('select Cname,Cno,Ccredit from Course');
          for (var row in res) {
            allCourse.add(Course(row[0], row[1], row[2]));
          }
          List<Widget> courseOpts = List.generate(
            allCourse.length,
            (i) => SimpleDialogOption(
              onPressed: () async {
                courseindex = i;
                if (courseindex != null && stuindex != null) {
                  Global.conn.query('insert into SC(Sno,Cno) values(?,?)',
                      [allStus[stuindex!].no, allCourse[courseindex!].no]);
                  setState(() {
                    items.add(StuCourseItem(
                        allStus[stuindex!].no,
                        allStus[stuindex!].name,
                        allCourse[courseindex!].no,
                        allCourse[courseindex!].name));
                  });
                }
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(allCourse[i].name),
              ),
            ),
          );
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text('请选择课程'),
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: courseOpts,
                    ),
                  ),
                ],
              );
            },
          );
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text('请选择学生'),
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: stuOpts,
                    ),
                  ),
                ],
              );
            },
          );
        },
        tooltip: "新增选课记录",
        child: Icon(Icons.add),
      ),
    );
    if (!global.multi) {
      stackchild.add(add);
    }
    return Stack(
      children: stackchild,
    );
  }
}
