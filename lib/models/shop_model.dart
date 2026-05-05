class ShopModel {
  bool? status;
  List<ShopData>? data;

  ShopModel({this.status, this.data});

  ShopModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <ShopData>[];
      json['data'].forEach((v) {
        data!.add(new ShopData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ShopData {
  String? sId;
  String? name;
  String? image;
  String? referenceUser;
  String? createdAt;
  String? updatedAt;
  int? iV;

  ShopData(
      {this.sId,
        this.name,
        this.image,
        this.referenceUser,
        this.createdAt,
        this.updatedAt,
        this.iV});

  ShopData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
    referenceUser = json['referenceUser'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['image'] = this.image;
    data['referenceUser'] = this.referenceUser;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
