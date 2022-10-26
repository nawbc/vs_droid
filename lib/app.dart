import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:vs_droid/config_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:vs_droid/utils.dart';
import 'double_pop.dart';
import 'package:path/path.dart' as pathLib;

class VSDroid extends StatefulWidget {
  const VSDroid({super.key});

  @override
  State<StatefulWidget> createState() {
    return _VSDroid();
  }
}

class _VSDroid extends State<VSDroid> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigModel>(
          create: (_) => ConfigModel(),
        ),
      ],
      child: const InnerVSDroid(),
    );
  }
}

class InnerVSDroid extends StatefulWidget {
  const InnerVSDroid({super.key});

  @override
  State<StatefulWidget> createState() {
    return _InnerVSDroid();
  }
}

class _InnerVSDroid extends State<InnerVSDroid> {
  late ConfigModel _cm;

  prepareAppEnv() async {
    _cm = Provider.of<ConfigModel>(context);
    await _cm.init();

    return true;
  }

  prepareUnixEnv() {}

  initPtyEnv() {}

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
      ),
      child: CupertinoApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        navigatorObservers: [
          SentryNavigatorObserver(),
        ],
        title: 'VS Droid',
        builder: (context, child) {
          return ResponsiveWrapper.builder(
            child,
            maxWidth: 1200,
            minWidth: 480,
            defaultScale: true,
            breakpoints: [
              const ResponsiveBreakpoint.resize(480, name: MOBILE),
              const ResponsiveBreakpoint.autoScale(800, name: TABLET),
              const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
            ],
            background: Container(color: const Color(0xFFF5F5F5)),
          );
        },
        home: DoublePop(
          child: FutureBuilder(
            future: prepareAppEnv(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError || snapshot.data == null) {
                  return Container(
                    color: Colors.white,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          UniconsLine.exclamation_triangle,
                          color: Colors.red,
                          size: 50,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Something wrong',
                          style: TextStyle(fontSize: 12),
                        )
                      ],
                    )),
                  );
                } else {
                  return const Demo();
                }
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Demo();
  }
}

class _Demo extends State<Demo> {
  late final Pty pty;
  final ptyOutout = StringBuffer();

  late ConfigModel _cm;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cm = Provider.of<ConfigModel>(context);

    Map<String, String> env = Map.from(Platform.environment);

    if (File("${_cm.termuxUsrDir.path}/lib/libtermux-exec.so").existsSync()) {}

    env['LD_PRELOAD'] = "${_cm.termuxUsrDir.path}/lib/libtermux-exec.so";
    env['LD_LIBRARY_PATH'] = "${_cm.termuxUsrDir.path}/lib";
    env['PATH'] = "${_cm.termuxBinDir.path}:${Platform.environment["PATH"]!}";
    // env['PATH'] = _cm.termuxBinDir.path;
    env['HOME'] = _cm.termuxHomeDir.path;
    env['SHELL'] = "${_cm.termuxBinDir.path}/bash";
    // env['PREFIX'] = _cm.termuxUsrDir.path;

    pty = Pty.start("${_cm.termuxBinDir.path}/bash", environment: env, workingDirectory: _cm.termuxHomeDir.path);

    pty.output.cast<List<int>>().transform(const Utf8Decoder()).listen((text) {
      log(text);
    });

    pty.exitCode.then((code) {
      ptyOutout.writeln('the process exited with exit code $code');
    });
  }

  @override
  Widget build(Object context) {
    return GestureDetector(
      onTap: () async {
        if (!_cm.termuxHomeDir.existsSync()) {
          await _cm.termuxHomeDir.create(recursive: true);
          await chmod(_cm.termuxHomeDir.path, "755").catchError((err) {});
        }

        if (!_cm.termuxUsrDir.existsSync()) {
          var a = await rootBundle.load("assets/bootstrap-aarch64.zip");
          final b = InputStream(a);

          final archive = ZipDecoder().decodeBuffer(b);
          extractArchiveToDisk(archive, _cm.termuxUsrDir.path);

          await chmod(_cm.termuxUsrDir.path, "755").catchError((err) {});
          File symLinks = File("${_cm.termuxUsrDir.path}/SYMLINKS.txt");
          Map map = {};

          await symLinks.openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) async {
            final p = line.split("←");
            final linkPath = pathLib.normalize(pathLib.join(_cm.termuxUsrDir.path, p.elementAt(1)));

            var linkDir = Directory(pathLib.dirname(linkPath));

            if (!linkDir.existsSync()) {
              linkDir.createSync(recursive: true);
            }

            Directory.current = linkDir;

            File target = File(pathLib.normalize(pathLib.join(Directory.current.path, p.elementAt(0))));

            if (target.existsSync()) {
              await Link(linkPath).create(target.path, recursive: true);
            } else {
              map[linkPath] = target.path;
            }
          });

          await for (var item in Stream.fromIterable(map.entries.toList())) {
            if (File(item.value).existsSync()) {
              await Link(item.key).create(item.value, recursive: true);
              map.remove(item.key);
            }
          }
        } else {
          // var a = await rootBundle.load("assets/proot-distro.zip");
          // final b = InputStream(a);

          // final archive = ZipDecoder().decodeBuffer(b);
          // extractArchiveToDisk(archive, _cm.termuxHomeDir.path);
          await chmod(_cm.termuxUsrDir.path, "775").catchError((err) {});
          // pty.write(const Utf8Encoder().convert("""touch demo.txt"""));

//           pty.write(const Utf8Encoder().convert("""
// cd ${_cm.termuxHomeDir.path}
// ls -al .
// """));

          // pty.write(const Utf8Encoder().convert('pwd'));

          // pty.output.listen((data) {
          //   print(String.fromCharCodes(data));
          //   print("====================");
          // }, onError: (v) {
          //   print(v);
          // }, onDone: () {
          //   // print(pty.output);
          //   // print("demodemodmeo");
          //   pty.kill();
          // });

          // print(File("${_cm.termuxBinDir.path}/pwd").statSync());
          // ProcessResult pr =
          //     await Process.run("pwait", [], workingDirectory: _cm.termuxHomeDir.path, environment: env)
          //         .catchError((err) {
          //   print(err);
          // });
          // print("${pr.stdout},======================");
          // print(pr.stderr);
        }
      },
      child: Container(
        height: 100,
        color: Color.fromARGB(255, 255, 255, 255),
        alignment: Alignment.center,
        child: Text("demo"),
      ),
    );
  }
}
