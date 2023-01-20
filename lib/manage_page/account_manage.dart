import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'package:student_class_system/cross_global.dart';
import 'package:student_class_system/basic_class/account.dart';
import 'package:student_class_system/global.dart';

class AccountManagePage extends StatefulWidget {
  const AccountManagePage({super.key});

  @override
  State<AccountManagePage> createState() => _AccountManagePageState();
}

class _AccountManagePageState extends State<AccountManagePage> {
  List<Account> accs = [];
  List<String> colstr = ["用户名", "密码", "角色", "编号"];
  List<DataColumn> cols = [];
  List<bool> selected = [];

  TextEditingController controller = TextEditingController();

  void initcols() {
    for (var str in colstr) {
      cols.add(
        DataColumn(
          label: Text(
            str,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  void initrows() async {
    accs = [];
    Results res =
        await Global.conn.query('select Aname,Apass,Arole,Ano from Account');
    for (var row in res) {
      accs.add(Account(row[0], row[1], row[2], row[3]));
      selected.add(false);
    }
    setState(() {});
  }

  void deleteAcc() async {
    for (int i = selected.length - 1; i >= 0; i--) {
      if (selected[i]) {
        await Global.conn
            .query('delete from Account where Aname = ?', [accs[i].name]);
        selected[i] = false;
        setState(() {
          accs.removeAt(i);
        });
      }
    }
  }

  void save(int num, int index) async {
    switch (num) {
      case 1:
        String newname = controller.text;
        if (!await Global.ValidAccName(newname)) {
          break;
        }
        await Global.conn.query('update Account set Aname = ? where Aname = ?',
            [newname, accs[index].name]);
        accs[index].name = newname;
        Global.account!.name = newname;
        break;
      case 2:
        String newpass = controller.text;
        if (!Global.ValidPass(newpass)) {
          break;
        }
        await Global.conn.query('update Account set Apass = ? where Aname = ?',
            [newpass, accs[index].name]);
        accs[index].pass = newpass;
        Global.account!.pass = newpass;
        break;
      case 3:
        String newrolestr = controller.text;
        if (!Global.ValidRole(newrolestr)) {
          break;
        }
        int newrole = int.parse(newrolestr);
        await Global.conn.query('update Account set Arole = ? where Aname = ?',
            [newrole, accs[index].name]);
        accs[index].role = newrole;
        break;
      case 4:
        String newno = controller.text;
        if (!await Global.ValidAccNoRole(
            newno, Global.role[accs[index].role])) {
          break;
        }
        await Global.conn.query('update Account set Ano = ? where Aname = ?',
            [newno, accs[index].name]);
        accs[index].no = newno;
        Global.account!.no = newno;
        break;
    }
    setState(() {});
  }

  void modifyAcc(int index, int num) {
    String hint = '';
    switch (num) {
      case 1:
        hint = accs[index].name;
        break;
      case 2:
        hint = accs[index].pass;
        break;
      default:
        return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        controller.text = hint;
        return AlertDialog(
          title: Text("修改" + colstr[num - 1]),
          content: TextField(
            autofocus: true,
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
            accs.length,
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
                  Text(accs[index].name),
                  onTap: () {
                    modifyAcc(index, 1);
                  },
                ),
                DataCell(
                  Text(accs[index].pass),
                  onTap: () {
                    modifyAcc(index, 2);
                  },
                ),
                DataCell(
                  Text(Global.role[accs[index].role]),
                  onTap: () {
                    modifyAcc(index, 3);
                  },
                ),
                DataCell(
                  Text(accs[index].no),
                  onTap: () {
                    modifyAcc(index, 4);
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
      child: Expanded(
          child: ElevatedButton.icon(
        icon: Icon(Icons.delete),
        label: Text("删除"),
        onPressed: () {
          deleteAcc();
          global.switchMulti();
        },
      )),
    );
    List<Widget> colchildren = [];
    colchildren.add(datatable);
    if (global.multi) {
      colchildren.add(delete);
    }
    List<Widget> stackchildren = [
      Column(
        children: colchildren,
      ),
    ];
    Widget add = Positioned(
      right: 30,
      bottom: 30,
      child: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, 'add_acc');
          initrows();
        },
        tooltip: "新建账户",
        child: Icon(Icons.add),
      ),
    );
    if (!global.multi) {
      stackchildren.add(add);
    }
    return Stack(
      children: stackchildren,
    );
  }
}
