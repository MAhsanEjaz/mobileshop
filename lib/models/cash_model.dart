class CashModel {
  bool? status;
  List<CashData>? data;
  int? stock;
  num? totalProfit;

  CashModel({this.status, this.data, this.stock, this.totalProfit});

  CashModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <CashData>[];
      json['data'].forEach((v) {
        data!.add(new CashData.fromJson(v));
      });
    }
    stock = json['stock'];
    totalProfit = json['totalProfit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['stock'] = stock;
    data['totalProfit'] = totalProfit;
    return data;
  }
}

class CashData {
  String? imei;
  String? status;
  String? purchasePrice;
  String? date;
  String? qty;
  String? sId;
  MobileDetail? mobileDetail;
  String? salePrice;
  String? profit;

  CashData(
      {this.imei,
        this.status,
        this.purchasePrice,
        this.date,
        this.sId,
        this.qty,
        this.mobileDetail,
        this.salePrice,
        this.profit});

  CashData.fromJson(Map<String, dynamic> json) {
    imei = json['imei'];
    status = json['status'];
    purchasePrice = json['purchasePrice'];
    date = json['date'];
    qty = json['qty'];
    sId = json['_id'];
    mobileDetail = json['mobileDetail'] != null
        ? new MobileDetail.fromJson(json['mobileDetail'])
        : null;
    salePrice = json['salePrice'];
    profit = json['profit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['imei'] = imei;
    data['status'] = status;
    data['purchasePrice'] = purchasePrice;
    data['date'] = date;
    data['qty'] = qty;
    data['_id'] = sId;
    if (mobileDetail != null) {
      data['mobileDetail'] = mobileDetail!.toJson();
    }
    data['salePrice'] = salePrice;
    data['profit'] = profit;
    return data;
  }
}

class MobileDetail {
  List<String>? images;
  String? brand;
  String? model;
  String? storage;
  String? ram;
  String? productStatus;
  String? purchaserName;
  String? color;
  String? accessories;
  String? salePart;
  String? price;
  String? qty;

  MobileDetail(
      {this.images,
        this.brand,
        this.model,
        this.storage,
        this.productStatus,
        this.purchaserName,
        this.ram,
        this.qty,
        this.salePart,
        this.color,
        this.accessories,
        this.price});

  MobileDetail.fromJson(Map<String, dynamic> json) {
    images = json['images'].cast<String>();
    brand = json['brand'];
    model = json['model'];
    salePart = json['salePart'];
    storage = json['storage'];
    qty = json['qty'];
    productStatus = json['productStatus'];
    purchaserName = json['purchaserName'];
    ram = json['ram'];
    color = json['color'];
    accessories = json['accessories'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['images'] = images;
    data['brand'] = brand;
    data['model'] = model;
    data['storage'] = storage;
    data['qty'] = qty;
    data['productStatus'] = productStatus;
    data['purchaserName'] = purchaserName;
    data['ram'] = ram;
    data['color'] = color;
    data['salePart'] = salePart;
    data['accessories'] = accessories;
    data['price'] = price;
    return data;
  }
}
