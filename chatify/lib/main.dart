import 'package:camera/camera.dart';
import 'package:chatify/view/screens/camera_screen/camera_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:chatify/const_files/keys/shared_pref_keys.dart';
import 'package:chatify/const_files/my_color.dart';
import 'package:chatify/routes/app_routes.dart';
import 'package:chatify/routes/routes_names.dart';
import 'package:chatify/services/database_helper.dart';
import 'package:chatify/services/shared_pref.dart';
import 'package:chatify/view/screens/home/home_screen.dart';
import 'package:chatify/view/screens/register_section/terms_condition_screen.dart';
import 'package:chatify/view/theme/light_theme.dart';
import 'package:chatify/view/widgets/common_appbar.dart';
import 'package:chatify/view/widgets/common_scaffold.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await Firebase.initializeApp();
  await Permission.camera.request();
  await Permission.storage.request();
  await Permission.manageExternalStorage.request();
  cameras = await availableCameras();

  await DatabaseHelper().initDB();

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: MyColor.primaryColor));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WhatsAppClone',
      theme: lightTheme,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child ?? Container()),

      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.downToUp,
      initialRoute: RoutesNames.indexPage,
      getPages: AppRoutes.routes,
      // onInit: () {
      //   SharedPref().saveString(SharedPrefKeys.authToken,
      //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2MjJkY2I3MzViZDcyODUyZThjM2M4N2YiLCJpYXQiOjE2NDcxNzIwNjF9.vC6VwZmVyD5QMcTDR9BivsxPb3WqG4jr_3PJfm5ia34");
      // },
    );
  }
}

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  Widget? mainWidget;

  @override
  void initState() {
    initialCheckUp();
    super.initState();
  }

  Future<void> initialCheckUp() async {
    String authToken = await SharedPref().readString(SharedPrefKeys.authToken);

    if (authToken.isEmpty) {
      mainWidget = const TermsConditionScreen();
    } else {
      mainWidget = const HomeScreen();
    }
    setState(() {});
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return mainWidget ??
        const CommonScaffold(
            appBar: CommonAppBar(whiteBackground: true), body: SizedBox());
  }
}
