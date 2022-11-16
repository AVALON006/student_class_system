import 'package:flutter/material.dart';
import 'package:student_class_system/global.dart';

class AddTeacherPage extends StatefulWidget {
  const AddTeacherPage({super.key});

  @override
  State<AddTeacherPage> createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AddTeacherPage> {
  List<String> colstr = ["编号", "姓名", "性别", "年龄"];
  List<IconData> icons = [
    Icons.numbers,
    Icons.person,
    Icons.wc,
    Icons.child_care
  ];
  List<String> hint = ["", "", "男或女", ""];
  List<TextEditingController> cs = [];
  List<FocusNode> focus = [];
  List<Widget> col = [];

  Future<void> addTeaData(
      String no, String name, String sex, String age) async {
    if (await Global.ValidPeopleNo(no) &&
        Global.ValidName(name) &&
        Global.ValidSex(sex) &&
        Global.ValidAge(age)) {
      int newage = int.parse(age);
      await Global.conn.query(
          'insert into People values(?,?,?,?,?)', [no, name, sex, newage, 2]);
    }
  }

  @override
  void initState() {
    focus = List.generate(colstr.length, (index) => FocusNode());
    cs = List.generate(colstr.length, (index) => TextEditingController());
    col.add(
      SizedBox(
        height: 60,
        child: Text(
          '新增账户信息',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );
    col.addAll(
      List.generate(colstr.length - 1, (index) {
        return TextField(
          autofocus: true,
          controller: cs[index],
          decoration: InputDecoration(
            labelText: colstr[index],
            prefixIcon: Icon(icons[index]),
            hintText: hint[index],
          ),
          focusNode: focus[index],
          onEditingComplete: () =>
              FocusScope.of(context).requestFocus(focus[index + 1]),
        );
      }),
    );
    col.add(
      TextField(
        autofocus: true,
        controller: cs[colstr.length - 1],
        decoration: InputDecoration(
          labelText: colstr[colstr.length - 1],
          prefixIcon: Icon(icons[colstr.length - 1]),
          hintText: hint[colstr.length - 1],
        ),
        focusNode: focus[colstr.length - 1],
        onEditingComplete: () async {
          await addTeaData(cs[0].text, cs[1].text, cs[2].text, cs[3].text);
          Navigator.pop(context);
        },
      ),
    );
    col.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () async {
              await addTeaData(cs[0].text, cs[1].text, cs[2].text, cs[3].text);
              Navigator.pop(context);
            },
            child: Text(
              '保存',
            ),
          ),
          SizedBox(
            height: 100,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              '取消',
            ),
          ),
        ],
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("添加教师信息")),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: col,
          ),
        ),
      ),
    );
  }
}
