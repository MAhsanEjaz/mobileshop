import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shopapp/controllers/cash_controller.dart';
import 'package:shopapp/controllers/expense_controller.dart';
import 'package:shopapp/controllers/inventory_controller.dart';
import 'package:shopapp/database.dart';

import 'package:shopapp/views/expanded_screen.dart';
import 'package:shopapp/views/nav_bar_screen.dart';
import 'package:shopapp/views/quiz_app_view.dart';
import 'package:shopapp/views/shop_screen.dart';
import 'controllers/shop_controller.dart';
import 'controllers/user_controller.dart';
import 'models/shop_model.dart';
import 'models/student_screen.dart';
import 'models/user_model.dart';
import 'views/sign_in_screen.dart';

LoginModel? loginModelUser;
ShopData? shopData;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  Get.put(CashController(), permanent: true);
  Get.put(PurchaseInventoryController(), permanent: true);
  Get.put(UserController(), permanent: true);
  Get.put(ExpenseController(), permanent: true);
  Get.put(ShopController(), permanent: true);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  getUser() async {
    var user = await LocalDataBase.getUserData();
    if (user != null) {
      loginModelUser = user;
      log('user--->${jsonEncode(loginModelUser)}');
    }
    setState(() {});
  }

  getShop() async {
    var shop = await LocalDataBase.getShopData();
    if (shop != null) {
      shopData = shop;
    }
    log('shop--->${jsonEncode(shopData)}');

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    getShop();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(.9)),
          child: child!,
        );
      },
      title: 'Mobile Shop',
      debugShowCheckedModeBanner: false,
      home: userNavigation(),

      // home: StudentScreen(),
      theme: ThemeData(
        fontFamily: 'Rubik',
        appBarTheme: AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
      ),
    );
  }

  userNavigation() {
    if (loginModelUser != null && loginModelUser!.user != null) {
      if (loginModelUser!.user!.shopData != null) {
        return NavBarScreen();
      } else {
        return ShopScreen();
      }
    } else {
      return SignInScreen();
    }
  }
}
