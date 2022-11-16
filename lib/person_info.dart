import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'global.dart';

class PersonInfoPage extends StatefulWidget {
  const PersonInfoPage({super.key});

  @override
  State<PersonInfoPage> createState() => _PersonInfoPageState();
}

class _PersonInfoPageState extends State<PersonInfoPage> {
  TextEditingController controller = TextEditingController();
  List<int> forbidnum = [0, 3, 5];
  List<String> perinfo = [];
  List<String> prefix = ['用户名', '姓名', '性别', '角色', '年龄', '编号'];
  List<String> hint = ['', '', '请输入男或女', '', '请输入0~100的数字', ''];
  //TODO 修改Person info部分
  void AddStuInfo() async {
    Results res = await Global.conn.query(
        'select Sname,Ssex,Sage from Student where '
        'Sno = ?',
        [Global.account!.no]);
    for (var row in res) {
      perinfo.add(row[0]);
      perinfo.add(row[1]);
      perinfo.add('学生');
      perinfo.add(row[2]);
      break;
    }
    perinfo.add(Global.account!.no);
  }

  void AddTeaInfo() async {
    Results res = await Global.conn.query(
        'select Tname,Tsex,Tage from Teacher where '
        'Tno = ?',
        [Global.account!.no]);
    for (var row in res) {
      perinfo.add(row[0]);
      perinfo.add(row[1]);
      perinfo.add('教师');
      perinfo.add(row[2]);
      break;
    }
    perinfo.add(Global.account!.no);
  }

  void save(int index) async {
    String text = controller.text;
    if (Global.account!.role == 0) {
      setState(() {
        perinfo[index] = text;
      });
      return;
    }
    switch (index) {
      case 1:
        //姓名
        Global.conn.query('update Student set Sname = ? where Sno = ?',
            [text, Global.account!.no]);
        setState(() {
          perinfo[1] = text;
        });
        break;
      case 2:
        //性别
        if (text.compareTo('男') != 0 || text.compareTo("女") != 0) {
          return;
        }
        Global.conn.query('update Student set Ssex = ? where Sno = ?',
            [text, Global.account!.no]);
        setState(() {
          perinfo[2] = text;
        });
        break;
      case 4:
        //年龄
        if (int.tryParse(text) == null) {
          return;
        } else {
          Global.conn.query('update Student set Sage = ? where Sno = ?',
              [int.parse(text), Global.account!.no]);
          setState(() {
            perinfo[3] = text;
          });
        }
        break;
    }
  }

  @override
  void initState() {
    perinfo.add(Global.account!.name);
    if (Global.account!.role == 0) {
      //系统管理员
      perinfo.add('管理员');
      perinfo.add('未知');
      perinfo.add('管理员');
      perinfo.add('未知');
      perinfo.add(Global.account!.no);
    } else if (Global.account!.role == 1) {
      //学生
      AddStuInfo();
    } else if (Global.account!.role == 2) {
      //老师
      AddTeaInfo();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("个人信息"),
      ),
      body: ListView.builder(
        itemCount: prefix.length * 2 + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index % 2 != 0) {
            return Divider(
              color: Colors.blue,
              height: 1,
            );
          } else {
            int i = (index / 2).floor().toInt();
            if (i == 0) {
              return Padding(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(),
                    ClipOval(
                      child: Container(
                        color: Colors.white,
                        width: 100,
                        height: 100,
                        child: Center(
                          child: Text(
                            Global.account!.name[0].toUpperCase(),
                            style: TextStyle(color: Colors.blue, fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(),
                  ],
                ),
              );
            }
            i = i - 1;
            return ListTile(
              tileColor: i.isEven ? Colors.grey.withOpacity(0.3) : Colors.white,
              title: Text(
                perinfo[i],
                textAlign: TextAlign.end,
              ),
              leading: Text(
                prefix[i],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              onTap: () {
                if (forbidnum.contains(i)) {
                  return;
                }
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    controller.clear();
                    return AlertDialog(
                      title: Text("修改" + prefix[i]),
                      content: TextField(
                        autofocus: true,
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: hint[i],
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              save(i);
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
              },
            );
          }
        },
      ),
    );
  }
}
