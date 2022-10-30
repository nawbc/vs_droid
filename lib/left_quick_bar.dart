import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class LeftQuickBar extends StatefulWidget {
  const LeftQuickBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LeftQuickBarState();
  }
}

class LeftQuickBarState extends State<LeftQuickBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('RightQuickBoard Painted...');

    print(ResponsiveWrapper.of(context).isSmallerThan(DESKTOP));

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text(
          '目录',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 20,
            // color: themeData.navTitleColor,
          ),
        ),
        // backgroundColor: themeData.navBackgroundColor,
        border: null,
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return TextButton(
                onPressed: () {
                  print(MediaQuery.of(context).size.width);
                  print(ResponsiveWrapper.of(context).isDesktop);
                },
                child: Text("demo"),
              );
              // return InkWell(
              //   onTap: () {
              //     Navigator.of(context, rootNavigator: true).push(
              //       CupertinoPageRoute(
              //         builder: (BuildContext context) {
              //           return Container();
              //         },
              //       ),
              //     );
              //   },
              //   child: ListTile(
              //       title: ThemedText(S.of(context)!.about),
              //       contentPadding: EdgeInsets.only(left: 15, right: 25),
              //       trailing: Icon(Icons.hdr_weak)),
              // );
            },
          ),
        ),
      ),
    );
  }
}
