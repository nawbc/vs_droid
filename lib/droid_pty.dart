import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:provider/provider.dart';
import 'config_model.dart';

class DroidPty {
  late Pty _pty;
  late ConfigModel _cm;

  Stream<Uint8List> get output => _pty.output;
  Future<int> get exitCode => _pty.exitCode;
  int get pid => _pty.pid;

  DroidPty(final BuildContext context, {int rows = 25, int columns = 80}) {
    _cm = Provider.of<ConfigModel>(context);
    Map<String, String> env = Map.from(Platform.environment);
    env["TERM"] = "xterm-256color";
    if (File("${_cm.termuxBinDir.path}/bash").existsSync()) {
      env['LD_PRELOAD'] = "${_cm.termuxUsrDir.path}/lib/libtermux-exec.so";
      env['LD_LIBRARY_PATH'] = "${_cm.termuxUsrDir.path}/lib";
      env['PATH'] = "${_cm.termuxBinDir.path}:${Platform.environment["PATH"]!}";
      env['HOME'] = _cm.termuxHomeDir.path;
      env['SHELL'] = "${_cm.termuxBinDir.path}/bash";
      env['TERMUX_PREFIX'] = _cm.termuxUsrDir.path;
      env['PREFIX'] = _cm.termuxUsrDir.path;
      env['TERMINFO'] = "${_cm.termuxUsrDir.path}/share/terminfo";

      _pty = Pty.start(
        "${_cm.termuxBinDir.path}/bash",
        environment: env,
        workingDirectory: _cm.termuxHomeDir.path,
        rows: rows,
        columns: columns,
      );
    } else {
      _pty = Pty.start(
        "/system/bin/sh",
        environment: env,
        rows: rows,
        columns: columns,
      );
    }
  }

  void exec(String shell) => _pty.write(const Utf8Encoder().convert("$shell\n"));
  void write(String shell) => _pty.write(const Utf8Encoder().convert(shell));

  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) => _pty.kill(signal);

  void resize(int rows, int cols) => _pty.resize(rows, cols);

  void ackRead() => _pty.ackRead();
}
