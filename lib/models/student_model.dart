class StudentModel {
  bool? status;
  List<StudentData>? data;

  StudentModel({this.status, this.data});

  StudentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <StudentData>[];
      json['data'].forEach((v) {
        data!.add(new StudentData.fromJson(v));
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

class StudentData {
  String? sId;
  String? name;
  String? className;
  String? cast;
  int? iV;

  StudentData({this.sId, this.name, this.className, this.cast, this.iV});

  StudentData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    className = json['className'];
    cast = json['cast'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['className'] = this.className;
    data['cast'] = this.cast;
    data['__v'] = this.iV;
    return data;
  }
}
