import 'package:image_picker/image_picker.dart';

class PurchaseModel {
  List<XFile>? images;

  String? imei;
  String? date;
  String? brand;
  String? model;
  String? ram;
  String? storage;
  String? color;
  String? condition;
  String? accessories;
  String? salePart;
  String? qty;
  String? price;
  String? purchaserName;
  String? totalPrice;
  String? paymentMethod;

  PurchaseModel({
    this.color,
    this.model,
    this.price,
    this.totalPrice,
    this.date,
    this.images,
    this.qty,
    this.salePart,
    this.purchaserName,
    this.accessories,
    this.brand,
    this.condition,
    this.imei,
    this.paymentMethod,
    this.ram,
    this.storage,
  });

  Map<String, dynamic> toJson() {
    return {
      'image': images!.map((element) => element.path).toList(),
      'color': color,
      'model': model,
      'price': price,
      'qty': qty,
      'salePart': salePart,
      'date': date,
      'purchaserName': purchaserName,
      'totalPrice': totalPrice,
      'accessories': accessories,
      'brand': brand,
      'condition': condition,
      'imei': imei,
      'paymentMethod': paymentMethod,
      'ram': ram,
      'storage': storage,
    };
  }

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      images:
          (json['images'] as List<dynamic>?)
              ?.map((path) => XFile(path.toString()))
              .toList(),
      color: json['color'],
      model: json['model'],
      qty: json['qty'],
      date: json['date'],
      salePart: json['salePart'],
      price: json['price'],
      totalPrice: json['totalPrice'],
      purchaserName: json['purchaserName'],
      accessories: json['accessories'],
      brand: json['brand'],
      condition: json['condition'],
      imei: json['imei'],
      paymentMethod: json['paymentMethod'],
      ram: json['ram'],
      storage: json['storage'],
    );
  }
}
