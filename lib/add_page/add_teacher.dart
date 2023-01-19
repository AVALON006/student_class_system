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

  void add(BuildContext context) async {
    String no = cs[0].text;
    String name = cs[1].text;
    String sex = cs[2].text;
    String age = cs[3].text;
    if (!await Global.ValidPeopleNo(no)) {
      Global.ShowAlert("添加失败", "和已有编号重复！", context);
      return;
    }
    if (!Global.ValidName(name)) {
      Global.ShowAlert("添加失败", "用户名应少于20个字符！", context);
      return;
    }
    if (!Global.ValidSex(sex)) {
      Global.ShowAlert("添加失败", "性别只能填男或女哦~", context);
      return;
    }
    if (!Global.ValidAge(age)) {
      Global.ShowAlert("添加失败", "请输入0~100的数字", context);
      return;
    }
    int newage = int.parse(age);
    await Global.conn.query(
        'insert into People values(?,?,?,?,?)', [no, name, sex, newage, 2]);
    Navigator.pop(context);
  }

  @override
  void initState() {
    focus = List.generate(colstr.length, (index) => FocusNode());
    cs = List.generate(colstr.length, (index) => TextEditingController());
    col.add(
      SizedBox(
        height: 60,
        child: Text(
          '新增教师信息',
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
        onEditingComplete: () => add(context),
      ),
    );
    col.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => add(context),
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
      appBar: AppBar(
        title: Text("添加教师信息"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: "返回",
        ),
      ),
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
