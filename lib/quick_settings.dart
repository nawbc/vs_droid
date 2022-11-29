import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:vs_droid/config_model.dart';
import 'package:vs_droid/terminal_page.dart';
import 'components/switch/switch.dart';
import 'droid_pty.dart';

class QuickSettings extends StatefulWidget {
  const QuickSettings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return QuickSettingsState();
  }
}

class QuickSettingsState extends State<QuickSettings> {
  VSDroidPty? _pty;
  late ConfigModel _cm;
  late bool _switch1;
  final TextEditingController _c1 = TextEditingController();
  final TextEditingController _c2 = TextEditingController();
  final FocusNode _f1 = FocusNode();
  final FocusNode _f2 = FocusNode();

  @override
  void initState() {
    super.initState();
    _switch1 = false;
    _f1.addListener(() {
      if (!_f1.hasFocus && mounted) {
        _cm.setInternalIP(_c1.text);
      }
    });
    _f2.addListener(() {
      if (!_f1.hasFocus && mounted) {}
      _cm.setServerPort(_c2.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cm = Provider.of<ConfigModel>(context);
    _c1.text = _cm.internalIP!;
    _c2.text = _cm.serverPort;
  }

  _shareCodeServer(bool value) async {
    _pty ??= VSDroidPty(_cm.termuxUsr.path);
    final addr = "${_cm.internalIP}:${_cm.serverPort}";
    if (value) {
      setState(() {
        _switch1 = true;
      });
      await _pty?.startCodeServer(name: _cm.currentRootfsId!, host: addr).catchError((err) {
        setState(() {
          _switch1 = false;
        });
      });
      Fluttertoast.showToast(msg: "VS Droid running on $addr");
    } else {
      setState(() {
        _switch1 = false;
      });
      _pty?.kill();
      _pty = null;
    }
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
              onChanged: _shareCodeServer,
              value: _switch1,
            ),
            subtitle: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
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
          InkWell(
            onTap: () async {},
            child: const ListTile(
              title: Text("Refresh Code Server", style: TextStyle(fontSize: 14)),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
              subtitle: Text("restart the code server when lost connection"),
            ),
          ),
        ],
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: Text(
          'Quick Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
          ),
        ),
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
