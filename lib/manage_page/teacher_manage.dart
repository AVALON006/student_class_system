import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysql1/mysql1.dart';
import 'package:student_class_system/global.dart';
import 'package:student_class_system/cross_global.dart';
import 'package:student_class_system/basic_class/people.dart';

class TeacherManagePage extends StatefulWidget {
  const TeacherManagePage({super.key});

  @override
  State<TeacherManagePage> createState() => _TeacherManagePageState();
}

class _TeacherManagePageState extends State<TeacherManagePage> {
  List<String> colstr = ["编号", "姓名", "性别", "年龄"];
  List<DataColumn> cols = [];
  List<Teacher> teas = [];
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
        .query('select Pno,Pname,Psex,Page from People where Prole = 2');
    teas = [];
    for (var row in res) {
      teas.add(Teacher(row[0], row[1], row[2], row[3]));
      selected.add(false);
    }
    setState(() {});
  }

  void modifyTea(int index, int num) {
    String old = '';
    String hint = '';
    switch (num) {
      case 2:
        old = teas[index].name;
        break;
      case 3:
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text('请选择性别'),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () async {
                    await Global.conn.query(
                        'update People set Psex = ? where Pno = ?',
                        ['男', teas[index].no]);
                    setState(() {
                      teas[index].sex = '男';
                    });
                    Navigator.pop(context, '男');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Text('男'),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () async {
                    await Global.conn.query(
                        'update People set Psex = ? where Pno = ?',
                        ['女', teas[index].no]);
                    setState(() {
                      teas[index].sex = '女';
                    });
                    Navigator.pop(context, '女');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Text('女'),
                  ),
                ),
              ],
            );
          },
        );
        return;
      case 4:
        old = teas[index].age.toString();
        hint = '请输入0~100的数字';
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
        await Global.conn.query('update People set Pname = ? where Pno = ?',
            [newname, teas[index].no]);
        teas[index].name = newname;
        break;
      case 4:
        String newage = controller.text;
        if (!Global.ValidAge(newage)) {
          break;
        }
        await Global.conn.query('update People set Page = ? where Pno = ?',
            [newage, teas[index].no]);
        teas[index].age = int.parse(newage);
        break;
    }
    setState(() {});
  }

  void deleteTea() async {
    for (int i = 0; i < selected.length; i++) {
      if (selected[i]) {
        await Global.conn
            .query('delete from People where Pno = ?', [teas[i].no]);
        selected[i] = false;
        setState(() {
          teas.removeAt(i);
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
      child: DataTable(
        columns: cols,
        rows: List<DataRow>.generate(
          teas.length,
          (int index) => DataRow(
            color: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              // All rows will have the same selected color.
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).colorScheme.primary.withOpacity(0.08);
              }
              // Even rows will have a grey color.
              if (index.isEven) {
                return Colors.grey.withOpacity(0.3);
              }
              return null; // Use default value for other states and odd rows.
            }),
            cells: <DataCell>[
              DataCell(
                Text(teas[index].no),
                onTap: () {
                  modifyTea(index, 1);
                },
              ),
              DataCell(
                Text(teas[index].name),
                onTap: () {
                  modifyTea(index, 2);
                },
              ),
              DataCell(
                Text(teas[index].sex),
                onTap: () {
                  modifyTea(index, 3);
                },
              ),
              DataCell(
                Text(teas[index].age.toString()),
                onTap: () {
                  modifyTea(index, 4);
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
    );
    Widget delete = SizedBox(
      height: 57,
      width: 784,
      child: Expanded(
          child: ElevatedButton.icon(
        icon: Icon(Icons.delete),
        label: Text("删除"),
        onPressed: deleteTea,
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
          await Navigator.pushNamed(context, 'add_tea');
          initrows();
        },
        tooltip: "添加教师信息",
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
