import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shopapp/controllers/cash_controller.dart';
import 'package:shopapp/controllers/inventory_controller.dart';
import 'package:shopapp/controllers/shop_controller.dart';

import 'package:shopapp/controllers/user_controller.dart';
import 'package:shopapp/database.dart';
import 'package:shopapp/main.dart';
import 'package:shopapp/utils.dart';
import 'package:shopapp/views/sign_in_screen.dart';
import 'package:shopapp/widgets/animated_widget.dart';
import 'package:shopapp/widgets/app_button.dart';
import 'package:shopapp/widgets/app_text_field.dart';
import 'package:shopapp/widgets/custom_dropdown.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  Map<int, Widget> children = {0: Text('Profile'), 1: Text('Registration')};

  TextEditingController nameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  String? shopId;
  String? shopTitle;

  int onChanged = 0;

  List<String> role = ['Admin', 'User'];

  String? selectRole;

  UserController userController = Get.put(UserController());
  ShopController shopController = Get.find();
  CashController cashController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: userController,
      builder: (cont) {
        return Scaffold(
          body: CustomAnimatedCard(
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl(
                        children: children,
                        groupValue: onChanged,
                        onValueChanged: (val) {
                          if (loginModelUser!.user!.role == 'user') {
                            customSnackBar(
                              'Access Denied',
                              'Your account does not have permission to add a new user.',
                              true,
                            );

                            return;
                          } else {
                            onChanged = val!;
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 15),

                            if (onChanged == 0) ...[
                              profileCard(cont),
                            ] else ...[
                              AppTextField(hint: 'Name', controller: nameCont),
                              AppTextField(
                                hint: 'Email',
                                controller: emailCont,
                                textInputType: TextInputType.emailAddress,
                              ),
                              AppTextField(
                                hint: 'Password',
                                controller: passwordCont,
                                obscureText: true,
                                textInputType: TextInputType.visiblePassword,
                              ),

                              CustomDropdown(
                                items: role,
                                filled: true,
                                onTap: (v) {
                                  selectRole = v!.toLowerCase();

                                  setState(() {});
                                },
                                title: selectRole?.toUpperCase(),
                              ),
                              SizedBox(height: 5),

                              selectRole == 'admin'
                                  ? SizedBox.shrink()
                                  : GetBuilder(
                                    init: shopController,
                                    builder: (shopCont) {
                                      return CustomDropdown(
                                        items:
                                            shopCont.shop
                                                .map((e) => e.name ?? '')
                                                .toList(),
                                        onTap: (v) {
                                          final title = shopCont.shop
                                              .firstWhere((e) => e.name == v);
                                          shopTitle = title.name;
                                          shopId = title.sId;
                                          log('shopId-->$shopId');
                                          setState(() {});
                                        },
                                        filled: true,
                                        title: shopTitle ?? 'Select Shop',
                                      );
                                    },
                                  ),

                              SizedBox(height: 10),

                              cont.loading
                                  ? CircularProgressIndicator(
                                    year2023: false,
                                    strokeWidth: .7,
                                  )
                                  : AppButton(
                                    width: double.infinity,
                                    height: 45,
                                    onTap: () {
                                      Map<String, dynamic> body = {
                                        "name": nameCont.text.trim(),
                                        "email": emailCont.text.trim(),
                                        "password": passwordCont.text.trim(),
                                        "role": selectRole,
                                        "shopId": shopId,
                                      };
                                      cont.register(body);
                                    },
                                    txt: 'Register',
                                  ),
                            ],
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
    );
  }

  Widget profileCard(UserController cont) {
    return Column(
      children: [
        // Profile Header
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    loginModelUser!.user?.email != null
                        ? NetworkImage(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQCNd2LZxcvUCyW1N5UVQJ9fejpX2Yf3oW4aA&s',
                        )
                        : null,
                child:
                    loginModelUser!.user?.email == null
                        ? Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey.shade700,
                        )
                        : null,
              ),
              const SizedBox(height: 10),
              Text(
                loginModelUser!.user?.name ?? 'Guest User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                loginModelUser!.user?.email ?? 'example@email.com',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Profile Details Card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Role'),
                  subtitle: Text(
                    loginModelUser!.user?.role?.capitalizeFirst ??
                        'Not Assigned',
                  ),
                ),
                Divider(),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(loginModelUser!.user?.email ?? 'Not Provided'),
                ),
                loginModelUser!.user!.shopData != null
                    ? Divider()
                    : SizedBox.shrink(),
                loginModelUser!.user!.shopData != null
                    ? ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          '$apiBaseUrl${loginModelUser!.user!.shopData!.image}',
                        ),
                      ),
                      title: Text(loginModelUser!.user!.shopData!.name!),
                      subtitle: Text(
                        loginModelUser!.user?.shopId ?? 'Not Provided',
                      ),
                    )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),

        SizedBox(height: 20), // Logout Button
        GetBuilder(
          init: cashController,
          builder: (cash) {
            return AppButton(
              txt: 'Logout',
              width: double.infinity,
              height: 45,
              onTap: () {
                Get.defaultDialog(
                  title: 'Logout',
                  middleText: 'Are you sure you want to logout?',
                  textCancel: 'Cancel',
                  textConfirm: 'Yes',
                  confirmTextColor: Colors.white,
                  onConfirm: () async {

                    final purchase = Get.find<PurchaseInventoryController>();

                    cash.logOutApi();

                    await LocalDataBase.saveShopData('');

                    shopData = null;
                    await LocalDataBase.saveUser(''); // Save empty string


                    purchase.clearData();

                    purchase.update();

                    Get.offAll(() => SignInScreen());

                    cash.onChangedState(0);

                    // Show logout message
                    Get.snackbar(
                      'Logout',
                      'Logged out successfully',
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
