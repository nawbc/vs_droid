import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vs_droid/distros/alpine.dart';
import 'package:xterm/core.dart';
import 'package:xterm/ui.dart';
import 'components/list.dart';
import 'components/menu.dart';
import 'config_model.dart';
import 'droid_pty.dart';
import 'utils.dart';

const terminalTheme = TerminalTheme(
  cursor: Color.fromARGB(255, 0, 148, 12),
  selection: Color(0XFFFFFF40),
  foreground: Color.fromARGB(255, 66, 66, 66),
  background: Color(0XFF1E1E1E),
  black: Color(0XFF000000),
  red: Color(0XFFCD3131),
  green: Color(0XFF0DBC79),
  yellow: Color(0XFFE5E510),
  blue: Color(0XFF2472C8),
  magenta: Color(0XFFBC3FBC),
  cyan: Color(0XFF11A8CD),
  white: Color(0XFFE5E5E5),
  brightBlack: Color(0XFF666666),
  brightRed: Color(0XFFF14C4C),
  brightGreen: Color(0XFF23D18B),
  brightYellow: Color(0XFFF5F543),
  brightBlue: Color(0XFF3B8EEA),
  brightMagenta: Color(0XFFD670D6),
  brightCyan: Color(0XFF29B8DB),
  brightWhite: Color(0XFFFFFFFF),
  searchHitBackground: Color(0XFFFFFF2B),
  searchHitBackgroundCurrent: Color(0XFF31FF26),
  searchHitForeground: Color(0XFF000000),
);

class InitVscPage extends StatefulWidget {
  const InitVscPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InitVscPageState();
  }
}

const rootfsCN = [
  {
    "label": "Alpine Linux(default)",
    "value": "alpine",
  },
  {
    "label": "Manjaro(coming soon)",
    "value": "manjaro",
    "url": "https://github.com/manjaro-arm/rootfs/releases",
  },
  {
    "label": "Arch Linux(coming soon)",
    "value": "arch",
    "url": "",
  },
  {
    "label": "Debian(coming soon)",
    "value": "debian",
    "url": "",
  },
  {
    "label": "Fedora(coming soon)",
    "value": "fedora",
    "url": "",
  },
  {
    "label": "OpenSUSE(coming soon)",
    "value": "openSUSE",
    "url": "",
  },
  {
    "label": "Ubuntu(coming soon)",
    "value": "ubuntu",
    "url": "",
  },
];

class _InitVscPageState extends State<InitVscPage> {
  late final Pty _pty;
  late ConfigModel _cm;
  late PlatformFile _rootfsFile;
  late final List<Map<String, String>> _supportRootfsList = rootfsCN;
  late List<String> _mirrorList = alpineMirror;
  String selectMirrorName = "tsinghua";
  String? _rootfsPath;

  Map<String, String> _rootfsSelection = {
    "label": "Alpine Linux(built-in)",
    "value": "alpine",
  };

  @override
  void initState() {
    super.initState();

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
        list = alpineMirror;
        break;
      default:
        list = alpineMirror;
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
      child: Text(name, style: const TextStyle(fontSize: 14, color: Color(0xFF007AFF))),
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
                  selectMirrorName = e;
                });
              },
            ),
          )
          .toList(),
      child: Text(name, style: const TextStyle(fontSize: 14, color: Color(0xFF007AFF))),
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
    var a = await rootBundle.load("assets/bootstrap-aarch64.zip");
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

  final terminal = Terminal(
    maxLines: 999999,
  );

  final terminalController = TerminalController();

  Future<void> _chooseImg() async {
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
                      leading: _rootfsPath != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_rootfsPath!, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _rootfsPath = null;
                                    });
                                  },
                                  child: Icon(UniconsLine.times_circle, size: 16, color: Colors.red[400]),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _selectRootfs(_rootfsSelection["label"]!),
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
                        child: const Text('Pick file', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                    ListItem(
                      dotted: true,
                      leading:
                          Text('$selectMirrorName  -  ecommend for Chinese (推荐中国地区)', style: TextStyle(fontSize: 14)),
                      trailing: CupertinoButton(
                        onPressed: _setMirror,
                        child: _selectMirror("Select distro pkg mirror"),
                      ),
                    ),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
