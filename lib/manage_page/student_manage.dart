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
    switch (num) {
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        break;
      default:
    }
  }

  void deleteStu() {}

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
          stus.length,
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
    );
    Widget delete = SizedBox(
      height: 57,
      width: 784,
      child: Expanded(
          child: ElevatedButton.icon(
        icon: Icon(Icons.delete),
        label: Text("删除"),
        onPressed: deleteStu,
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
