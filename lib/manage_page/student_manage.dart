import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysql1/mysql1.dart';
import 'package:student_class_system/global.dart';
import 'package:student_class_system/cross_global.dart';
import 'package:student_class_system/basic_class/people.dart';

class StudentManagePage extends StatefulWidget {
  const StudentManagePage({super.key});

  @override
  State<StudentManagePage> createState() => _StudentManagePageState();
}

class _StudentManagePageState extends State<StudentManagePage> {
  List<String> colstr = ["编号", "姓名", "性别", "年龄"];
  List<DataColumn> cols = [];
  List<Student> stus = [];
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
        .query('select Pno,Pname,Psex,Page from People where Prole = 1');
    stus = [];
    for (var row in res) {
      stus.add(Student(row[0], row[1], row[2], row[3]));
      selected.add(false);
    }
    setState(() {});
  }

  void modifyStu(int index, int num) {
    String old = '';
    String hint = '';
    switch (num) {
      case 2:
        old = stus[index].name;
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
                        ['男', stus[index].no]);
                    setState(() {
                      stus[index].sex = '男';
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
                        ['女', stus[index].no]);
                    setState(() {
                      stus[index].sex = '女';
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
        old = stus[index].age.toString();
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
            [newname, stus[index].no]);
        stus[index].name = newname;
        break;
      case 4:
        String newage = controller.text;
        if (!Global.ValidAge(newage)) {
          break;
        }
        await Global.conn.query('update People set Page = ? where Pno = ?',
            [newage, stus[index].no]);
        stus[index].age = int.parse(newage);
        break;
    }
    setState(() {});
  }

  void deleteStu() async {
    for (int i = selected.length - 1; i >= 0; i--) {
      if (selected[i]) {
        await Global.conn
            .query('delete from People where Pno = ?', [stus[i].no]);
        selected[i] = false;
        setState(() {
          stus.removeAt(i);
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
            stus.length,
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
                  Text(stus[index].no),
                  onTap: () {
                    modifyStu(index, 1);
                  },
                ),
                DataCell(
                  Text(stus[index].name),
                  onTap: () {
                    modifyStu(index, 2);
                  },
                ),
                DataCell(
                  Text(stus[index].sex),
                  onTap: () {
                    modifyStu(index, 3);
                  },
                ),
                DataCell(
                  Text(stus[index].age.toString()),
                  onTap: () {
                    modifyStu(index, 4);
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
          deleteStu();
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
          await Navigator.pushNamed(context, 'add_stu');
          initrows();
        },
        tooltip: "添加学生",
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
