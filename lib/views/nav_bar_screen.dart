import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shopapp/controllers/cash_controller.dart';
import 'package:shopapp/views/home_screen.dart';
import 'package:shopapp/views/stock_screen.dart';
import 'package:shopapp/views/user_screens/user_main_screen.dart';

import '../utils.dart';
import 'add_purchase_screen.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  final screens = [
    const HomeScreen(), // Home
    AddPurchaseScreen(), // Purchase Entry
    const StockScreen(), // Sale Entry (replace later with actual screen)
    const UserMainScreen(), // Profile (replace later with actual screen)
  ];

  CashController cashController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: cashController,
      builder: (cont) {
        return Scaffold(
          body: screens[cont.currentIndex],
          bottomNavigationBar: SafeArea(
            child: CircleNavBar(
              activeIndex: cont.currentIndex,
              onTap: (index) {
                setState(() => cont.currentIndex = index);
              },
              activeIcons: const [
                Icon(CupertinoIcons.house_fill, color: Colors.white),
                // Home
                Icon(CupertinoIcons.cart_fill_badge_plus, color: Colors.white),
                // Purchase
                Icon(CupertinoIcons.cart_fill_badge_minus, color: Colors.white),
                // Sale
                Icon(CupertinoIcons.person_circle_fill, color: Colors.white),
                // Profile
              ],
              inactiveIcons: const [
                Icon(CupertinoIcons.house, color: Colors.white),
                Icon(CupertinoIcons.cart_badge_plus, color: Colors.white),
                Icon(CupertinoIcons.cart_badge_minus, color: Colors.white),
                Icon(CupertinoIcons.person_circle, color: Colors.white),
              ],
              circleColor: appColor,
              color: appColor,
              height: 60,
              circleWidth: 55,
              shadowColor: Colors.black26,
              elevation: 8,
            ),
          ),
        );
      },
    );
  }
}
