import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DroidDialogTitle extends StatelessWidget {
  final Widget title;
  final Widget? subTitle;

  const DroidDialogTitle({Key? key, required this.title, this.subTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        title,
        const SizedBox(width: 10),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 2,
          ),
          child: subTitle,
        ),
      ],
    );
  }
}

class DroidDialog extends Dialog {
  final Widget? title;
  final List<Widget> children;
  final dynamic action;
  final VoidCallback? onOk;
  final VoidCallback? onCancel;
  final String okText;
  final String cancelText;
  final MainAxisAlignment actionPos;
  final bool display;
  final bool withOk;
  final bool withCancel;

  const DroidDialog({
    super.key,
    required this.children,
    this.display = false,
    this.actionPos = MainAxisAlignment.start,
    this.okText = "OK",
    this.cancelText = "Cancel",
    this.title,
    this.action = true,
    this.onOk,
    this.onCancel,
    this.withOk = true,
    this.withCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Offstage(
      offstage: display,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
            duration: insetAnimationDuration,
            curve: insetAnimationCurve,
            child: MediaQuery.removeViewInsets(
              removeLeft: true,
              removeTop: true,
              removeRight: true,
              removeBottom: true,
              context: context,
              child: Center(
                child: Wrap(
                  children: <Widget>[
                    Center(
                      child: SizedBox(
                        width: screenWidth - 80,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                          decoration: const ShapeDecoration(
                            color: Color(0xC0FFFFFF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: <Widget>[
                                  if (title != null)
                                    DefaultTextStyle(
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                      child: title!,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ...children,
                              if (action is List<Widget>) ...action,
                              if (!action) const SizedBox(height: 30),
                              if (action)
                                Row(
                                  mainAxisAlignment: actionPos,
                                  children: <Widget>[
                                    if (withOk)
                                      CupertinoButton(
                                        onPressed: onOk,
                                        child: Text(okText),
                                      ),
                                    if (withCancel)
                                      CupertinoButton(
                                        onPressed: onCancel is Function
                                            ? onCancel
                                            : () {
                                                Navigator.pop(context);
                                              },
                                        child: Text(cancelText),
                                      ),
                                  ],
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
