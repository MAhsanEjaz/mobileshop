import 'dart:convert';
import 'dart:developer';
import 'dart:io';

// import 'package:excel/excel.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart' show FilePicker, FileType;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shopapp/controllers/cash_controller.dart';
import 'package:shopapp/main.dart';
import 'package:shopapp/services/get_request.dart';
import 'package:shopapp/services/post_request.dart';
import 'package:shopapp/utils.dart';

import '../models/cash_model.dart';
import '../models/product_model.dart';
import '../models/purchase_model.dart';
import '../widgets/purchase_entry_card.dart';

import 'package:http/http.dart' as http;

class PurchaseInventoryController extends GetxController {
  List<PurchaseEntryCard> purchase = [];

  CashController cashController = Get.find();

  bool stockVisible = false;

  CashModel? cashData;

  List<PurchaseModel> model = [];

  List<SaleProducts> sale = [];
  List<StockProducts> stock = [];
  List<StockProducts> paginationStock = [];
  List<SaleProducts> paginationSale = [];

  List<SaleProducts> saleSearch = [];
  List<StockProducts> stockSearch = [];

  bool paginationOff = false;

  paginOff(bool pagin) {
    paginationOff = pagin;
    update();
  }

  searchQueryForSale(String searchQuery) {
    final search = searchQuery.toLowerCase().trim();

    saleSearch =
        paginationSale.where((element) {
          String imei = element.imei!.toLowerCase();
          String model =
              '${element.model!.toLowerCase()}${element.brand!.toLowerCase()}';
          String accessories = element.accessories!.toLowerCase();

          return imei.contains(search) ||
              model.contains(search) ||
              accessories.contains(search);
        }).toList();
    update();
  }

  searchQueryForStock(String searchQuery) {
    final search = searchQuery.toLowerCase().trim();

    stockSearch =
        paginationStock.where((element) {
          String imei = element.imei!.toLowerCase();
          String model =
              '${element.model!.toLowerCase()}${element.brand!.toLowerCase()}';
          String accessories = element.accessories!.toLowerCase();

          return imei.contains(search) ||
              model.contains(search) ||
              accessories.contains(search);
        }).toList();
    update();
  }

  List<TextEditingController> imeiCont = [];
  List<TextEditingController> brandCont = [];
  List<TextEditingController> modelCont = [];
  List<TextEditingController> ramCont = [];
  List<TextEditingController> storageCont = [];
  List<TextEditingController> colorCont = [];
  List<TextEditingController> accessCont = [];
  List<TextEditingController> priceCont = [];
  List<TextEditingController> accesoriesTotalPrice = [];
  List<TextEditingController> totalPriceCont = [];
  List<TextEditingController> purchaserName = [];
  List<TextEditingController> qty = [];
  List<TextEditingController> date = [];
  List<String> storage = [];
  List<String> ram = [];
  List<String> payment = [];
  List<String> condition = [];
  List<String> brand = [];
  List<int> colorIndex = [];
  List<int> ramIndex = [];
  List<int> storageIndex = [];
  List<int?> brandIndex = [];
  List<String?> salePart = [];

  addPurchaseInventory() {
    purchase.add(PurchaseEntryCard());
    imeiCont.add(TextEditingController());
    brandCont.add(TextEditingController());
    modelCont.add(TextEditingController());
    ramCont.add(TextEditingController());
    purchaserName.add(TextEditingController());
    storageCont.add(TextEditingController());
    colorCont.add(TextEditingController());
    priceCont.add(TextEditingController());
    qty.add(TextEditingController());
    totalPriceCont.add(TextEditingController());
    accessCont.add(TextEditingController());
    accesoriesTotalPrice.add(TextEditingController());
    storage.add('4GB');
    ram.add('1GB');
    date.add(TextEditingController());
    payment.add('');
    condition.add('');
    files.add(<XFile>[]);
    colorIndex.add(0);
    ramIndex.add(0);
    storageIndex.add(0);
    brandIndex.add(null); // works fine
    brand.add('');
    salePart.add('Mobile');
    update();
  }

  List<List<XFile>> files = [];

  List<XFile> updateImageFile = [];

  updateWithImageGalPick() async {
    final images = await ImagePicker().pickMultiImage();

    updateImageFile.addAll(images);
    update();
  }

