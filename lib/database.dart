import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/models/user_model.dart';

import 'models/shop_model.dart';

class LocalDataBase {
  static saveUser(String? user) async {
    var prefs = await SharedPreferences.getInstance();

    prefs.setString('user', user!);
  }

  static getUser() async {
    var prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('user');
    return data;
  }

  static getUserData() async {
    var data = await getUser();

    // Check if data is null or empty
    if (data == null || data.trim().isEmpty) {
      return null;
    }

    try {
      Map<String, dynamic> userData = jsonDecode(data);
      return LoginModel.fromJson(userData);
    } catch (e) {
      print("JSON Decode Error: $e");
      return null;
    }
  }

  //shopLocalDatabase---------

  static saveShopData(String? shopData) async {
    var prefs = await SharedPreferences.getInstance();

    prefs.setString('shop', shopData!);
  }

  static getShop() async {
    var prefs = await SharedPreferences.getInstance();

    final shop = prefs.getString('shop');
    return shop;
  }

  static getShopData() async {
    var data = await getShop();
    if (data != null) {
      Map<String, dynamic> shopData = jsonDecode(data);
      return ShopData.fromJson(shopData);
    }
  }
}
