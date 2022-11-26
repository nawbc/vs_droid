import 'package:vs_droid/distros/distro.dart';

final alpineDistro = Distro(
  id: "alpine",
  name: "Alpine Linux (edge)",
  semver: "3.16.2",
  sha256: "cb5dc88e0328765b0decae0da390c2eeeb9414ae82f79784cf37d7c521646a59",
  chineseMirrors: ["tsinghua", "aliyun", "ustc", "apline"],
  defaultMirror: 'tsinghua',
  replaceCNMirrorShell: {},
);
