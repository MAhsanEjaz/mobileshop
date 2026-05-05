class AssignModel {
  String? name;
  String? assignDate;

  AssignModel({this.name, this.assignDate});

  Map<String, dynamic> toJson() {
    return {'name': name, 'assignDate': assignDate};
  }

  factory AssignModel.fromJson(Map<String, dynamic> json) {
    return AssignModel(assignDate: json['assignDate'], name: json['name']);
  }
}