  updateWithImageCamPick() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      updateImageFile.add(image); // ✅ correct
    }
    update();
  }

  Future<void> imagePickFunction(int index) async {
    final images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      files[index].addAll(images);
      update();
    }
  }

  Future<void> imagePickCamera(int index) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      files[index].add(image!);

      update();
    }
  }

  removePurchaseEntryCard() {
    purchase.clear();
    // ✅ Remove controllers
    imeiCont.clear();
    brandCont.clear();
    accessCont.clear();
    purchaserName.clear();
    modelCont.clear();
    ramCont.clear();
    storageCont.clear();
    colorCont.clear();
    priceCont.clear();
    totalPriceCont.clear();
    date.clear();

    // ✅ Remove lists
    files.clear();
    storage.clear();
    ram.clear();
    condition.clear();
    payment.clear();

    // ✅ Remove indexes
    colorIndex.clear();
    ramIndex.clear();
    storageIndex.clear();
    brandIndex.clear();

    update();
  }

  bool validation() {
    for (int i = 0; i < date.length; i++) {
      if (date[i].text.isEmpty) {
        customSnackBar('Failed', 'Enter Date', true);
        return false;
      }

      if (imeiCont[i].text.isEmpty) {
        if (salePart[i] == 'Accessories') {
          customSnackBar('Failed', 'Enter Product Code', true);
        } else {
          customSnackBar('Failed', 'Enter Imei', true);
        }
        return false;
      }

      if (salePart[i] == 'Mobile') {
        if (brandCont[i].text.isEmpty) {
          customSnackBar('Failed', 'Select mobile brand', true);
          return false;
        }
      }
      if (salePart[i] == 'Mobile') {
        if (modelCont[i].text.isEmpty) {
          customSnackBar('Failed', 'Enter mobile model', true);
          return false;
        }
      }

      if (accessCont[i].text.isEmpty) {
        customSnackBar('Failed', 'Enter Accessory Detail', true);
        return false;
      }
      if (priceCont[i].text.isEmpty) {
        customSnackBar('Failed', 'Enter Price', true);
        return false;
      }
    }
    return true;
  }

  saveModelData() {
    for (int i = 0; i < imeiCont.length; i++) {
      model.add(
        PurchaseModel(
          color: colorCont[i].text,
          price: priceCont[i].text,
          totalPrice: totalPriceCont[i].text,
          brand: brandCont[i].text,
          imei: imeiCont[i].text,
          storage: storage[i].toString(),
          date: date[i].text,
          salePart: salePart[i],
          model: modelCont[i].text,
          qty: qty[i].text,
          accessories: accessCont[i].text,
          ram: ram[i].toString(),
          condition: condition[i],
          paymentMethod: payment[i],
          purchaserName: purchaserName[i].text,
          images: files[i].map((element) => element).toList(),
        ),
      );
    }
    log(jsonEncode(model));

    update();
  }

  deleteItem(Map? body, String? startDate, String? endDate) async {
    loader();

    var res = await PostRequest.postRequest('deleteItems', body);
    exitLoader();

    if (res['status'] != false) {
      paginationStock.clear();
      paginationSale.clear();
      saleSearch.clear();
      stockSearch.clear();
      sale.clear();
      stock.clear();

      await getPurchases(
        customUrl:
            'getPurchaseWithPagi/?userId=${loginModelUser!.user!.sId}'
            '&shopId=${shopData?.sId ?? loginModelUser!.user!.shopData!.sId}'
            '&startDate=${startDate.toString()}&endDate=${endDate.toString()}',
      );
      exitLoader();

      update();

      return true;
    } else {
      return false;
    }
  }

  updateInventory(StockProducts stock, int i) async {
    loader();

    paginationStock.clear();
    paginationSale.clear();

    http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse('${apiBaseUrl}updateItemOld'),
    );

    request.fields.addAll({
      "itemId": stock.sId!,
      "qty": qty[i].text,
      "imei": imeiCont[i].text,
      "brand": brandCont[i].text,
      "model": modelCont[i].text,
      "purchaserName": purchaserName[i].text,
      "salePart": salePart[i]!,
      "storage": storage[i],
      "ram": ram[i],
      "color": colorCont[i].text,
      "condition": condition[i],
      "accessories": accessCont[i].text,
      "price": priceCont[i].text,
      "totalPrice": priceCont[i].text,
      "paymentMethod": payment[i],
    });

    if (stock.images != null) {
      for (var l in stock.images!) {
        request.fields['images'] = l;
      }
    }
    if (updateImageFile.isNotEmpty) {
      for (var l in updateImageFile) {
        // request.files.add(await http.MultipartFile.fromPath('images', l.path));

        log('not empted multer');
        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // MUST match multer field
            l.path,
          ),
        );
      }
    }

    var response = await request.send();

    exitLoader();

    update();

    if (response.statusCode == 200) {
      await getPurchases();
      return true;
    } else {
      return false;
    }
  }

  purchaseService() async {
    try {
      model.clear();

      loader();

      await saveModelData();

      http.MultipartRequest request = http.MultipartRequest(
        'Post',
        Uri.parse('${apiBaseUrl}addPurchase'),
      );
      log('userId-->${loginModelUser!.user!.sId!}');
      request.fields.addAll({
        'purchase': json.encode(model.map((e) => e.toJson()).toList()),
        'userId': loginModelUser!.user!.sId!,
        'shopId': shopData?.sId ?? loginModelUser!.user!.shopData!.sId!,
      });

      for (int i = 0; i < model.length; i++) {
        for (var img in model[i].images!) {
          request.files.add(
            await http.MultipartFile.fromPath('images_$i', img.path),
          );
        }
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);
      exitLoader();

      print("body-->${decoded}");

      if (response.statusCode == 200) {
        if (decoded["message"] ==
            "One or more products already exist in stock") {
          return customSnackBar("Failed", decoded["message"], true);
        }

        await getCash();
        stockVisible = false;
        model.clear();
        purchase.clear();
        paginationStock.clear();
        paginationSale.clear();
        saleSearch.clear();
        stockSearch.clear();
        sale.clear();
        stock.clear();
        files.clear();

        customSnackBar(
          decoded["status"] == false ? "Failed" : "Success",
          decoded["message"],
          decoded["status"] == false ? true : false,
        );
        model.clear();

        removePurchaseEntryCard();
        update();
        print('success');
        return true;
      } else {
        customSnackBar(
          decoded["status"] == false ? "Failed" : "Success",
          decoded["message"],
          decoded["status"] == false ? true : false,
        );
        return false;
      }
    } catch (err) {
      exitLoader();
      customSnackBar("Failed", err.toString(), true);
    }
  }

  String? sDate;
  String? eDate;

  int page = 1;

  bool firstTimeLoading = true;

  bool onlySaleTimeClearPagination = false;

  getPurchases({String? startDate, String? endDate, String? customUrl}) async {
    try {
      if (firstTimeLoading) {
        loader();
      }

      sale.clear();
      stock.clear();

      var now = DateTime.now();
      var firstDate = DateTime(now.year, now.month, 1);
      var lastDate = DateTime(now.year, now.month + 1, 0);

      var res = await GetRequest.getRequest(
        customUrl ??
            'getPurchaseWithPagi/?userId=${loginModelUser!.user!.sId}'
                '&shopId=${shopData?.sId ?? loginModelUser!.user!.shopData!.sId}'
                '&page=$page&limit=20&startDate=${startDate ?? dateFormatWithName(firstDate.toString())}&endDate=${endDate ?? dateFormatWithName(lastDate.toString())}',
      );
      if (firstTimeLoading) {
        exitLoader();
      }

      if (res['status'] != false) {
        ProductModel productModel = ProductModel.fromJson(res);

        sale = productModel.saleProducts ?? [];
        stock = productModel.stockProducts ?? [];

        paginationSale.addAll(sale);
        paginationStock.addAll(stock);

        saleSearch = List.from(paginationSale);
        stockSearch = List.from(paginationStock);

        firstTimeLoading = false;
        update();
      }
    } catch (err) {
      print(err);
      exitLoader();
    }
  }

  ScrollController scrollController = ScrollController();

  bool isLoadingMore = false;

  pageUpdate() {
    page = 1;
    paginationStock.clear();
    paginationSale.clear();
    sale.clear();
    stock.clear();
    saleSearch.clear();
    stockSearch.clear();
    update();
  }

  void purchasePaginationControls() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore) {
        isLoadingMore = true;
        update();

        page++;
        await getPurchases();

        isLoadingMore = false;
        update();
      }
    });
  }

  TextEditingController saleDate = TextEditingController();

  getCash() async {
    final date = DateTime.now();
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);
    await cashController.getPurchases(
      dateFormatWithName(start.toString()),
      dateFormatWithName(end.toString()),
    );
  }

  saleItem(body) async {
    try {
      loader();
      var res = await PostRequest.postRequest('saleWithSingle', body);
      if (res['status'] != false) {
        await getCash();
        Navigator.pop(Get.context!);

        page = 1;
        paginationStock.clear();
        paginationSale.clear();
        await getPurchases();
        Navigator.pop(Get.context!);
        return true;
      } else {
        return false;
      }
    } catch (err) {
      customSnackBar("Failed", err.toString(), true);
      exitLoader();
    }
  }

  String? filePath;

  filePick() async {
    // var permis = await Permission.storage.request();
    // if (!permis.isGranted) {
    //   openAppSettings();
    //   return;
    // }

    try {
      final fileData = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx'], // Supports all Excel formats
      );

      if (fileData != null && fileData.files.isNotEmpty) {
        final picked = fileData.files.first;
        if (picked.path == null) {
          Get.snackbar('Error', 'Invalid file path');
          return;
        }

        filePath = picked.path!;
        await importFromExcel(File(filePath!));
      } else {
        Get.snackbar('No File', 'No file selected');
      }
    } catch (e) {
      Get.snackbar('Error', 'File picker failed: $e');
    }
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

      removePurchaseEntryCard();

      for (int i = 1; i < table.rows.length; i++) {
        final row = table.rows[i];
        if (row.isEmpty || row.every((c) => c?.value == null)) continue;

        addPurchaseInventory();
        int last = imeiCont.length - 1;

        final firstCell = row[0]?.value?.toString().toLowerCase().trim() ?? '';

        // =========================
        // 🟡 ACCESSORIES (HAS TYPE)
        // =========================
        if (firstCell == 'accessories') {
          salePart[last] = 'Accessories';

          date[last].text = dateFormatWithName(row[1]?.value?.toString()) ?? '';
          purchaserName[last].text = row[2]?.value?.toString() ?? '';

          qty[last].text = row[3]?.value?.toString() ?? '';
          imeiCont[last].text = row[4]?.value?.toString() ?? ''; // Product Code

          condition[last] = row[5]?.value?.toString() ?? '';
          accessCont[last].text = row[6]?.value?.toString() ?? '';

          priceCont[last].text = numberFormat(
            num.tryParse(row[7]?.value?.toString() ?? '') ?? 0,
          );

          accesoriesTotalPrice[last].text = row[8]?.value?.toString() ?? '';

          payment[last] = row[9]?.value?.toString() ?? '';

          // clear mobile-only fields
          brandCont[last].clear();
          modelCont[last].clear();
          ramCont[last].clear();
          storageCont[last].clear();
          colorCont[last].clear();
        }
        // =========================
        // 🔵 MOBILE (NO TYPE)
        // =========================
        else {
          salePart[last] = 'Mobile';

          date[last].text = dateFormatWithName(row[0]?.value?.toString()) ?? '';
          purchaserName[last].text = row[1]?.value?.toString() ?? '';

          imeiCont[last].text = row[2]?.value?.toString() ?? '';
          brandCont[last].text = row[3]?.value?.toString() ?? '';
          modelCont[last].text = row[4]?.value?.toString() ?? '';
          ramCont[last].text = row[5]?.value?.toString() ?? '';
          storageCont[last].text = row[6]?.value?.toString() ?? '';
          colorCont[last].text = row[7]?.value?.toString() ?? '';
          accessCont[last].text = row[8]?.value?.toString() ?? '';

          priceCont[last].text = numberFormat(
            num.tryParse(row[9]?.value?.toString() ?? '') ?? 0,
          );

          totalPriceCont[last].text = row[10]?.value?.toString() ?? '';

          condition[last] = row[11]?.value?.toString() ?? '';
          payment[last] = row[12]?.value?.toString() ?? '';

          ram[last] = ramCont[last].text;
          storage[last] = storageCont[last].text;
          brand[last] = brandCont[last].text;
        }
      }

      update();
      log('✅ Excel import complete (Accessories + Mobile)');
    } catch (e, st) {
      log('❌ Error reading Excel: $e\n$st');
      Get.snackbar('Error', 'Failed to read Excel file');
    }
  }

  clearData() {
    paginationStock.clear();
    paginationStock = [];
    paginationSale.clear();
    paginationSale = [];
    cashController.purchase = [];
    cashController.purchase.clear();
    firstTimeLoading = true;
    update();
  }
}

ProductModel parseProductData(String jsonString) {
  final Map<String, dynamic> json = jsonDecode(jsonString);
  return ProductModel.fromJson(json);
}

CashModel parseCashData(String jsonString) {
  final Map<String, dynamic> json = jsonDecode(jsonString);

  return CashModel.fromJson(json);
}
