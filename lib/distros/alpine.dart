import 'dart:io';

List<String> alpineMirror = ["tsinghua", "aliyun", "ustc", "apline"];

Future<void> setChineseAlpineMirror(String usr, [String? mirror]) async {
  String mirrorUrl;
  switch (mirror) {
    case "tsinghua":
      mirrorUrl =
          'http://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/main\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/community';
      break;
    case "aliyun":
      mirrorUrl =
          'http://mirrors.aliyun.com/alpine/latest-stable/main\nhttp://mirrors.aliyun.com/alpine/latest-stable/community';
      break;
    case "ustc":
      mirrorUrl =
          'http://mirrors.ustc.edu.cn/alpine/latest-stable/main\nhttp://mirrors.ustc.edu.cn/alpine/latest-stable/community';
      break;
    case "apline":
      mirrorUrl =
          'http://dl-cdn.alpinelinux.org/alpine/latest-stable/main\nhttp://dl-cdn.alpinelinux.org/alpine/latest-stable/community';
      break;
    default:
      mirrorUrl =
          'http://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/main\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/community';
  }

  // File repoFile = File('$usr/rootfs/etc/apk/repositories');

  // if (repoFile.existsSync()) {
  //   await repoFile.writeAsString(mirrorUrl);
  // } else {
  //   throw Exception('${repoFile.path} ENOENT');
  // }
}
