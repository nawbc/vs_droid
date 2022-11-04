import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:path/path.dart' as p;

class DroidPty {
  late Pty _pty;

  Stream<Uint8List> get output => _pty.output;
  Future<int> get exitCode => _pty.exitCode;
  int get pid => _pty.pid;

  DroidPty(String root, {int rows = 25, int columns = 80}) {
    Map<String, String> env = Map.from(Platform.environment);

    final home = p.normalize("$root/../home");
    env["TERM"] = "xterm-256color";
    if (File("$root/bin/bash").existsSync()) {
      env['LD_PRELOAD'] = "$root/lib/libtermux-exec.so";
      env['LD_LIBRARY_PATH'] = "$root/lib";
      env['PATH'] = "$root/bin:${Platform.environment["PATH"]!}";
      env['HOME'] = home;
      env['SHELL'] = "$root/bin/bash";
      env['TERMUX_PREFIX'] = root;
      env['PREFIX'] = root;
      env['TERMINFO'] = "$root/share/terminfo";

      _pty = Pty.start(
        "$root/bin/bash",
        environment: env,
        workingDirectory: home,
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
