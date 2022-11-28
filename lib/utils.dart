import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:system_info2/system_info2.dart';
import 'droid_pty.dart';

/// RFC1918 https://en.wikipedia.org/wiki/Private_network
Future<String?> getInternalIp() async {
  String? ip;

  for (var interface in await NetworkInterface.list()) {
    for (var addr in interface.addresses) {
      if (!addr.isLoopback && addr.type.name == 'IPv4') {
        String pureAddr = addr.address.replaceAll(RegExp(r"\/\d+"), '');

        List block = pureAddr.split(RegExp(r"\."));

        if (block.length == 4) {
          if (block[0] == '192' &&
              block[1] == '168' &&
              int.parse(block[2]) >= 0 &&
              int.parse(block[2]) <= 255 &&
              int.parse(block[3]) >= 0 &&
              int.parse(block[3]) <= 255) {
            ip = addr.address;
          }

          if (block[0] == '172' &&
              int.parse(block[1]) >= 16 &&
              int.parse(block[1]) <= 33 &&
              int.parse(block[2]) >= 0 &&
              int.parse(block[2]) <= 255 &&
              int.parse(block[3]) >= 0 &&
              int.parse(block[3]) <= 255) {
            ip = addr.address;
          }

          if (block[0] == '10' &&
              int.parse(block[1]) >= 0 &&
              int.parse(block[1]) <= 255 &&
              int.parse(block[2]) >= 0 &&
              int.parse(block[2]) <= 255 &&
              int.parse(block[3]) >= 0 &&
              int.parse(block[3]) <= 255) {
            ip = addr.address;
          }
        }
      }
    }
  }
  return ip;
}

getSysArch() {
  late String arch;

  switch (SysInfo.kernelArchitecture) {
    case 'aarch64':
      arch = 'aarch64';
      break;
    case 'armv71':
      arch = 'armv7';
      break;
    case 'armv51':
      arch = 'armv7';
      break;
    case 'i686':
      arch = 'x86_64';
      break;
    default:
  }
  return arch;
}

Future<ProcessResult> chmod(String path, [String access = "775"]) async {
  return Process.run(
    'chmod',
    [
      '-R',
      access,
      path,
    ],
    workingDirectory: '/',
  );
}

class OutputCollector {
  final VSDroidPty _pty;

  OutputCollector(this._pty) {
    subscription = _pty.output.cast<List<int>>().transform(const Utf8Decoder()).listen((data) {
      log(data);
      buffer.write(data);
    });
  }

  final StringBuffer buffer = StringBuffer();

  late StreamSubscription subscription;

  String get output => buffer.toString();

  late final done = subscription.asFuture();

  Future<void> waitForFirstChunk() async {
    while (buffer.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> waitForOutput(Pattern pattern, [int timeout = 2000]) async {
    while (pattern.allMatches(output).isEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}

Future<bool> checkEnv(Directory usr, String rootfsName) async {
  final root = Directory("${usr.path}/var/lib/proot-distro/installed-rootfs/$rootfsName");
  final isUsr = await usr.exists();
  final isRootfs = await root.exists();
  if (!isUsr && !isRootfs) {
    return false;
  }

  return codeServerHealth(usr, rootfsName);
}

/// Deprecated
Future<bool> codeServerHealth(Directory usr, String name) async {
  final pty = VSDroidPty(
    usr.path,
  );

  final collector = OutputCollector(pty);

  try {
    pty.exec("""
proot-distro login $name
which code-server
""");
    await collector.waitForOutput("code-server").timeout(const Duration(seconds: 5)).catchError((err) {
      throw Exception(err);
    });
  } catch (e) {
    log("$e");
    return false;
  }
  return true;
}
