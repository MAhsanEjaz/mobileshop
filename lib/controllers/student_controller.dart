import 'package:get/get.dart';
import 'package:shopapp/services/get_request.dart';

import '../models/student_model.dart';

class StudentController extends GetxController {
  List<StudentData> students = [];

  getAllStudents() async {
    var res =await GetRequest.getRequest('getStudents');
    if (res['status'] != false) {
      StudentModel studentModel = StudentModel.fromJson(res);
      students = studentModel.data!;
      update();
    }
  }

  searchApi(String?query) async {
    var res = await GetRequest.getRequest('getSearchStudents?search=$query');

    if (res['status'] != false) {
      StudentModel studentModel = StudentModel.fromJson(res);
      students = studentModel.data!;
      update();
    }
  }
}
