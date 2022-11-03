import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:vs_droid/config_model.dart';
import 'package:vs_droid/terminal_page.dart';
import 'components/switch/switch.dart';

class LeftQuickBar extends StatefulWidget {
  const LeftQuickBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LeftQuickBarState();
  }
}

class LeftQuickBarState extends State<LeftQuickBar> {
  late ConfigModel _cm;

  final TextEditingController _c1 = TextEditingController();
  final TextEditingController _c2 = TextEditingController();
  final FocusNode _f1 = FocusNode();
  final FocusNode _f2 = FocusNode();

  @override
  void initState() {
    super.initState();
    _f1.addListener(() {
      if (!_f1.hasFocus) {}
      setState(() {});
    });
    _f2.addListener(() {
      if (!_f1.hasFocus) {}
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cm = Provider.of<ConfigModel>(context);
    // _c1. = _cm.internalIP;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('RightQuickBoard Painted...');

    List<Widget> settings = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () async {
              await Navigator.of(context).push(
                CupertinoPageRoute<void>(
                  maintainState: false,
                  builder: (BuildContext context) {
                    return const TerminalPage();
                  },
                ),
              );
            },
            child: ListTile(
              trailing: SizedBox(
                height: 23,
                child: CupertinoButton.filled(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  onPressed: () async {
                    Fluttertoast.showToast(msg: "Coming soon");
                  },
                  child: Wrap(
                    children: const [
                      Text("Quake mode", style: TextStyle(fontSize: 12)),
                      Icon(UniconsLine.bolt, size: 14)
                    ],
                  ),
                ),
              ),
              title: const Text("Terminal View", style: TextStyle(fontSize: 14)),
              contentPadding: const EdgeInsets.only(left: 15, right: 25),
            ),
          ),
          ListTile(
            trailing: DroidSwitch(
              onChanged: (bool value) {},
              value: false,
            ),
            subtitle: Row(
              children: [
                const Text("Host: "),
                SizedBox(
                  width: 150,
                  height: 23,
                  child: CupertinoTextField(
                    focusNode: _f1,
                    padding: const EdgeInsets.only(top: 4, left: 5),
                    cursorHeight: 16,
                    controller: _c1,
                  ),
                ),
                const SizedBox(width: 10),
                const Text("Port: "),
                SizedBox(
                  width: 60,
                  height: 23,
                  child: CupertinoTextField(
                    focusNode: _f2,
                    padding: const EdgeInsets.only(top: 4, left: 5),
                    cursorHeight: 16,
                    controller: _c2,
                  ),
                ),
              ],
            ),
            title: const Text("Allow Lan", style: TextStyle(fontSize: 14)),
            contentPadding: const EdgeInsets.only(left: 15, right: 25),
          ),
        ],
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: Text(
          'Quick Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        // backgroundColor: themeData.navBackgroundColor,
        border: null,
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: settings.length,
            itemBuilder: (BuildContext context, int index) {
              return settings[index];
            },
          ),
        ),
      ),
    );
  }
}
