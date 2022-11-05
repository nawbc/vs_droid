// ignore_for_file: constant_identifier_names

const List<String> ALPINE_MIRROR = ["tsinghua", "aliyun", "ustc", "apline"];

const ALPINE_SEMVER = "v3.16.2";
const BOOTSTRAP_SEMVER = "2022.10.23-r1+apt-android-7";
const PROOT_DISTRO_SEMVER = "3.2.1";
const PROOT_SEMVER = "5.1.107-54";
const NCURSES_SEMVER = "6.3-4";
const NCURSES_UTILS_SEMVER = "6.3-4";
const TALLOC_SEMVER = "2.3.3";

const ALPINE_TARBALL = "alpine-aarch64-$ALPINE_SEMVER.tar.xz";
const FAKE_ALPINE_SCRIPT = """
DISTRO_NAME="Alpine Linux (edge)"

TARBALL_URL['aarch64']="$ALPINE_TARBALL"
TARBALL_SHA256['aarch64']="cb5dc88e0328765b0decae0da390c2eeeb9414ae82f79784cf37d7c521646a59"
""";

String setChineseAlpineMirror(String mirror) {
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
