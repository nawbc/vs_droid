import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:vs_droid/components/droid_modal.dart';
import 'package:vs_droid/constant.dart';
import 'package:vs_droid/distros/alpine.dart';
import 'package:xterm/core.dart';
import 'package:xterm/ui.dart';
import 'components/list.dart';
import 'components/menu.dart';
import 'config_model.dart';
import 'droid_pty.dart';
import 'theme.dart';
import 'theme_model.dart';
import 'utils.dart';

const DEB_ASSETS = [
  "libtalloc_${TALLOC_SEMVER}_aarch64.deb",
  "ncurses_${NCURSES_SEMVER}_aarch64.deb",
  "ncurses-utils_${NCURSES_UTILS_SEMVER}_aarch64.deb",
  "proot_${PROOT_SEMVER}_aarch64.deb",
  "proot-distro_${PROOT_DISTRO_SEMVER}_all.deb",
];

const ALL_ASSETS = [...DEB_ASSETS, ALPINE_TARBALL];

class InitVscPage extends StatefulWidget {
  const InitVscPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InitVscPageState();
  }
}

class _InitVscPageState extends State<InitVscPage> {
  DroidPty? _pty;
  late ConfigModel _cm;
  late ThemeModel _tm;
  PlatformFile? _rootfsFile;
  PlatformFile? _codeServerFile;
  late List<Map<String, String>> _supportRootfsList;
  late List<String> _mirrorList;
  late String _validMirrorName;
  late String _rootfsPath;
  late bool _isCN;

  /// Assets lock, avoid conflict.
  late bool _mutex;
  late bool _isInstalled;

  Map<String, String> _rootfsSelection = {
    "label": "Alpine Linux(built-in)",
    "value": "alpine",
  };

  final terminal = Terminal(
    maxLines: 999999,
  );

