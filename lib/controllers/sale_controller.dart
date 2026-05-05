import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:shopapp/controllers/inventory_controller.dart';
import 'package:shopapp/main.dart';
import 'package:shopapp/models/sale_product_model.dart';
import 'package:shopapp/services/post_request.dart';
import 'package:shopapp/utils.dart';

class SaleController extends GetxController {
  List<SaleProductModel> sale = [];

  PurchaseInventoryController purchaseInventoryController = Get.put(
    PurchaseInventoryController(),
  );

  addSale(SaleProductModel? saleData) {
    sale.add(saleData!);
    log('saleData-->${saleData}');
    update();
  }

  clearSaleProduct() {
    sale.clear();
    update();
  }

  String? filePath;

  pickSaleFilePick() async {
    var fileData = await FilePicker.platform.pickFiles();
    if (fileData != null) {
      // filePath = fileData.files[0].name;
      filePath = fileData.files.single.path; // ✅ Correct
    }

    await importFromExcel(File(filePath!));

    log('json${jsonEncode(sale)}');

    update();
  }

  void makeEmpty() {
    filePath = null;
    sale.clear();
    update();
  }

  Future<void> importFromExcel(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        Get.snackbar('Error', 'No sheets found in Excel file');
        return;
      }

      final sheet = excel.tables.keys.first;
      final table = excel.tables[sheet]!;
      // sale.clear();

      for (int i = 1; i < table.rows.length; i++) {
        final row = table.rows[i];

        addSale(
          SaleProductModel(
            date: dateFormatWithName(row[0]?.value?.toString()),
            salePart: row[1]?.value?.toString(),
            qty: row[2]?.value?.toString(),

            imei: row[3]?.value?.toString(),

            customerName: row[4]?.value?.toString(),
            customerPhone: row[5]?.value?.toString(),
            salePrice: row[6]?.value?.toString(),
            paymentMethod: row[7]?.value?.toString(),
          ),
        );
      }

      update();
      log('✅ Excel import complete: ${sale.length} rows');
    } catch (e, st) {
      log('❌ Error reading Excel: $e\n$st');
      Get.snackbar('Error', 'Failed to read Excel file');
    }
  }

  saveInCloud() async {
    loader();
    Map<String, dynamic> body = {
      // 'saleData': jsonEncode(sale.map(((e) => e.toJson())).toList()),
      'saleData': sale,
      'userId': loginModelUser!.user!.sId,
      'shopId': shopData!.sId ?? loginModelUser!.user!.shopData!.sId,
    };

    print('json-->${jsonEncode(sale)}');
    var res = await PostRequest.postRequest('salewithList', body);

    exitLoader();

    if (res['status'] != false) {
      customSnackBar('Success', res['message'], false);

      purchaseInventoryController.getPurchases();
      return true;
    } else {
      customSnackBar('Failed', res['message'], true);

      return false;
    }
  }

  updateSalePart(Map<String, dynamic> body) async {
    loader();
    var res = await PostRequest.postRequest('updateSalePart', body);
    exitLoader();

    if (res['status'] != false) {
      purchaseInventoryController.paginationStock;
      purchaseInventoryController.paginationSale;
      purchaseInventoryController.sale;
      purchaseInventoryController.stock;
      purchaseInventoryController.stockSearch;
      purchaseInventoryController.saleSearch;
      purchaseInventoryController.page = 1;
      purchaseInventoryController.paginationSale.clear();
      purchaseInventoryController.paginationSale.clear();

      await purchaseInventoryController.getPurchases();

      exitLoader();

      update();

      return true;
    } else {
      return false;
    }
  }
}
