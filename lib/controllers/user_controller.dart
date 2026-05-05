import 'dart:convert';

// import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopapp/database.dart';
import 'package:shopapp/utils.dart';

import '../main.dart';
import '../models/user_model.dart';
import '../services/post_request.dart';
import '../views/nav_bar_screen.dart';
import '../views/shop_screen.dart';

class UserController extends GetxController {
  bool loading = false;

  register(Map? body) async {
    try {
      loading = true;
      update();

      var res = await PostRequest.postRequest('register', body);
      loading = false;
      update();

      if (res['status'] != false) {
        customSnackBar('Success', res['message'], false);
        return true;
      } else {
        return false;
      }
    } catch (err) {
      print(err);
      loading = false;
      update();
      return false;
    }
  }

  login(Map? body) async {
    try {
      loading = true;

      update();

      var res = await PostRequest.postRequest('login', body);
      loading = false;
      update();

      if (res['status'] != false) {
        // LoginModel loginModel = LoginModel.fromJson(res);

        final loginModel = await compute(loginIsolateFunction, jsonEncode(res));

        await LocalDataBase.saveUser(jsonEncode(loginModel.toJson()));

        loginModelUser = loginModel;

        if (loginModel.user?.role == 'user') {
          if (loginModel.user?.shopData == null) {
            customSnackBar('Failed', 'No Shop Found', true);
            return;
          }

          Get.offAll(NavBarScreen());
        } else {
          Get.offAll(ShopScreen());
        }
        customSnackBar('Success', res['message'], false);

        return true;
      } else {
        customSnackBar('Failed', res['message'], true);

        return false;
      }
    } catch (err) {
      loading = false;
      update();
      return false;
    }
  }
}

LoginModel loginIsolateFunction(String data) {
  final Map<String, dynamic> response = jsonDecode(data);

  return LoginModel.fromJson(response);
}
