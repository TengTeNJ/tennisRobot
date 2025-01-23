/// 原始机器人main函数
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:tennis_robot/connect/connect_robot_controller.dart';
// import 'package:tennis_robot/route/routes.dart';
// import 'package:tennis_robot/utils/navigator_util.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     NavigatorUtil.init(context);
//
//     return MaterialApp(
//       title: 'Flutter Demo',
//       onGenerateRoute: Routes.onGenerateRoute,
//       home: ConnectRobotController(),
//       //home: RobotConnectionPage(),
//       builder: EasyLoading.init(),
//     );
//   }
// }
/// 建图定位 图传通信机器人main函数
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gamepads/gamepads.dart';
import 'package:tennis_robot/court/court_list_controller.dart';
import 'package:tennis_robot/global/setting.dart';
import 'package:tennis_robot/page/court_map_page.dart';
import 'package:tennis_robot/provider/global_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennis_robot/route/routes.dart';
import 'package:tennis_robot/trainmode/train_mode_controller.dart';
import 'package:tennis_robot/utils/navigator_util.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tennis_robot/page/map_page.dart';
import 'package:tennis_robot/page/robot_connect_page.dart';
import 'package:tennis_robot/provider/ros_channel.dart';
import 'package:tennis_robot/page/setting_page.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'provider/them_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _setInitialOrientation();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<RosChannel>(create: (_) => RosChannel()),
    ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ChangeNotifierProvider<GlobalState>(create: (_) => GlobalState())
  ], child: MyApp()));
}

Future<void> _setInitialOrientation() async {
  ///  landscape 横屏     portrait 竖屏
  final prefs = await SharedPreferences.getInstance();
  final orientationValue = prefs.getString('screenOrientation') ?? 'portrait';
  if (orientationValue == 'portrait') {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } else {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    // 关闭系统状态栏的显示
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    WakelockPlus.toggle(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    NavigatorUtil.init(context);

    return MaterialApp(
      onGenerateRoute: Routes.onGenerateRoute,
      title: 'Ros Flutter GUI App',
      initialRoute: "/connect",
      routes: {
        "/connect": ((context) => RobotConnectionPage()),
        "/map": ((context) => MapPage(nextTitle: '',)),
        "/setting": ((context) => SettingsPage()),
        "/court": ((context) => CourtMapPage()),
        "/courtList":((context) => CourtListController()),
        "/train":((context) => TrainModeController()),
      },
      themeMode: Provider.of<ThemeProvider>(context, listen: true).themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blue,
          secondary: Colors.blue[50],
          background: Color.fromRGBO(240, 240, 240, 1),
          surface: Color.fromARGB(153, 224, 224, 224),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, // 设置全局图标颜色为绿色
        ),
        cardColor: Color.fromRGBO(230, 230, 230, 1),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(elevation: 0),
        chipTheme: ThemeData.light().chipTheme.copyWith(
          backgroundColor: Colors.white,
          elevation: 10.0,
          shape: StadiumBorder(
            side: BorderSide(
              color: Colors.grey[300]!, // 设置边框颜色
              width: 1.0, // 设置边框宽度
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme:
        ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
          primary: Colors.blue,
          secondary: Colors.blueGrey,
          surface: Color.fromRGBO(60, 60, 60, 1),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
        cardColor: Color.fromRGBO(230, 230, 230, 1),
        scaffoldBackgroundColor: Color.fromRGBO(40, 40, 40, 1),
        appBarTheme: AppBarTheme(elevation: 0),
        iconTheme: IconThemeData(
          color: Colors.white, // 设置全局图标颜色为绿色
        ),
        chipTheme: ThemeData.dark().chipTheme.copyWith(
          backgroundColor: Color.fromRGBO(60, 60, 60, 1),
          elevation: 10.0,
          shape: StadiumBorder(
            side: BorderSide(
              color: Colors.white, // 设置边框颜色
              width: 1.0, // 设置边框宽度
            ),
          ),
        ),
      ),
      home: RobotConnectionPage(),
      builder: EasyLoading.init(),
    );
  }
}


