import 'package:flutter/widgets.dart';
import 'xlive_switch.dart';

class DroidSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color unActiveColor;
  final Color? thumbColor;

  const DroidSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xCE007BFF),
    this.unActiveColor = const Color(0xCE007BFF),
    this.thumbColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.78,
      child: XlivSwitch(
        unActiveColor: unActiveColor,
        activeColor: activeColor,
        thumbColor: thumbColor,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
