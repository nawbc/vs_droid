import 'dart:io';

enum AlpineMirror { tsinghua, aliyun, ustc, apline }

Future<void> setChineseAlpineMirror(String usr, [AlpineMirror? mirror]) async {
  String mirrorUrl;
  switch (mirror) {
    case AlpineMirror.tsinghua:
      mirrorUrl =
          'http://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/main\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/community';
      break;
    case AlpineMirror.aliyun:
      mirrorUrl =
          'http://mirrors.aliyun.com/alpine/latest-stable/main\nhttp://mirrors.aliyun.com/alpine/latest-stable/community';
      break;
    case AlpineMirror.ustc:
      mirrorUrl =
          'http://mirrors.ustc.edu.cn/alpine/latest-stable/main\nhttp://mirrors.ustc.edu.cn/alpine/latest-stable/community';
      break;
    case AlpineMirror.apline:
      mirrorUrl =
          'http://dl-cdn.alpinelinux.org/alpine/latest-stable/main\nhttp://dl-cdn.alpinelinux.org/alpine/latest-stable/community';
      break;
    default:
      mirrorUrl =
          'http://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/main\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/community';
  }

  File repoFile = File('$usr/rootfs/etc/apk/repositories');

  if (repoFile.existsSync()) {
    await repoFile.writeAsString(mirrorUrl);
  } else {
    throw Exception('${repoFile.path} ENOENT');
  }
}
