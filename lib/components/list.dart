import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final Widget leading;
  final Widget trailing;
  final Widget? sub;
  final bool dotted;
  final bool require;
  const ListItem({
    super.key,
    required this.leading,
    required this.trailing,
    this.dotted = false,
    this.require = false,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                require ? const Text("*", style: TextStyle(color: Colors.red)) : Container(),
                const SizedBox(width: 3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leading,
                    const SizedBox(height: 3),
                    sub ?? Container(),
                  ],
                )
              ],
            ),
            trailing
          ],
        ),
        dotted
            ? DottedLine(
                dashColor: Colors.grey[400]!,
              )
            : Container()
      ],
    );
  }
}
