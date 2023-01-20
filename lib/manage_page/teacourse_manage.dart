import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'package:student_class_system/global.dart';
import 'package:student_class_system/cross_global.dart';

class TeaCourseManagePage extends StatefulWidget {
  const TeaCourseManagePage({super.key});

  @override
  State<TeaCourseManagePage> createState() => _TeaCourseManagePageState();
}

class _TeaCourseManagePageState extends State<TeaCourseManagePage> {
  List<String> colstr = ['课程编号', '课程名称', '学分'];
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
    Results res = await Global.conn.query(
        'select tc.Cno,Cname,Ccredit from Course c,TC tc '
        'where Tno = ? and c.Cno=tc.Cno',
        [Global.account!.no]);
    tc = [];
    for (var row in res) {
      List<String> tmp = [];
      for (var ele in row) {
        tmp.add(ele.toString());
      }
      tc.add(tmp);
      selected.add(false);
    }
    setState(() {});
  }

  void modifyTeaCourse(int index, int num) {
    String old = '';
    String hint = '';
    switch (num) {
      case 2:
        // 修改课程名称
        old = tc[index][1];
        break;
      case 3:
        //修改课程学分
        old = tc[index][2];
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
      case 3:
        String newcredit = controller.text;
        if (!Global.ValidCredit(newcredit)) {
          break;
        }
        await Global.conn.query('update Course set Ccredit = ? where Cno = ?',
            [newcredit, tc[index][0]]);
        tc[index][2] = newcredit;
        break;
    }
    setState(() {});
  }

  void deleteTeaCourse() async {
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
                  Text(tc[index][2].toString()),
                  onTap: () {
                    modifyTeaCourse(index, 3);
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
      child: ElevatedButton.icon(
        icon: Icon(Icons.delete),
        label: Text("删除"),
        onPressed: () {
          deleteTeaCourse();
          global.switchMulti();
        },
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
