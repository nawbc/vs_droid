import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vs_droid/config_model.dart';
import 'package:xterm/core.dart';
import 'package:xterm/ui.dart';
import 'droid_pty.dart';
import 'theme.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TerminalPageState();
  }
}

class _TerminalPageState extends State<TerminalPage> {
  late DroidPty _pty;
  late ConfigModel _cm;

  final terminal = Terminal(
    maxLines: 999999,
  );

  final terminalController = TerminalController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cm = Provider.of<ConfigModel>(context);
    _startPty();
  }

  void _startPty() {
    _pty = DroidPty(_cm.termuxUsr.path, rows: terminal.viewWidth, columns: terminal.viewHeight);

    _pty.output.cast<List<int>>().transform(const Utf8Decoder()).listen((data) {
      terminal.write(data);
    });

    _pty.exitCode.then((code) {
      terminal.write('the process exited with exit code $code');
    });

    terminal.onOutput = (data) {
      _pty.write(data);
    };

    terminal.onResize = (w, h, pw, ph) {
      _pty.resize(h, w);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: TerminalView(
          terminal,
          padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
          controller: terminalController,
          autofocus: true,
          theme: terminalDarkTheme,
          alwaysShowCursor: true,
          backgroundOpacity: 1,
          onSecondaryTapDown: (details, offset) async {
            final selection = terminalController.selection;
            if (selection != null) {
              final text = terminal.buffer.getText(selection);
              terminalController.clearSelection();
              await Clipboard.setData(ClipboardData(text: text));
            } else {
              final data = await Clipboard.getData('text/plain');
              final text = data?.text;
              if (text != null) {
                terminal.paste(text);
              }
            }
          },
          // backgroundOpacity: 0,
        ),
      ),
    );
  }
}
