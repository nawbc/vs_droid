import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:vs_droid/components/droid_modal.dart';
import 'package:vs_droid/constant.dart';
import 'package:vs_droid/distros/ubuntu.dart';
import 'package:xterm/core.dart';
import 'package:xterm/ui.dart';
import 'components/list.dart';
import 'components/menu.dart';
import 'config_model.dart';
import 'distros/distro.dart';
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

// ignore: non_constant_identifier_names

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
  String? _codeServerPath;
  late String _validMirrorName;
  late String _rootfsPath;
  late String _region;
  late Distro _distro;
  late List<String> _envAssets;

  /// Assets lock, avoid conflict.
  late bool _installationMutex;
  late bool _isTermuxInstalled;

  final terminal = Terminal(
    maxLines: 999999,
  );

  @override
  void initState() {
    super.initState();
    _region = Platform.localeName.substring(0, 2) == 'zh' ? 'zh' : 'en';
    _validMirrorName = _region == "zh" ? "tsinghua" : "ubuntu";
    _distro = ubuntuDistro;
    _envAssets = [...DEB_ASSETS, "${_distro.id}-${_distro.arch}-${_distro.semver}.tar.xz"];
    _rootfsPath = "ubuntu";
    _installationMutex = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tm = Provider.of<ThemeModel>(context);
    _cm = Provider.of<ConfigModel>(context);
    _isTermuxInstalled = _cm.termuxUsr.existsSync();

    _pseudoWrite("Linux runtime is ${_isTermuxInstalled ? "" : "not"}installed ");
    if (_isTermuxInstalled) {
      _pseudoWrite("If you wanna to reset runtime, tap delete sandbox button...");
    } else {
      _pseudoWrite("Setting required options and tapping install button to init environment...");
    }
  }

  void _startPty() {
    _pty = DroidPty(
      _cm.termuxUsr.path,
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
    );

    _pty?.exitCode.then((code) {
      terminal.write('the process exited with exit code $code');
    });

    _pty?.output.cast<List<int>>().transform(const Utf8Decoder()).listen((data) {
      log(data);
      terminal.write(data);
    }, onDone: () {
      var a = 10;
      print(a);

      print('----------------');
    });

    terminal.onResize = (w, h, pw, ph) {
      _pty?.resize(h, w);
    };
  }

  Future<void> _deleteSandbox() async {
    if (_installationMutex) {
      Fluttertoast.showToast(msg: "Installing...");
      return;
    }

    if (!_cm.termuxUsr.existsSync()) {
      return;
    }

    _pseudoWrite("rm -rf ${_cm.termuxUsr.path}");
    _pseudoWrite("rm -rf ${_cm.termuxHome.path}...");
    await _cm.termuxUsr.delete(recursive: true);
    await _cm.termuxHome.delete(recursive: true);
    _pseudoWrite("remove successfully...");
    if (mounted) {
      setState(() {
        _isTermuxInstalled = false;
      });
    }
  }

  Widget _selectRootfs(String name) {
    return FocusedMenuHolder(
      menuWidth: 200,
      menuItemExtent: 35,
      offsetY: 10,
      duration: const Duration(milliseconds: 100),
      maskColor: const Color.fromARGB(30, 116, 116, 116),
      menuItems: VALID_ROOTFS
          .map(
            (e) => FocusedMenuItem(
              title: Text(e["label"]!, style: const TextStyle(fontSize: 14)),
              onPressed: () {
                Fluttertoast.showToast(msg: "Coming soon");
                // setState(() {
                //   _distro = DISTRO_MAP[e["value"]]!;
                // });
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
      menuItems: _distro.chineseMirrors
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
    File symLinks = File("${_cm.termuxUsr.path}/SYMLINKS.txt");
    Map map = {};

    await symLinks.openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach(
      (line) async {
        final pair = line.split("←");
        final linkPath = p.normalize(p.join(_cm.termuxUsr.path, pair.elementAt(1)));

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
    await _cm.termuxHome.create(recursive: true);
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
        File(p.join(_cm.termuxUsr.path, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(p.join(_cm.termuxUsr.path, filename)).create(recursive: true);
      }
    }

    _pseudoWrite("Extract bootstrap-aarch64 successfully...");
  }

  Future<void> _prepareTermux() async {
    if (await _cm.termuxUsr.exists()) {
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

    await for (var ele in Stream.fromIterable(_envAssets)) {
      var a = await rootBundle.load("assets/$ele");
      var b = File("${_cm.termuxHome.path}/$ele");
      await b.writeAsBytes(a.buffer.asUint8List(a.offsetInBytes, a.lengthInBytes));
    }
    await chmod(_cm.termuxHome.path, "755");
    await chmod(_cm.termuxUsr.path, "755");

    _startPty();

    await for (var ele in Stream.fromIterable(DEB_ASSETS)) {
      _pty?.exec("dpkg -i ./$ele");
    }
  }

  Future<void> _clean() async {
    await for (var ele in Stream.fromIterable(_envAssets)) {
      var b = File("${_cm.termuxHome.path}/$ele");
      await b.delete();
    }
  }

  Future<void> _prepareCodeServer() async {
    final fakeScript = File("${_cm.termuxUsr.path}/etc/proot-distro/${_distro.id}.sh");
    await chmod(_codeServerPath!, "777");
    await fakeScript.writeAsString(_distro.overwriteDistro);
    final replaceMirrorShell = _distro.replaceCNMirrorShell[_validMirrorName];
    var rootfsTarball = _rootfsFile != null ? _rootfsFile!.path : './${_distro.tarball}';

    _pty?.write("""
PROOT_DISTRO=\$PREFIX/var/lib/proot-distro
mkdir -p \$PROOT_DISTRO/dlcache
mv $rootfsTarball \$PROOT_DISTRO/dlcache
proot-distro install ubuntu
proot-distro login ubuntu
$replaceMirrorShell
mkdir -p /home/code-server
apt update && apt install $_codeServerPath -y
exit
""");
  }

  bool assetsValidate() {
    if (_codeServerPath == null) {
      Fluttertoast.showToast(msg: "Pleace pick code server tarball");
      return false;
    }

    return true;
  }

  Future<void> _install() async {
    if (_installationMutex) {
      Fluttertoast.showToast(msg: "Installing...");
      return;
    }

    /// verify assets available.
    if (!assetsValidate()) return;

    _installationMutex = true;
    // Prepare termux env, install deb packages.
    await _prepareTermux().catchError((err) {
      _installationMutex = false;
      showAlertModal(context, "Prepare assets failed");
      throw err;
    });
    await Future.delayed(const Duration(seconds: 1));
    // Install rootfs by proot.
    await _prepareCodeServer();

    setState(() {
      _installationMutex = false;
    });
  }

  Future<void> _pickRootfs() async {
    Fluttertoast.showToast(msg: "Ubuntu Linux is built-in, and currently only support Ubuntu");
    // if (_distro.id == "ubuntu") {
    //   Fluttertoast.showToast(msg: "Ubuntu Linux is built-in");
    //   return;
    // }
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['gz', 'xz'],
    // );
    // if (result != null) {
    //   setState(() {
    //     _rootfsFile = result.files.single;
    //     _rootfsPath = result.files.single.name;
    //   });
    // }
  }

  Future<void> _pickCodeServer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gz', 'xz', 'deb'],
    );

    if (result != null) {
      if (!result.files.single.name.contains(RegExp("arm64|aarch64"))) {
        Fluttertoast.showToast(msg: "Tarball name needs to include arm64 or aarch64");
        return;
      }

      setState(() {
        _codeServerPath = result.files.single.path?.replaceAll(RegExp(r"\/data\/user\/\d+"), "/data/data");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    log("$_isTermuxInstalled");
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
                          Text('Recommended defaults', style: TextStyle(fontSize: 15.sp)),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 30,
                                  child: CupertinoButton(
                                    padding: EdgeInsets.only(
                                        left: 30, right: _isTermuxInstalled ? 0 : 30, top: 5, bottom: 5),
                                    onPressed: _deleteSandbox,
                                    child:
                                        Text('Delete sandbox', style: TextStyle(fontSize: 15, color: Colors.red[800])),
                                  ),
                                ),
                                _isTermuxInstalled
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
                                              child: Text('Install', style: TextStyle(fontSize: 15.sp)),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
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
                                  _region = "zh";
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 20,
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                color: _region == "zh" ? _tm.themeData.primaryColor : Colors.transparent,
                                child: Text('中文',
                                    style: TextStyle(fontSize: 12, color: _region == "zh" ? Colors.white : null)),
                              ),
                            ),
                            const SizedBox(width: 25),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _region = "en";
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 20,
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                color: _region == "zh" ? Colors.transparent : _tm.themeData.primaryColor,
                                child: Text('English',
                                    style: TextStyle(fontSize: 12, color: _region == "zh" ? null : Colors.white)),
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
                            Text(_distro.name),
                          ],
                        ),
                        trailing: CupertinoButton(
                          onPressed: _pickRootfs,
                          child: _selectRootfs("Select rootfs"),
                        ),
                      ),
                      ListItem(
                        require: true,
                        dotted: true,
                        leading: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_rootfsPath, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        trailing: Wrap(
                          children: [
                            CupertinoButton(
                              onPressed: () async {
                                await launchUrl(
                                    Uri.parse(_region == "zh" ? _distro.releaseUriCN! : _distro.releaseUri!),
                                    mode: LaunchMode.externalApplication);
                              },
                              child: const Text('Download'),
                            ),
                            CupertinoButton(
                              onPressed: _pickRootfs,
                              child: const Text('Pick file'),
                            ),
                          ],
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
                          sub: _codeServerPath == null
                              ? null
                              : Text(_codeServerPath ?? "", style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                      _region == "zh"
                          ? ListItem(
                              dotted: true,
                              leading: Text(_validMirrorName),
                              sub: const Text("推荐更换镜像(默认清华源)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              trailing: CupertinoButton(
                                onPressed: () {},
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
