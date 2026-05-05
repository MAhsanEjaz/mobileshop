import 'package:flutter/material.dart';

class SaleProductModel {
  String? date;
  String? imei;
  String? customerName;
  String? qty;
  String? customerPhone;
  String? salePrice;
  String? paymentMethod;
  String? salePart;

  SaleProductModel({this.imei,this.salePrice,this.paymentMethod,this.customerPhone,this.customerName,this.date,this.qty,this.salePart});

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'imei': imei,
      'qty': qty,
      'salePart': salePart,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'salePrice': salePrice,
      'paymentMethod': paymentMethod,
    };
  }


  factory SaleProductModel.fromJson(Map<String, dynamic> json) {
    return SaleProductModel(
      date: json['date'] as String?,
      imei: json['imei'] as String?,
      customerName: json['customerName'] as String?,
      qty: json['qty'] as String?,
      salePart: json['salePart'] as String?,
      customerPhone: json['customerPhone'] as String?,
      salePrice: json['salePrice'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );
  }
}
