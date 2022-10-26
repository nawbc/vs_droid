import 'dart:io';
import 'package:system_info2/system_info2.dart';

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

downloadBootstrap() async {
  const VERSION = "2022.10.23-r1";
  // const VERSION_C = VERSION + "bootstrap-2022.10.23-r1+apt-android-7"
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