  @override
  void initState() {
    super.initState();
    _isCN = Platform.localeName.substring(0, 2) == 'zh';
    _supportRootfsList = ROOTFS_DOWNLOAD_CN;
    _validMirrorName = _isCN ? "tsinghua" : "alpine";
    _mirrorList = ALPINE_MIRROR;
    _rootfsPath = "alpine";
    _mutex = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tm = Provider.of<ThemeModel>(context);
    _cm = Provider.of<ConfigModel>(context);
    _isInstalled = _cm.termuxUsrDir.existsSync();

    _pseudoWrite("Linux runtime is ${_isInstalled ? "" : "not"}installed ");
    if (_isInstalled) {
      _pseudoWrite("If you wanna reset runtime, tap delete rootfs button...");
    } else {
      _pseudoWrite("Setting required options and tapping install button to init environment...");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _startPty() {
    _pty = DroidPty(
      _cm.termuxUsrDir.path,
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
    );

    _pty?.exitCode.then((code) {
      terminal.write('the process exited with exit code $code');
    });

    _pty?.output.cast<List<int>>().transform(const Utf8Decoder()).listen((data) {
      terminal.write(data);
    });

    terminal.onResize = (w, h, pw, ph) {
      _pty?.resize(h, w);
    };
  }

  Future<void> _deleteSandbox() async {
    if (_mutex) {
      Fluttertoast.showToast(msg: "Installing...");
      return;
    }

    if (!_cm.termuxUsrDir.existsSync()) {
      return;
    }

    _pseudoWrite("rm -rf ${_cm.termuxUsrDir.path}");
    _pseudoWrite("rm -rf ${_cm.termuxHomeDir.path}...");
    await _cm.termuxUsrDir.delete(recursive: true);
    await _cm.termuxHomeDir.delete(recursive: true);
    _pseudoWrite("remove successfully...");
    if (mounted) {
      setState(() {
        _isInstalled = false;
      });
    }
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

  void _pseudoWrite(String data) {
    terminal.write("\r\n");
    terminal.write(r"~$: " + data);
  }

  Future<void> _extractBootstrap() async {
    await _cm.termuxHomeDir.create(recursive: true);
    _pseudoWrite("Create home directory successfully");

    _pseudoWrite("Start extract assets from bundle...");
    var a = await rootBundle.load("assets/bootstrap-aarch64-$BOOTSTRAP_SEMVER.zip");
    final b = InputStream(a);
    final archive = ZipDecoder().decodeBuffer(b);

    // Extract the contents of the Zip archive to disk.
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(p.join(_cm.termuxUsrDir.path, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(p.join(_cm.termuxUsrDir.path, filename)).create(recursive: true);
      }
    }

    _pseudoWrite("Extract bootstrap-aarch64 successfully...");
  }

  Future<void> _prepareTermux() async {
    if (await _cm.termuxUsrDir.exists()) {
      return;
    }
    await _extractBootstrap().catchError((err) {
      _pseudoWrite("Extract assets failed");
      _pseudoWrite(err);
    });
    _pseudoWrite("Start linking symbolic");
    await _createRootfsSymlink().catchError((err) {
      _pseudoWrite("Linking failed...");
      _pseudoWrite(err);
    });
    _pseudoWrite("Linking successfully...");

    await for (var ele in Stream.fromIterable(ALL_ASSETS)) {
      var a = await rootBundle.load("assets/$ele");
      var b = File("${_cm.termuxHomeDir.path}/$ele");
      await b.writeAsBytes(a.buffer.asUint8List(a.offsetInBytes, a.lengthInBytes));
    }
    await chmod(_cm.termuxHomeDir.path, "755");
    await chmod(_cm.termuxUsrDir.path, "755");

    _startPty();

    await for (var ele in Stream.fromIterable(DEB_ASSETS)) {
      _pty?.exec("dpkg -i ./$ele");
    }
  }

  Future<void> _clean() async {
    await for (var ele in Stream.fromIterable(ALL_ASSETS)) {
      var b = File("${_cm.termuxHomeDir.path}/$ele");
      await b.delete();
    }
  }

  Future<void> _prepareRootfs() async {
    final alpineScript = File("${_cm.termuxUsrDir.path}/etc/proot-distro/alpine.sh");

    await alpineScript.writeAsString(FAKE_ALPINE_SCRIPT);
    final changeMirrorShell = setChineseAlpineMirror(_validMirrorName);
    var rootfsTarball = _rootfsFile != null ? _rootfsFile!.path : './$ALPINE_TARBALL';

    _pty?.write("""
PROOT_DISTRO=\$PREFIX/var/lib/proot-distro
mkdir -p \$PROOT_DISTRO/dlcache
mv $rootfsTarball \$PROOT_DISTRO/dlcache
proot-distro install alpine
proot-distro login alpine
$changeMirrorShell
apk update && apk add nodejs
""");
  }

  bool assetsValidate() {
    if (_rootfsSelection["value"] != "alpine") {
      Fluttertoast.showToast(msg: "Only support Alpine Linux");
      return false;
    }

    if (_codeServerFile == null) {
      Fluttertoast.showToast(msg: "Code Server tarball");
      return false;
    }

    return true;
  }

  Future<void> _install() async {
    if (_mutex) {
      Fluttertoast.showToast(msg: "Installing...");
      return;
    }

    /// verify assets available.
    final validate = assetsValidate();
    if (!validate) {
      return;
    }

    _mutex = true;
    // Prepare termux env, install deb packages.
    await _prepareTermux().catchError((err) {
      _mutex = false;
      showAlertModal(context, "Prepare assets failed");
      throw err;
    });
    await Future.delayed(const Duration(seconds: 1));
    // Install rootfs by proot.
    await _prepareRootfs();

    setState(() {
      _mutex = false;
    });
  }

  Future<void> _pickRootfs() async {
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

  Future<void> _pickCodeServer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gz', 'xz'],
    );

    if (result != null) {
      if (!result.files.single.name.contains(RegExp("arm64|aarch64"))) {
        Fluttertoast.showToast(msg: "Tarball name needs to include arm64 or aarch64");
        return;
      }

      setState(() {
        _codeServerFile = result.files.single;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    log("$_isInstalled");
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: TerminalView(
                  terminal,
                  padding: const EdgeInsets.only(right: 50),
                  theme: terminalTheme,
                  alwaysShowCursor: true,
                  backgroundOpacity: 0,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recommended defaults', style: TextStyle(fontSize: 15)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 30,
                                child: CupertinoButton(
                                  padding: EdgeInsets.only(left: 30, right: _isInstalled ? 0 : 30, top: 5, bottom: 5),
                                  onPressed: _deleteSandbox,
                                  child: Text('Delete sandbox', style: TextStyle(fontSize: 15, color: Colors.red[800])),
                                ),
                              ),
                              _isInstalled
                                  ? Container()
                                  : Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          height: 30,
                                          child: CupertinoButton.filled(
                                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                                            padding: const EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 5),
                                            onPressed: _install,
                                            child: const Text('Install', style: TextStyle(fontSize: 15)),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Material(
                        color: Colors.transparent,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Region:"),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _validMirrorName = "tsinghua";
                                  _isCN = true;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 20,
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                color: _isCN ? _tm.themeData.primaryColor : Colors.transparent,
                                child: Text('中文', style: TextStyle(fontSize: 12, color: _isCN ? Colors.white : null)),
                              ),
                            ),
                            const SizedBox(width: 25),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _validMirrorName = "alpine";
                                  _isCN = false;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 20,
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                color: _isCN ? Colors.transparent : _tm.themeData.primaryColor,
                                child:
                                    Text('English', style: TextStyle(fontSize: 12, color: _isCN ? null : Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListItem(
                          require: true,
                          dotted: true,
                          leading: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(_rootfsSelection["label"]!),
                            ],
                          ),
                          trailing: Wrap(
                            children: [
                              CupertinoButton(
                                onPressed: () async {
                                  await launchUrl(Uri.parse(_rootfsSelection["url"]!),
                                      mode: LaunchMode.externalApplication);
                                },
                                child: const Text('Download'),
                              ),
                              CupertinoButton(
                                onPressed: _pickRootfs,
                                child: _selectRootfs("Pick rootfs"),
                              ),
                            ],
                          )),
                      ListItem(
                        require: true,
                        dotted: true,
                        leading: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_rootfsPath, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        trailing: CupertinoButton(
                          onPressed: _pickRootfs,
                          child: const Text('Pick file'),
                        ),
                      ),
                      ListItem(
                          require: true,
                          dotted: true,
                          leading: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text("Code Server"),
                            ],
                          ),
                          sub: _codeServerFile?.path == null
                              ? null
                              : Text(_codeServerFile!.path ?? "",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Wrap(
                            children: [
                              CupertinoButton(
                                onPressed: () async {
                                  await launchUrl(Uri.parse(CODE_SERVER_RELEASE), mode: LaunchMode.externalApplication);
                                },
                                child: const Text('Download'),
                              ),
                              CupertinoButton(
                                onPressed: _pickCodeServer,
                                child: const Text('Pick file'),
                              ),
                            ],
                          )),
                      _isCN
                          ? ListItem(
                              dotted: true,
                              leading: Text(_validMirrorName),
                              sub: const Text("推荐更换镜像(默认清华源)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              trailing: CupertinoButton(
                                onPressed: _setMirror,
                                child: _selectMirror("Select rootfs mirror"),
                              ),
                            )
                          : Container(),
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
