class ExpenseModel {
  bool? status;
  List<ExpenseData>? data;
  int? calculateTotalPrice;

  ExpenseModel({this.status, this.data, this.calculateTotalPrice});

  ExpenseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <ExpenseData>[];
      json['data'].forEach((v) {
        data!.add(new ExpenseData.fromJson(v));
      });
    }
    calculateTotalPrice = json['calculateTotalPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['calculateTotalPrice'] = this.calculateTotalPrice;
    return data;
  }
}

class ExpenseData {
  String? sId;
  String? title;
  String? amount;
  String? description;
  String? date;
  int? iV;

  ExpenseData(
      {this.sId,
        this.title,
        this.amount,
        this.description,
        this.date,
        this.iV});

  ExpenseData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    amount = json['amount'];
    description = json['description'];
    date = json['date'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['amount'] = this.amount;
    data['description'] = this.description;
    data['date'] = this.date;
    data['__v'] = this.iV;
    return data;
  }
}
