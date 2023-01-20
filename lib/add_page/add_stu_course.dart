import 'package:flutter/material.dart';
import 'package:student_class_system/global.dart';

class AddStuCoursePage extends StatefulWidget {
  const AddStuCoursePage({super.key});

  @override
  State<AddStuCoursePage> createState() => _AddStuCoursePageState();
}

class _AddStuCoursePageState extends State<AddStuCoursePage> {
  List<String> colstr = ['学号', '课程号', '成绩'];
  List<IconData> icons = [Icons.numbers, Icons.numbers, Icons.grade];
  List<String> hint = ["", "", ""];
  List<TextEditingController> cs = [];
  List<FocusNode> focus = [];
  List<Widget> col = [];

  Future<bool> addStuCourseData(String Sno, String Cno, String grade) async {
    if (await Global.ValidCourseNo(Cno) &&
        await Global.ValidPeopleNo(Sno) &&
        int.tryParse(grade) != null) {
      int newcredit = int.parse(grade);
      await Global.conn
          .query('insert into SC values(?,?,?)', [Sno, Cno, grade]);
      return true;
    } else {
      return false;
    }
  }

  Future<void> add(BuildContext context) async {
    bool success = await addStuCourseData(cs[0].text, cs[1].text, cs[2].text);
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
          '新增学生选课信息',
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
      appBar: AppBar(title: Text("添加学生选课信息")),
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
