import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:variable_app_icon/variable_app_icon.dart';
import 'package:vs_droid/config_model.dart';
import 'package:vs_droid/init_vsc_page.dart';
import 'package:vs_droid/terminal_page.dart';
import 'components/switch/switch.dart';
import 'droid_pty.dart';
import 'theme.dart';
import 'theme_model.dart';

class ImageItem {
  final dynamic value;
  final Image image;

  ImageItem({required this.value, required this.image});
}

class ImageSelect extends StatelessWidget {
  final Function(dynamic value) onChange;
  final List<ImageItem> images;
  final int defaultIndex;

  const ImageSelect({
    Key? key,
    required this.images,
    required this.onChange,
    this.defaultIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int active = defaultIndex;
    ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
    DroidTheme themeData = themeModel.themeData;

    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: images
            .asMap()
            .map(
              (key, el) => MapEntry(
                key,
                GestureDetector(
                  onTap: () {
                    setState(() {
                      active = key;
                    });
                    onChange(el.value);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    decoration: active == key
                        ? BoxDecoration(
                            boxShadow: [
                              BoxShadow(spreadRadius: -1, color: themeData.primaryColor),
                            ],
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                          )
                        : null,
                    child: el.image,
                  ),
                ),
              ),
            )
            .values
            .toList(),
      );
    });
  }
}

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
    _c1.text = _cm.internalIP;
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
                  child: const Wrap(
                    children: [Text("Quake mode", style: TextStyle(fontSize: 12)), Icon(UniconsLine.bolt, size: 14)],
                  ),
                ),
              ),
              title: const Text("Terminal", style: TextStyle(fontSize: 14)),
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
          ListTile(
            trailing: ImageSelect(
              defaultIndex: _cm.appIcon == "appicon.DEFAULT" ? 0 : 1,
              onChange: (val) async {
                await VariableAppIcon.changeAppIcon(androidIconId: val);
                _cm.setAppIcon(val);
              },
              images: [
                ImageItem(
                  value: 'appicon.DEFAULT',
                  image: Image.asset(
                    'assets/ic_launcher.png',
                    width: 35,
                  ),
                ),
                ImageItem(
                  value: 'appicon.VSCODE',
                  image: Image.asset(
                    'assets/ic_launcher1.png',
                    width: 35,
                  ),
                ),
              ],
            ),
            title: const Text("Change App Icon", style: TextStyle(fontSize: 14)),
            contentPadding: const EdgeInsets.only(left: 15, right: 25),
          ),
          InkWell(
            onTap: () async {
              await Navigator.of(context).push(
                CupertinoPageRoute<void>(
                  maintainState: false,
                  builder: (BuildContext context) {
                    return const InitVscPage();
                  },
                ),
              );
            },
            child: const ListTile(
              title: Text("Installation Page", style: TextStyle(fontSize: 14, color: Colors.red)),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
              subtitle: Text("Re-install envirenment"),
            ),
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
        border: null,
      ),
      child: Material(
        child: Container(
          color: Colors.white,
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
      ),
    );
  }
}
