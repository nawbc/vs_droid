import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:provider/provider.dart';
import 'config_model.dart';

class DroidPty {
  late final Pty _pty;
  late ConfigModel _cm;

  Stream<Uint8List> get output => _pty.output;
  Future<int> get exitCode => _pty.exitCode;
  int get pid => _pty.pid;

  DroidPty(final BuildContext context) {
    _cm = Provider.of<ConfigModel>(context);
    Map<String, String> env = Map.from(Platform.environment);

    env['LD_PRELOAD'] = "${_cm.termuxUsrDir.path}/lib/libtermux-exec.so";
    env['LD_LIBRARY_PATH'] = "${_cm.termuxUsrDir.path}/lib";
    env['PATH'] = "${_cm.termuxBinDir.path}:${Platform.environment["PATH"]!}";
    env['HOME'] = _cm.termuxHomeDir.path;
    env['SHELL'] = "${_cm.termuxBinDir.path}/bash";
    env['TERMUX_PREFIX'] = _cm.termuxUsrDir.path;

    _pty = Pty.start("${_cm.termuxBinDir.path}/bash", environment: env, workingDirectory: _cm.termuxUsrDir.path);
  }

  void exec(String shell) => _pty.write(const Utf8Encoder().convert(shell));

  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) => _pty.kill(signal);

  void resize(int rows, int cols) => _pty.resize(rows, cols);

  void ackRead() => _pty.ackRead();
}
