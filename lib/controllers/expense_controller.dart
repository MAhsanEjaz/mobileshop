import 'package:get/get.dart';
import 'package:shopapp/models/expense_model.dart';
import 'package:shopapp/services/get_request.dart';
import 'package:shopapp/services/post_request.dart';
import 'package:shopapp/utils.dart';

class ExpenseController extends GetxController {
  List<ExpenseData> expense = [];

  bool isExpense = false;
   int totalExpense=0;

  addExpense(Map? body) async {
    loader();
    var res = await PostRequest.postRequest('addExpense', body);

    exitLoader();

    if (res['status'] != false) {
      customSnackBar('Success', res['message'], false);
      return true;
    } else {
      customSnackBar('Failed', res['message'], true);

      return false;
    }
  }

  closeExpense() {
    isExpense = false;
    update();
  }

  getExpense(String?startDate,String?endDate) async {
    loader();
    var res = await GetRequest.getRequest(
      'getExpense?startDate=${startDate}&endDate=${endDate.toString()}',
    );

    exitLoader();

    if (res['status'] != false) {
      isExpense = true;

      ExpenseModel expenseModel = ExpenseModel.fromJson(res);
      totalExpense = expenseModel.calculateTotalPrice!.toInt();
      expense = expenseModel.data!;
      update();
    }
  }
}
