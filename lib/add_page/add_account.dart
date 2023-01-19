import 'package:flutter/material.dart';
import 'package:student_class_system/global.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({super.key});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  List<String> colstr = ["用户名", "密码", "角色", "编号"];
  List<IconData> icons = [
    Icons.person,
    Icons.lock,
    Icons.groups,
    Icons.numbers
  ];
  List<String> hint = ["", "", "0表示管理员1表示学生2表示老师", ""];
  List<TextEditingController> cs = [];
  List<FocusNode> focus = [];
  List<Widget> col = [];

  void add(BuildContext context) async {
    if (!await Global.ValidAccName(cs[0].text)) {
      //验证正确的用户名
      Global.ShowAlert("添加失败", "用户名应不能和已有用户名重复！", context);
      return;
    }
    if (!Global.ValidPass(cs[1].text)) {
      Global.ShowAlert("添加失败", "密码应不超过20个字符！", context);
      return;
    }
    if (!Global.ValidRole(cs[2].text)) {
      Global.ShowAlert("添加失败", "角色信息填写错误！", context);
      return;
    }
    if (!await Global.ValidAccNoRole(cs[3].text, cs[2].text)) {
      Global.ShowAlert("添加失败", "角色与编号不对应或缺少与该编号对应的人", context);
      return;
    }
    int newrole = int.parse(cs[2].text);
    await Global.conn.query('insert into Account values(?,?,?,?)',
        [cs[0].text, cs[1].text, newrole, cs[3].text]);

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
    col.addAll(List<Widget>.generate(colstr.length - 1, (index) {
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
    }));
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
        title: Text("新建账户"),
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
