class Distro {
  String arch;
  String? releaseUri;
  String? releaseUriCN;

  final String id;
  final String name;
  final String semver;
  final String sha256;
  late String overwriteDistro;
  final String defaultMirror;
  late String tarball;
  late List<String> chineseMirrors;

  Distro({
    required this.id,
    required this.name,
    required this.semver,
    required this.sha256,
    required this.chineseMirrors,
    required this.defaultMirror,
    this.arch = "aarch64",
    this.releaseUri,
    this.releaseUriCN,
  }) {
    tarball = "$id-$arch-$semver.tar.xz";
    overwriteDistro = """
DISTRO_NAME="$name"

TARBALL_URL['$arch']="$tarball"
TARBALL_SHA256['$arch']="$sha256"
""";
  }

  String setChineseMirror(String mirror) {
    String shell;
    switch (mirror) {
      case "tsinghua":
        shell = "sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories";
        break;
      case "aliyun":
        shell = "sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories";
        break;
      case "ustc":
        shell = "sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories";
        break;
      case "apline":
        shell = "";
        break;
      default:
        shell = '';
    }

    return shell;
  }
}
