import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config_model.dart';
import 'constant.dart';
import 'double_pop.dart';
import 'error.dart';
import 'vsc_page.dart';
import 'init_vsc_page.dart';
import 'inner_drawer.dart';
import 'quick_settings.dart';
import 'theme.dart';
import 'theme_model.dart';
import 'utils.dart';

class VSDroid extends StatefulWidget {
  const VSDroid({super.key});

  @override
  State<StatefulWidget> createState() {
    return _VSDroid();
  }
}

class _VSDroid extends State<VSDroid> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigModel>(
          create: (_) => ConfigModel(),
        ),
        ChangeNotifierProvider<ThemeModel>(
          create: (_) => ThemeModel(),
        ),
      ],
      child: const InnerVSDroid(),
    );
  }
}

class InnerVSDroid extends StatefulWidget {
  const InnerVSDroid({super.key});

  @override
  State<StatefulWidget> createState() {
    return _InnerVSDroid();
  }
}

class _InnerVSDroid extends State<InnerVSDroid> {
  late ConfigModel _cm;
  late ThemeModel _tm;
  late bool _modelInited;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    _cm = Provider.of<ConfigModel>(context);
    _tm = Provider.of<ThemeModel>(context);
    await _cm.init();
    await _tm.init();

    setState(() {
      _modelInited = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _modelInited = false;
  }

  @override
  Widget build(BuildContext context) {
    DroidTheme themeData = _tm.themeData;

    if (!_modelInited) {
      return Container(color: themeData.scaffoldBackgroundColor);
    } else {
      return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              systemNavigationBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
            child: CupertinoApp(
              theme: CupertinoThemeData(
                primaryColor: themeData.primaryColor,
                textTheme: const CupertinoTextThemeData(
                  textStyle: TextStyle(fontSize: 14, color: Color(0xFF131313)),
                ),
              ),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              navigatorObservers: [
                SentryNavigatorObserver(),
                FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
              ],
              title: 'VS Droid',
              home: child,
            ),
          );
        },
        child: DoublePop(child: const Home()),
      );
    }
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Home();
  }
}

class _Home extends State<Home> {
  late ConfigModel _cm;
  late ThemeModel _tm;
  late StreamSubscription<ConnectivityResult> _connectSubscription;
  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();

  Future<void> _setInternalIp(ConnectivityResult? result, {bool notify = true}) async {
    if (result == ConnectivityResult.wifi) {
      final info = NetworkInfo();
      var wifiIP = await info.getWifiIP() ?? await getInternalIp() ?? LOOPBACK_ADDR;
      _cm.setInternalIP(wifiIP, notify: notify);
    }
  }

  Future<bool> appInit() async {
    var result = await Connectivity().checkConnectivity();
    await _setInternalIp(result, notify: false).catchError((err) {});

    return await checkEnv(_cm.termuxUsr, _cm.currentRootfsId!);
  }

  @override
  dispose() {
    super.dispose();
    _connectSubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) {
          _connectSubscription = Connectivity().onConnectivityChanged.listen(_setInternalIp);
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cm = Provider.of<ConfigModel>(context);
    _tm = Provider.of<ThemeModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: appInit(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        bool isInit = snapshot.data == true;
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || snapshot.data == null) {
            return const ErrorBoard();
          }

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: InnerDrawer(
              key: _innerDrawerKey,
              onTapClose: true,
              swipe: false,
              boxShadow: const [],
              colorTransitionChild: Colors.transparent,
              colorTransitionScaffold: Colors.transparent,
              offset: const IDOffset.only(top: 0.2, right: 0, left: 0),
              scale: const IDOffset.horizontal(1),
              proportionalChildArea: true,
              borderRadius: 8,
              leftAnimationType: InnerDrawerAnimation.quadratic,
              rightAnimationType: InnerDrawerAnimation.quadratic,
              backgroundDecoration: const BoxDecoration(color: Colors.white),
              leftChild: const QuickSettings(),
              scaffold: CupertinoPageScaffold(
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    isInit ? const VscPage() : const InitVscPage(),
                    Positioned(
                      bottom: isInit ? 130 : null,
                      top: isInit ? null : 30,
                      left: 10,
                      child: GestureDetector(
                        onTap: () {
                          _innerDrawerKey.currentState?.open();
                        },
                        child: const Icon(
                          UniconsLine.bars,
                          color: Color(0xFF4285f4),
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container(color: _tm.themeData.scaffoldBackgroundColor);
        }
      },
    );
  }
}
