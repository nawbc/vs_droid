import 'package:vs_droid/distros/distro.dart';

final ubuntuDistro = Distro(
  id: "ubuntu",
  name: "Ubuntu (jammy)",
  semver: "22.04.1",
  sha256: "ee0eaebf390559583c4659b4d719b9b6a42a2eb7dad10d0aec09e38add559086",
  chineseMirrors: ["tsinghua", "aliyun", "ustc", "ubuntu"],
  defaultMirror: 'tsinghua',
  releaseUriCN: "https://github.com/deskbtm/proot-distro",
  replaceCNMirrorShell: {
    "tsinghua": """sed -i "s/ports.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list""",
    "aliyun": """sed -i "s/ports.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list""",
    "ustc": """sed -i "s/ports.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list""",
    "ubuntu": "",
  },
);
