import 'package:vs_droid/distros/ubuntu.dart';
import 'alpine.dart';

class Distro {
  String arch;
  String? releaseUri;
  String? releaseUriCN;

  final String id;
  final String name;
  final String semver;
  final String sha256;
  final Map replaceCNMirrorShell;
  final String defaultMirror;

  late String overwriteDistro;
  late String tarball;
  late List<String> chineseMirrors;

  Distro({
    required this.id,
    required this.name,
    required this.semver,
    required this.sha256,
    required this.chineseMirrors,
    required this.defaultMirror,
    required this.replaceCNMirrorShell,
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
}

// ignore: non_constant_identifier_names
var DISTRO_MAP = {
  "ubuntu": ubuntuDistro,
  "alpine": alpineDistro,
};

const VALID_ROOTFS = [
  {
    "label": "Ubuntu(built-in)",
    "value": "ubuntu",
  },
  {
    "label": "Alpine Linux(coming soon)",
    "value": "alpine",
  },
  {
    "label": "Manjaro(coming soon)",
    "value": "manjaro",
    "url": "https://github.com/manjaro-arm/rootfs/releases",
  },
  {
    "label": "Arch Linux(coming soon)",
    "value": "arch",
    "url": "",
  },
  {
    "label": "Debian(coming soon)",
    "value": "debian",
    "url": "",
  },
  {
    "label": "Fedora(coming soon)",
    "value": "fedora",
    "url": "",
  },
  {
    "label": "OpenSUSE(coming soon)",
    "value": "openSUSE",
    "url": "",
  }
];
