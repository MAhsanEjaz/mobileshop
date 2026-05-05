import 'package:shopapp/models/shop_model.dart';

class LoginModel {
  bool? status;
  String? message;
  User? user;
  String? token;

  LoginModel({this.status, this.message, this.user, this.token});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}

class User {
  String? sId;
  String? name;
  String? email;
  String? password;
  String? role;
  String? shopId;
  int? iV;
  ShopData? shopData;

  User({
    this.sId,
    this.name,
    this.email,
    this.password,
    this.role,
    this.shopId,
    this.iV,
    this.shopData,
  });

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    role = json['role'];
    shopId = json['shopId'];
    iV = json['__v'];
    shopData =
        json['shopData'] != null
            ? new ShopData.fromJson(json['shopData'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['role'] = this.role;
    data['shopId'] = this.shopId;
    data['__v'] = this.iV;
    if (this.shopData != null) {
      data['shopData'] = this.shopData!.toJson();
    }
    return data;
  }
}

