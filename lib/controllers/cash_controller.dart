import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shopapp/main.dart';
import 'package:shopapp/models/cash_model.dart';
import 'package:shopapp/services/get_request.dart';
import 'package:shopapp/utils.dart';

class CashController extends GetxController {
  int currentIndex = 0;

  bool logout = false;

  onChangedState(int state) {
    currentIndex = state;
    update();
  }

  logOutApi() {
    logout = true;
    update();
  }

  logInApi() {
    logout = false;
    update();
  }

  List<CashData> purchase = [];
  List<CashData> totalSale = [];
  List<CashData> totalPurchase = [];
  List<CashData> searchModelList = [];

  getSearchData() {
    searchModelList = purchase;
    update();
  }

  searchFunction(String val) {
    searchModelList =
        purchase.where((element) {
          String imei = element.imei?.toLowerCase() ?? "";
          String? model = element.mobileDetail?.model?.toLowerCase() ?? "";
          String? brand = element.mobileDetail?.brand?.toLowerCase() ?? "";
          String? accessories =
              element.mobileDetail?.accessories?.toLowerCase();
          return imei.contains(val.toLowerCase()) ||
              model.contains(val.toLowerCase()) ||
              brand.contains(val.toLowerCase()) ||
              accessories!.contains(val.toLowerCase());
        }).toList();
    update();
  }

  int inStockItems = 0;
  num totalProfit = 0;

  getTotalSalePurchase() {
    totalSale.clear();
    totalPurchase.clear();

    for (var l in searchModelList) {
      if (l.status == 'sale') {
        totalSale.add(l);
      } if(l.status == 'stock') {
        totalPurchase.add(l);
      }
    }
    update();
  }

  getPurchases(String? startDate, String? endDate) async {
    loader();
    var res = await GetRequest.getRequest(
      'getCash?userId=${loginModelUser!.user!.sId}&startDate=$startDate&endDate=$endDate&shopId=${shopData?.sId ?? loginModelUser!.user!.shopData!.sId}',
    );

    exitLoader();


    if (res['status'] != false) {
      CashModel cashModel = CashModel.fromJson(res);
      purchase = cashModel.data!;
      inStockItems = cashModel.stock!;
      totalProfit = cashModel.totalProfit!;

      searchModelList = purchase;
    }

    await getTotalSalePurchase();
    update();
  }
}
