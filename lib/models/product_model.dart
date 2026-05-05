class ProductModel {
  bool? status;
  List<SaleProducts>? saleProducts;
  List<StockProducts>? stockProducts;

  ProductModel({this.status, this.saleProducts, this.stockProducts});

  ProductModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['saleProducts'] != null) {
      saleProducts = <SaleProducts>[];
      json['saleProducts'].forEach((v) {
        saleProducts!.add(new SaleProducts.fromJson(v));
      });
    }
    if (json['stockProducts'] != null) {
      stockProducts = <StockProducts>[];
      json['stockProducts'].forEach((v) {
        stockProducts!.add(new StockProducts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = status;
    if (saleProducts != null) {
      data['saleProducts'] = saleProducts!.map((v) => v.toJson()).toList();
    }
    if (stockProducts != null) {
      data['stockProducts'] =
          stockProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SaleProducts {
  String? productStatus;
  List<String>? images;
  String? imei;
  String? brand;
  String? date;
  String? model;
  String? storage;
  String? salePart;
  String? ram;
  String? color;
  String? condition;
  String? accessories;
  String? price;
  String? totalPrice;
  String? paymentMethod;
  String? sId;
  CustomerData? customerData;

  SaleProducts(
      {this.productStatus,
        this.images,
        this.imei,
        this.brand,
        this.model,
        this.storage,
        this.ram,
        this.date,
        this.color,
        this.condition,
        this.salePart,
        this.accessories,
        this.price,
        this.totalPrice,
        this.paymentMethod,
        this.sId,
        this.customerData});

  SaleProducts.fromJson(Map<String, dynamic> json) {
    productStatus = json['productStatus'];
    images = json['images'].cast<String>();
    imei = json['imei'];
    brand = json['brand'];
    salePart = json['salePart'];
    model = json['model'];
    storage = json['storage'];
    date = json['date'];
    ram = json['ram'];
    color = json['color'];
    condition = json['condition'];
    accessories = json['accessories'];
    price = json['price'];
    totalPrice = json['totalPrice'];
    paymentMethod = json['paymentMethod'];
    sId = json['_id'];
    customerData = json['customerData'] != null
        ? new CustomerData.fromJson(json['customerData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productStatus'] = productStatus;
    data['images'] = images;
    data['imei'] = imei;
    data['brand'] = brand;
    data['model'] = model;
    data['date'] = date;
    data['storage'] = storage;
    data['salePart'] = salePart;
    data['ram'] = ram;
    data['color'] = color;
    data['condition'] = condition;
    data['accessories'] = accessories;
    data['price'] = price;
    data['totalPrice'] = totalPrice;
    data['paymentMethod'] = paymentMethod;
    data['_id'] = sId;
    if (customerData != null) {
      data['customerData'] = customerData!.toJson();
    }
    return data;
  }
}

class CustomerData {
  String? imei;
  String? customerName;
  String? customerPhone;
  String? paymentMethod;
  String? qty;
  String? salePrice;
  String? date;
  String? sId;

  CustomerData({this.imei, this.customerName, this.customerPhone, this.sId,this.date,this.qty});

  CustomerData.fromJson(Map<String, dynamic> json) {
    imei = json['imei'];
    customerName = json['customerName'];
    customerPhone = json['customerPhone'];
    paymentMethod = json['paymentMethod'];
    qty = json['qty'];
    date = json['date'];
    salePrice = json['salePrice'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imei'] = imei;
    data['customerName'] = customerName;
    data['customerPhone'] = customerPhone;
    data['date'] = date;
    data['qty'] = qty;
    data['salePrice'] = salePrice;
    data['paymentMethod'] = paymentMethod;
    data['_id'] = sId;
    return data;
  }
}

class StockProducts {
  String? productStatus;
  List<String>? images;
  String? imei;
  String? brand;
  String? model;
  String? date;
  String? purchaserName;
  String? qty;
  String? storage;
  String? ram;
  String? color;
  String? condition;
  String? salePart;
  String? accessories;
  String? price;
  String? totalPrice;
  String? paymentMethod;
  String? sId;

  StockProducts(
      {this.productStatus,
        this.images,
        this.imei,
        this.salePart,
        this.brand,
        this.model,
        this.storage,
        this.qty,
        this.purchaserName,
        this.date,
        this.ram,
        this.color,
        this.condition,
        this.accessories,
        this.price,
        this.totalPrice,
        this.paymentMethod,
        this.sId});

  StockProducts.fromJson(Map<String, dynamic> json) {
    productStatus = json['productStatus'];
    images = json['images'].cast<String>();
    imei = json['imei'];
    brand = json['brand'];
    model = json['model'];
    storage = json['storage'];
    qty = json['qty'];
    purchaserName = json['purchaserName'];
    ram = json['ram'];
    salePart = json['salePart'];
    color = json['color'];
    date = json['date'];
    condition = json['condition'];
    accessories = json['accessories'];
    price = json['price'];
    totalPrice = json['totalPrice'];
    paymentMethod = json['paymentMethod'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productStatus'] = productStatus;
    data['images'] = images;
    data['imei'] = imei;
    data['brand'] = brand;
    data['model'] = model;
    data['qty'] = qty;
    data['storage'] = storage;
    data['date'] = date;
    data['ram'] = ram;
    data['purchaserName'] = purchaserName;
    data['salePart'] = salePart;
    data['color'] = color;
    data['condition'] = condition;
    data['accessories'] = accessories;
    data['price'] = price;
    data['totalPrice'] = totalPrice;
    data['paymentMethod'] = paymentMethod;
    data['_id'] = sId;
    return data;
  }
}
