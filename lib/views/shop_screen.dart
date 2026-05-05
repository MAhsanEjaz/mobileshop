import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shopapp/main.dart';
import 'package:shopapp/models/shop_model.dart';
import 'package:shopapp/utils.dart';
import 'package:shopapp/views/nav_bar_screen.dart';
import 'package:shopapp/views/sign_in_screen.dart';
import 'package:shopapp/widgets/app_button.dart';
import 'package:shopapp/widgets/app_text_field.dart';

import '../controllers/shop_controller.dart';
import '../database.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool addShop = false;

  ShopController shopController = Get.find();
  String? imagePath;

  TextEditingController shopCont = TextEditingController();

  getShops() async {
    log('saveShop--->${shopData}');

    if (shopData != null) {
      Get.offAll(NavBarScreen());
    } else {
      await shopController.getShop();
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: shopController,
      builder: (cont) {
        return Scaffold(
          extendBodyBehindAppBar: true,

          appBar: AppBar(
            actions: [
              (cont.shop.isEmpty)
                  ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0),
                    child: InkWell(
                      onTap: () async {
                        await LocalDataBase.saveUser('');
                        Get.offAll(SignInScreen());
                        setState(() {});
                      },
                      child: Icon(Icons.logout, color: Colors.white),
                    ),
                  )
                  : (addShop == true)
                  ? InkWell(
                    onTap: () async {
                      imagePath = null;
                      shopCont.clear();
                      await cont.getShop();
                      addShop = false;
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  )
                  : SizedBox.shrink(),
            ],
            title: Text(
              (cont.shop.isEmpty || addShop) ? "Add Shop" : 'Shops',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: appColor,
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(
                    (addShop || cont.shop.isEmpty) ? 18.0 : 0,
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          (cont.shop.isEmpty || addShop == true)
                              ? dottedCard(cont)
                              : shopHomeCards(cont),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18.0),
                child: AppButton(
                  txt:
                      (cont.shop.isEmpty)
                          ? "Save"
                          : (addShop == true && cont.shop.isNotEmpty)
                          ? "Save"
                          : 'Add Shop',
                  onTap:
                      (cont.shop.isEmpty)
                          ? () {
                            Map<String, String> body = {
                              'name': shopCont.text.trim(),
                              "referenceUser": loginModelUser!.user!.sId!,
                            };

                            cont.shopAddFunction(body, imagePath!);
                            addShop = true;
                            setState(() {});
                          }
                          : (addShop == true && cont.shop.isNotEmpty)
                          ? () async {
                            Map<String, String> body = {
                              'name': shopCont.text.trim(),
                              "referenceUser": loginModelUser!.user!.sId!,
                            };

                            cont.shopAddFunction(body, imagePath!);
                          }
                          : () {
                            addShop = true;
                            setState(() {});
                          },
                  color: Colors.purple.shade400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget dottedCard(ShopController shop) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            final image = await shop.imagePickFunction(true);
            if (image != null) {
              imagePath = image;
              setState(() {});
            }
          },
          child: SizedBox(
            height: 200,
            width: double.infinity,

            child: DottedBorder(
              dashPattern: [6],
              color: Colors.white30,
              child:
                  imagePath != null
                      ? Image.file(
                        File(imagePath!),
                        height: 200,
                        width: Get.width,
                        fit: BoxFit.cover,
                      )
                      : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.photo_fill,
                              size: 40,
                              color: Colors.white38,
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Drop your photo',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        ),
        SizedBox(height: 23),
        AppTextField(hint: 'Shop Name', controller: shopCont),
      ],
    );
  }

  shopHomeCards(ShopController shop) {
    return Align(
      child: Wrap(
        children: [
          for (var l in shop.shop) ...[
            InkWell(
              onTap: () async {
                Get.offAll(NavBarScreen());

                final getSingleShop = shop.shop.firstWhere(
                  (e) => e.sId == l.sId,
                );
                log('shopData${jsonEncode(getSingleShop)}');

                await LocalDataBase.saveShopData(
                  json.encode(getSingleShop.toJson()),
                );

                // Fix: assign the whole object if shopData is null
                if (shopData == null) {
                  shopData = getSingleShop;
                } else {
                  shopData!
                    ..sId = getSingleShop.sId
                    ..name = getSingleShop.name
                    ..image = getSingleShop.image
                    ..referenceUser = getSingleShop.referenceUser;
                }

                setState(() {});
              },


              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width / 2.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: appColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3), // soft shadow
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: Offset(0, 6), // vertical shadow
                      ),
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        // subtle secondary shadow
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: '$apiBaseUrl${l.image}',
                          // fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          l.name!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
