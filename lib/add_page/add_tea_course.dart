import 'package:flutter/material.dart';
import 'package:student_class_system/global.dart';

class AddTeaCoursePage extends StatefulWidget {
  const AddTeaCoursePage({super.key});

  @override
  State<AddTeaCoursePage> createState() => _AddTeaCoursePageState();
}

class _AddTeaCoursePageState extends State<AddTeaCoursePage> {
  List<String> colstr = ['课程编号', '课程名称', '学分'];
  List<IconData> icons = [Icons.numbers, Icons.edit, Icons.grade];
  List<String> hint = ["", "", "0~10"];
  List<TextEditingController> cs = [];
  List<FocusNode> focus = [];
  List<Widget> col = [];

  Future<bool> addTeaCourseData(String no, String name, String credit) async {
    if (await Global.ValidCourseNo(no) &&
        Global.ValidName(name) &&
        Global.ValidCredit(credit)) {
      int newcredit = int.parse(credit);
      await Global.conn
          .query('insert into Course values(?,?,?)', [no, name, newcredit]);
      await Global.conn
          .query('insert into TC values(?,?)', [Global.account!.no, no]);
      return true;
    } else {
      return false;
    }
  }

  Future<void> add(BuildContext context) async {
    bool success = await addTeaCourseData(cs[0].text, cs[1].text, cs[2].text);
    if (success) {
      Navigator.pop(context);
    } else {
      Global.ShowAlert("添加失败", "格式有误！", context);
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
          '新增教学课程信息',
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
        title: Text("添加教学课程"),
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
