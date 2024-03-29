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
  List<bool> showErr = List.generate(6, ((index) => false));

  void AddStuInfo() async {
    Results res = await Global.conn.query(
        'select Pname,Psex,Page from People where '
        'Pno = ? and Prole = 1',
        [Global.account!.no]);
    for (var row in res) {
      perinfo.add(row[0]);
      perinfo.add(row[1]);
      perinfo.add('学生');
      perinfo.add(row[2].toString());
      break;
    }
    perinfo.add(Global.account!.no);
    setState(() {});
  }

  void AddTeaInfo() async {
    Results res = await Global.conn.query(
        'select Pname,Psex,Page from People where '
        'Pno = ? and Prole = 2',
        [Global.account!.no]);
    for (var row in res) {
      perinfo.add(row[0]);
      perinfo.add(row[1]);
      perinfo.add('教师');
      perinfo.add(row[2].toString());
      break;
    }
    perinfo.add(Global.account!.no);
    setState(() {});
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
        Global.conn.query('update People set Pname = ? where Pno = ?',
            [text, Global.account!.no]);
        setState(() {
          perinfo[1] = text;
        });
        break;
      case 4:
        //年龄
        if (!Global.ValidAge(text)) {
          showErr[4] = true;
          return;
        } else {
          Global.conn.query('update People set Page = ? where Pno = ?',
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
    Widget body = Global.waitMySql;
    if (perinfo.length == prefix.length) {
      body = ListView.builder(
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
            if (i > perinfo.length) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              );
            }
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
                if (Global.account!.no.compareTo('0') == 0) {
                  return;
                }
                showErr[i] = false;
                if (i == 2) {
                  //性别
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: const Text('请选择性别'),
                        children: <Widget>[
                          SimpleDialogOption(
                            onPressed: () async {
                              Global.conn.query(
                                  'update People set Psex = ? where Pno = ?',
                                  ['男', Global.account!.no]);
                              setState(() {
                                perinfo[2] = '男';
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
                              Global.conn.query(
                                  'update People set Psex = ? where Pno = ?',
                                  ['女', Global.account!.no]);
                              setState(() {
                                perinfo[2] = '女';
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
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      controller.clear();
                      return AlertDialog(
                        title: Text("修改" + prefix[i]),
                        content: TextField(
                          autofocus: true,
                          controller: controller,
                          onEditingComplete: () {
                            save(i);
                            Navigator.pop(context);
                          },
                          decoration: InputDecoration(
                            hintText: hint[i],
                            errorText: showErr[i] ? hint[i] : null,
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
                  ).then((value) {
                    if (showErr[i] == true) {
                      Global.ShowAlert("修改失败", "${hint[i]}！", context);
                    }
                  });
                }
              },
            );
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("个人信息"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: "返回",
        ),
      ),
      body: body,
    );
  }
}
