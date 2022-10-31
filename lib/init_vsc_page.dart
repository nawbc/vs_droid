import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:vs_droid/constant.dart';
import 'package:vs_droid/distros/alpine.dart';
import 'package:xterm/core.dart';
import 'package:xterm/ui.dart';
import 'components/list.dart';
import 'components/menu.dart';
import 'config_model.dart';
import 'droid_pty.dart';
import 'theme.dart';
import 'utils.dart';

class InitVscPage extends StatefulWidget {
  const InitVscPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InitVscPageState();
  }
}

class _InitVscPageState extends State<InitVscPage> {
  late final Pty _pty;
  late ConfigModel _cm;
  late PlatformFile _rootfsFile;
  late List<Map<String, String>> _supportRootfsList;
  late List<String> _mirrorList;
  late String _validMirrorName;
  late String _rootfsPath;

  Map<String, String> _rootfsSelection = {
    "label": "Alpine Linux(built-in)",
    "value": "alpine",
  };

  final terminal = Terminal(
    maxLines: 999999,
  );

  final terminalController = TerminalController();

  @override
  void initState() {
    super.initState();
    _supportRootfsList = ROOTFS_DOWNLOAD_CN;
    _validMirrorName = "tsinghua";
    _mirrorList = ALPINE_MIRROR;
    _rootfsPath = "alpine";

    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) _startPty();
      },
    );
  }

  void _startPty() {
    _pty = Pty.start(
      "sh",
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
      environment: {"TERM": "xterm-256color"},
    );

    _pty.output.cast<List<int>>().transform(const Utf8Decoder()).listen((data) {
      terminal.write(data);
    });

    _pty.exitCode.then((code) {
      terminal.write('the process exited with exit code $code');
    });

    terminal.onResize = (w, h, pw, ph) {
      _pty.resize(h, w);
    };
  }

  void _setMirror() {
    List<String> list;
    switch (_rootfsSelection["value"]) {
      case "alpine":
        list = ALPINE_MIRROR;
        break;
      default:
        list = ALPINE_MIRROR;
        break;
    }

    setState(() {
      _mirrorList = list;
    });
  }

  Widget _selectRootfs(String name) {
    return FocusedMenuHolder(
      menuWidth: 200,
      menuItemExtent: 35,
      offsetY: 10,
      duration: const Duration(milliseconds: 100),
      maskColor: const Color.fromARGB(30, 116, 116, 116),
      menuItems: _supportRootfsList
          .map(
            (e) => FocusedMenuItem(
              title: Text(e["label"]!, style: const TextStyle(fontSize: 14)),
              onPressed: () {
                setState(() {
                  _rootfsSelection = e;
                });
              },
            ),
          )
          .toList(),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _selectMirror(String name) {
    return FocusedMenuHolder(
      menuWidth: 200,
      menuItemExtent: 35,
      offsetY: 10,
      duration: const Duration(milliseconds: 100),
      maskColor: const Color.fromARGB(30, 116, 116, 116),
      menuItems: _mirrorList
          .map(
            (e) => FocusedMenuItem(
              title: Text(e, style: const TextStyle(fontSize: 14)),
              onPressed: () {
                setState(() {
                  _validMirrorName = e;
                });
              },
            ),
          )
          .toList(),
      child: Text(name, style: const TextStyle(fontSize: 14)),
    );
  }

  late DroidPty pty1;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cm = Provider.of<ConfigModel>(context);

    pty1 = DroidPty(context);

    pty1.output.cast<List<int>>().transform(const Utf8Decoder()).listen((data) {
      log(data);
    });

    _pseudoWrite("Linux runtime is not installed");
    _pseudoWrite("Setting required options and tapping install button to init environment...");
  }

  Future<void> _createRootfsSymlink() async {
    File symLinks = File("${_cm.termuxUsrDir.path}/SYMLINKS.txt");
    Map map = {};

    await symLinks.openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach(
      (line) async {
        final pair = line.split("←");
        final linkPath = p.normalize(p.join(_cm.termuxUsrDir.path, pair.elementAt(1)));

        var linkDir = Directory(p.dirname(linkPath));

        if (!linkDir.existsSync()) {
          linkDir.createSync(recursive: true);
        }

        /// Change cwd to link directory
        Directory.current = linkDir;
        File target = File(p.normalize(p.join(Directory.current.path, pair.elementAt(0))));

        if (target.existsSync()) {
          await Link(linkPath).create(target.path, recursive: true);
          _pseudoWrite("${target.path}->$linkPath");
        } else {
          map[linkPath] = target.path;
        }
      },
    );

    await for (var item in Stream.fromIterable(map.entries.toList())) {
      if (File(item.value).existsSync()) {
        await Link(item.key).create(item.value, recursive: true);
        _pseudoWrite("${item.value}->${item.key}");
        map.remove(item.key);
      }
    }

    /// Reset current directory
    Directory.current = Directory("/");
  }

  _pseudoWrite(String data) {
    terminal.write("\r\n");
    terminal.write(r"$: " + data);
  }

  Future<void> _extractAssets() async {
    await _cm.termuxHomeDir.create(recursive: true);
    await chmod(_cm.termuxHomeDir.path, "755").catchError((err) {});
    _pseudoWrite("Create home directory successfully");

    _pseudoWrite("Start extract assets from bundle...");
    var a = await rootBundle.load("assets/bootstrap-aarch64-$BOOTSTRAP_SEMVER.zip");
    final b = InputStream(a);
    final archive = ZipDecoder().decodeBuffer(b);
    extractArchiveToDisk(archive, _cm.termuxUsrDir.path);
    await chmod(_cm.termuxUsrDir.path, "755").catchError((err) {});
    _pseudoWrite("Extract bootstrap-aarch64 successfully...");
  }

  Future<void> _prepareEnv() async {
    if (await _cm.termuxUsrDir.exists()) {
      return;
    }
    await _extractAssets().catchError((err) {
      _pseudoWrite("Extract assets failed");
      _pseudoWrite(err);
    });
    _pseudoWrite("Start linking symbolic");
    await _createRootfsSymlink().catchError((err) {
      _pseudoWrite("Linking failed...");
      _pseudoWrite(err);
    });
    _pseudoWrite("Linking successfully...");
  }

  Future<void> _chooseImg() async {
    if (_rootfsSelection["value"] == "alpine") {
      Fluttertoast.showToast(msg: "Alpine Linux is built-in");
      return;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gz', 'xz'],
    );
    if (result != null) {
      setState(() {
        _rootfsFile = result.files.single;
        _rootfsPath = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: TerminalView(
                  terminal,
                  controller: terminalController,
                  autofocus: true,
                  padding: const EdgeInsets.only(right: 50),
                  theme: terminalTheme,
                  alwaysShowCursor: true,
                  backgroundOpacity: 0,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 30,
                            child: CupertinoButton.filled(
                              borderRadius: const BorderRadius.all(Radius.circular(4)),
                              padding: const EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 5),
                              onPressed: () async {
                                pty1.exec("pwd");
                              },
                              child: const Text('Install', style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListItem(
                        require: true,
                        dotted: true,
                        leading: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(_rootfsSelection["label"]!, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 10),
                            _rootfsSelection["value"] != "alpine"
                                ? SizedBox(
                                    height: 20,
                                    child: CupertinoButton.filled(
                                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                                      padding: const EdgeInsets.only(left: 10, right: 10),
                                      onPressed: () async {
                                        await launchUrl(Uri.parse(_rootfsSelection["url"]!),
                                            mode: LaunchMode.externalApplication);
                                      },
                                      child: const Text('download', style: TextStyle(fontSize: 15)),
                                    ),
                                  )
                                : Container(),
                            const SizedBox(width: 10),
                          ],
                        ),
                        trailing: CupertinoButton(
                          onPressed: _chooseImg,
                          child: _selectRootfs("Select rootfs"),
                        ),
                      ),
                      ListItem(
                        require: true,
                        dotted: true,
                        leading: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_rootfsPath, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                        trailing: CupertinoButton(
                          onPressed: _chooseImg,
                          child: const Text('Pick file', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      ListItem(
                        dotted: true,
                        leading: Text(_validMirrorName, style: const TextStyle(fontSize: 14)),
                        sub: const Text("Recommend for Chinese (推荐中国地区)",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: CupertinoButton(
                          onPressed: _setMirror,
                          child: _selectMirror("Select termux mirror"),
                        ),
                      ),
                      ListItem(
                        dotted: true,
                        leading: Text(_validMirrorName, style: const TextStyle(fontSize: 14)),
                        sub: const Text("Recommend for Chinese (推荐中国地区)",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: CupertinoButton(
                          onPressed: _setMirror,
                          child: _selectMirror("Select rootfs mirror"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
