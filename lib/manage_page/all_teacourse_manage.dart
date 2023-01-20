import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'package:student_class_system/global.dart';
import 'package:student_class_system/cross_global.dart';
import 'package:student_class_system/basic_class/people.dart';

class AllTeaCourseManagePage extends StatefulWidget {
  const AllTeaCourseManagePage({super.key});

  @override
  State<AllTeaCourseManagePage> createState() => _AllTeaCourseManagePageState();
}

class _AllTeaCourseManagePageState extends State<AllTeaCourseManagePage> {
  List<String> colstr = ['课程编号', '课程名称', '任课教师', '学分'];
  List<DataColumn> cols = [];
  List<List<String>> tc = [];
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

  void initrows() async {
    Results res = await Global.conn
        .query('select c.Cno,Cname,Tno,Ccredit from Course c left join TC tc '
            'on tc.Cno = c.Cno');
    tc = [];
    for (var row in res) {
      List<String> tmp = [];
      for (var ele in row) {
        tmp.add(ele.toString());
      }
      Results teaName = await Global.conn.query(
          'select Pname from People '
          'where Pno = ?',
          [tmp[2]]);
      for (var name in teaName) {
        tmp[2] = name[0];
      }
      tc.add(tmp);
      selected.add(false);
    }
    setState(() {});
  }

  void modifyTeaCourse(int index, int num) async {
    String old = '';
    String hint = '';
    switch (num) {
      case 2:
        // 修改课程名称
        old = tc[index][1];
        break;
      case 3:
        List<Teacher> allTeas = [];
        Results res = await Global.conn
            .query('select Pno,Pname,Psex,Page from People where Prole = 2');
        for (var row in res) {
          allTeas.add(Teacher(row[0], row[1], row[2], row[3]));
        }
        List<Widget> teaOpts = List.generate(allTeas.length, (i) {
          return SimpleDialogOption(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(allTeas[i].name),
            ),
            onPressed: () async {
              String? tno;
              Results res = await Global.conn.query(
                  'select Pno from People where Pname = ?', [tc[index][2]]);
              for (var row in res) {
                tno = row[0];
                break;
              }
              if (tno != null) {
                await Global.conn.query(
                    'update TC set Tno = ? where Tno = ? and Cno = ?',
                    [allTeas[i].no, tno, tc[index][0]]);
              } else {
                await Global.conn.query('insert into TC(Tno,Cno) values(?,?)',
                    [allTeas[i].no, tc[index][0]]);
              }
              setState(() {
                tc[index][2] = allTeas[i].name;
              });
              Navigator.pop(context);
            },
          );
        });
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text('请选择任课教师'),
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: teaOpts,
                  ),
                ),
              ],
            );
          },
        );
        return;
      case 4:
        //修改课程学分
        old = tc[index][3];
        hint = '请输入0~10的数字';
        break;
      default:
        return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        controller.text = old;
        return AlertDialog(
          title: Text("修改" + colstr[num - 1]),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: hint,
            ),
            onEditingComplete: () {
              save(num, index);
              Navigator.pop(context);
            },
            controller: controller,
          ),
          actions: [
            TextButton(
                onPressed: () {
                  save(num, index);
                  Navigator.pop(context);
                },
                child: Text('保存')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('取消'))
          ],
        );
      },
    );
  }

  void save(int num, int index) async {
    switch (num) {
      case 2:
        String newname = controller.text;
        if (!await Global.ValidName(newname)) {
          break;
        }
        await Global.conn.query('update Course set Cname = ? where Cno = ?',
            [newname, tc[index][0]]);
        tc[index][1] = newname;
        break;
      case 4:
        String newcredit = controller.text;
        if (!Global.ValidCredit(newcredit)) {
          break;
        }
        await Global.conn.query('update Course set Ccredit = ? where Cno = ?',
            [newcredit, tc[index][0]]);
        tc[index][3] = newcredit;
        break;
    }
    setState(() {});
  }

  void deleteTeaCourse() async {
    for (int i = selected.length - 1; i >= 0; i--) {
      if (selected[i]) {
        String? tno;
        Results res = await Global.conn
            .query('select Pno from People where Pname = ?', [tc[i][2]]);
        for (var row in res) {
          tno = row[0];
          break;
        }
        await Global.conn
            .query('delete from TC where Tno = ? and Cno = ?', [tno, tc[i][0]]);
        selected[i] = false;
        setState(() {
          tc[i][2] = 'null';
        });
      }
    }
  }

  void deleteCourse() async {
    for (int i = selected.length - 1; i >= 0; i--) {
      if (selected[i]) {
        await Global.conn.query('delete from TC where Cno = ?', [tc[i][0]]);
        await Global.conn.query('delete from SC where Cno = ?', [tc[i][0]]);
        await Global.conn.query('delete from Course where Cno = ?', [tc[i][0]]);
        selected[i] = false;
        setState(() {
          tc.removeAt(i);
        });
      }
    }
  }

  @override
  void initState() {
    initcols();
    initrows();
    super.initState();
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
          rows: List<DataRow>.generate(
            tc.length,
            (int index) => DataRow(
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
                  Text(tc[index][0]),
                  onTap: () {
                    modifyTeaCourse(index, 1);
                  },
                ),
                DataCell(
                  Text(tc[index][1]),
                  onTap: () {
                    modifyTeaCourse(index, 2);
                  },
                ),
                DataCell(
                  Text(tc[index][2]),
                  onTap: () {
                    modifyTeaCourse(index, 3);
                  },
                ),
                DataCell(
                  Text(tc[index][3].toString()),
                  onTap: () {
                    modifyTeaCourse(index, 4);
                  },
                ),
              ],
              selected: selected[index],
              onSelectChanged: (bool? value) {
                setState(() {
                  selected[index] = value!;
                });
              },
            ),
          ),
          horizontalMargin: 50,
          showCheckboxColumn: global.multi,
        ),
      ),
    );
    Widget delete = SizedBox(
      height: 57,
      width: 784,
      child: Row(
        children: <Widget>[
          SizedBox(
            height: 57,
            width: 392,
            child: ElevatedButton.icon(
              icon: Icon(Icons.delete),
              label: Text("删除任课教师"),
              onPressed: () {
                deleteTeaCourse();
                global.switchMulti();
              },
            ),
          ),
          SizedBox(
            height: 57,
            width: 392,
            child: ElevatedButton.icon(
              icon: Icon(Icons.delete),
              label: Text("删除课程"),
              onPressed: () {
                deleteCourse();
                global.switchMulti();
              },
            ),
          ),
        ],
      ),
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
          await Navigator.pushNamed(context, 'add_tea_course');
          initrows();
        },
        tooltip: "新增教学课程",
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
