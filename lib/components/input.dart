import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../theme_model.dart';

BorderSide kDefaultRoundedBorderSide(color) => BorderSide(
      color: color,
      style: BorderStyle.solid,
      width: 0.0,
    );
Border defaultRoundedBorder({color}) => Border(
      top: kDefaultRoundedBorderSide(color),
      bottom: kDefaultRoundedBorderSide(color),
      left: kDefaultRoundedBorderSide(color),
      right: kDefaultRoundedBorderSide(color),
    );

BoxDecoration inputDecoration({color = CupertinoColors.white, required Color borderColor}) => BoxDecoration(
      color: color,
      border: defaultRoundedBorder(color: borderColor),
      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
    );

class DroidInput extends StatefulWidget {
  final TextStyle? style;
  final BoxDecoration? decoration;
  final TextEditingController? controller;
  final String? placeholder;
  final int maxLines;
  final Function(String)? onSubmitted;
  final TextStyle? textStyle;
  final FocusNode? focusNode;

  const DroidInput({
    Key? key,
    this.style,
    this.controller,
    this.placeholder,
    this.maxLines = 1,
    this.onSubmitted,
    this.decoration,
    this.textStyle,
    this.focusNode,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DroidInput();
  }
}

class _DroidInput extends State<DroidInput> {
  late ThemeModel _tm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tm = Provider.of<ThemeModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      focusNode: widget.focusNode,
      cursorHeight: 24,
      style: widget.style,
      controller: widget.controller,
      maxLines: widget.maxLines,
      placeholder: widget.placeholder,
      onSubmitted: widget.onSubmitted,
      // decoration: widget.decoration ??
      //     inputDecoration(
      //       color: theme.inputBgColor,
      //       borderColor: theme.inputBorderColor,
      //     ),
      // placeholderStyle: widget.textStyle ??
      //     TextStyle(
      //       fontWeight: FontWeight.w400,
      //       color: theme.itemFontColor,
      //     ),
    );
  }
}
