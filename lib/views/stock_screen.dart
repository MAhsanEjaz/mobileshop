import 'dart:convert';
import 'dart:io';
import 'package:barcode_scan2/model/android_options.dart';
import 'package:barcode_scan2/model/scan_options.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopapp/controllers/inventory_controller.dart';
import 'package:shopapp/models/sale_product_model.dart';
import 'package:shopapp/pdf_service/sale_invoice.dart';
import 'package:shopapp/utils.dart';
import 'package:shopapp/views/add_purchase_screen.dart';
import 'package:shopapp/views/home_screen.dart';
import 'package:shopapp/widgets/app_button.dart';
import 'package:shopapp/widgets/app_text_field.dart';
import 'package:shopapp/widgets/custom_dropdown.dart';
import '../controllers/sale_controller.dart';
import '../main.dart';
import '../models/product_model.dart';
import '../pdf_service/inventory_pdf_service.dart';
import '../widgets/dialog_container.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  PurchaseInventoryController purchaseInventoryController = Get.find();

  List<String> mop = ['Cash', 'Transfer', 'Debit Card', 'Credit Card'];

  Map<int, Widget> children = {0: Text('Stock'), 1: Text('Sold')};

  getPurchaseData() {
    purchaseInventoryController.firstTimeLoading = true;
    purchaseInventoryController.update();
    purchaseInventoryController.pageUpdate();
    purchaseInventoryController.getPurchases();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('json${jsonEncode(purchaseInventoryController.model)}');
      purchaseInventoryController.purchasePaginationControls();
      purchaseInventoryController.paginOff(false);
      print(purchaseInventoryController.paginationOff);
      getPurchaseData();
    });
  }

  int currentIndex = 0;

  bool filter = false;
  SnapshotController snapshotControllerStock = SnapshotController();

  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        purchaseInventoryController.stockVisible = false;

        setState(() {});

        return true;
      },
      child: GetBuilder(
        init: purchaseInventoryController,
        builder: (cont) {
          return Scaffold(
            floatingActionButton:
                currentIndex == 1
                    ? SizedBox.shrink()
                    : GetBuilder(
                      init: saleController,
                      builder: (sale) {
                        return FloatingActionButton(
                          backgroundColor: Colors.red,
                          onPressed: () {
                            sale.clearSaleProduct();
                            imeiCont.clear();
                            saleDate.clear();
                            productName.clear();
                            customerName.clear();
                            contact.clear();
                            qty.clear();
                            totalPrice.clear();
                            salePrice.clear();
                            partType = null;

                            ///-----------------
                            if (saleDate.text.isEmpty) {
                              saleDate.text = dateFormatWithName(
                                DateTime.now().toString(),
                              );
                              setState(() {});
                            }

                            customDialogInterFace(dialogCard(cont));
                          },
                          child: Icon(
                            CupertinoIcons.cart_badge_minus,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
            appBar: AppBar(
              actions: [
                InkWell(
                  onTap: () async {
                    cont.update();
                    customDialogInterFace(
                      filterDialog(
                        onTap: () async {

                          cont.firstTimeLoading = true;
                          cont.paginOff(true);
                          cont.paginationSale.clear();
                          cont.paginationStock.clear();
                          await cont.getPurchases(
                            startDate: startDate.text,
                            endDate: endDate.text,
                            customUrl:
                                'getPurchaseWithPagi/?userId=${loginModelUser!.user!.sId}'
                                '&shopId=${shopData?.sId ?? loginModelUser!.user!.shopData!.sId}'
                                '&startDate=${startDate.text.toString()}&endDate=${endDate.text.toString()}',
                          );
                          exitLoader();
                        },
                        endDate: endDate,
                        startDate: startDate,
                      ),
                    );
                  },
                  child: Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: Colors.white,
                  ),
                ),

                InkWell(
                  onTap: () {
                    filter = !filter;
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      filter
                          ? Icons.close
                          : CupertinoIcons.search, // 🎛 iOS-style filter icon
                    ),
                  ),
                ),

                InkWell(
                  onTap: () async {
                    final pdfData =
                        await InventoryPdfService.inventoryPdfService(
                          cont.paginationStock,
                          currentIndex == 0 ? true : false,
                          currentIndex == 1 ? true : false,
                          cont.paginationSale,
                        );

                    final dir = await getApplicationDocumentsDirectory();
                    final pdfFilePath =
                        '${dir.path}/${currentIndex == 0 ? "Inventory Report.pdf" : "Sale Report.pdf"}';
                    final pdfFile = File(pdfFilePath);

                    await pdfFile.writeAsBytes(pdfData);

                    // Safely open file
                    try {
                      final result = await OpenFile.open(pdfFilePath);
                      if (result.type != ResultType.done) {
                        Get.snackbar(
                          'Error',
                          'No PDF viewer app found on your device',
                        );
                      }
                    } catch (e) {
                      print('Error opening PDF: $e');
                      Get.snackbar('Error', 'Failed to open PDF file');
                    }

                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Icon(Icons.picture_as_pdf),
                  ),
                ),
              ],
              leading: SizedBox(),
              title: const Text(
                'Stock',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              backgroundColor: appColor,
              elevation: 2,
            ),
            body: CustomScrollView(
              controller:cont.paginationOff==false? cont.scrollController:null,
              slivers: [
                SliverToBoxAdapter(child: customHeight(0.01)),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 8,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,

                              child: CupertinoSlidingSegmentedControl(
                                children: children,
                                padding: EdgeInsets.all(9),
                                groupValue: currentIndex,
                                onValueChanged: (val) {
                                  currentIndex = val!;
                                  setState(() {});
                                },
                              ),
                            ),

                            lengthShowing(
                              cont.stockSearch.length.toString(),
                              Colors.green.shade900,
                            ),
                            Positioned(
                              right: 20,
                              child: lengthShowing(
                                cont.saleSearch.length.toString(),
                                Colors.red.shade900,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: filter ? 8 : 0),
                        filter
                            ? SizedBox(
                              child: CupertinoSearchTextField(
                                onChanged:
                                    currentIndex == 0
                                        ? cont.searchQueryForStock
                                        : cont.searchQueryForSale,
                                placeholder: "Search with imei",
                                keyboardType: TextInputType.visiblePassword,
                              ),
                            )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: customHeight(0.01)),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item =
                          currentIndex == 0
                              ? cont.stockSearch[index]
                              : cont.saleSearch[index];

                      final sale =
                          currentIndex == 0 ? null : cont.saleSearch[index];

                      return widgetOfStockAndSale(item, sale, index);
                    }, childCount: lengthOfStockAndSale(cont)),
                  ),
                ),
                SliverToBoxAdapter(
                  child:
                      cont.isLoadingMore
                          ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: CircularProgressIndicator(color: appColor),
                            ), // default size
                          )
                          : SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int lengthOfStockAndSale(PurchaseInventoryController cont) {
    return currentIndex == 0 ? cont.stockSearch.length : cont.saleSearch.length;
  }

  Widget widgetOfStockAndSale(dynamic items, dynamic sale, int index) {
    return currentIndex == 0
        ? stockWidget(items, index)
        : saleWidget(index, sale);
  }

  TextEditingController imeiCont = TextEditingController();
  TextEditingController customerName = TextEditingController();
  TextEditingController productName = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController salePrice = TextEditingController();
  TextEditingController saleDate = TextEditingController();
  TextEditingController qty = TextEditingController();
  TextEditingController totalPrice = TextEditingController();

  String? partType;

  String? payment;

  SaleController saleController = Get.put(SaleController());

  Widget dialogCard(PurchaseInventoryController? cont) {
    return GetBuilder(
      init: saleController,
      builder: (sale) {
        return Center(
          child: DialogContainer(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: StatefulBuilder(
                builder: (context, setstate) {
                  return SingleChildScrollView(
                    child:
                        sale.filePath != null
                            ? Column(
                              children: [
                                Card(
                                  elevation: 5,
                                  shadowColor: Colors.grey.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        // Left icon
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: const Icon(
                                            CupertinoIcons.doc_text_fill,
                                            color: Colors.blueAccent,
                                            size: 28,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        // File details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Sale File',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                sale.filePath ?? '',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Right arrow
                                        const Icon(
                                          CupertinoIcons.chevron_forward,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 6),

                                AppButton(
                                  width: double.infinity,
                                  height: 45,
                                  onTap: () {
                                    sale.saveInCloud();
                                  },
                                  txt: 'Save',
                                ),
                                AppButton(
                                  width: double.infinity,
                                  height: 45,
                                  color: Colors.red,
                                  onTap: () {
                                    sale.makeEmpty();
                                  },
                                  txt: 'Cancel',
                                ),
                              ],
                            )
                            : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        onChanged: (val) {
                                          final data = cont!.paginationStock
                                              .firstWhere(
                                                (e) => e.imei == imeiCont.text,
                                              );

                                          if (data.salePart == "Accessories") {
                                            productName.text =
                                                data.accessories!;
                                            partType = data.salePart;
                                          } else {
                                            productName.text =
                                                '${data.brand} ${data.model!}';
                                          }

                                          salePrice.text = data.price!;
                                          partType = data.salePart;
                                          setstate(() {});
                                        },
                                        hint: 'IMEI',
                                        controller: imeiCont,
                                        textInputType:
                                            TextInputType.numberWithOptions(),
                                      ),
                                    ),

                                    SizedBox(width: 10),
                                    GetBuilder(
                                      init: purchaseInventoryController,
                                      builder: (cont) {
                                        return InkWell(
                                          onTap: () async {
                                            var scanData =
                                                await BarcodeScanner.scan(
                                                  options: ScanOptions(restrictFormat:[] ,
                                                    android: AndroidOptions(
                                                      useAutoFocus: true,
                                                    ),
                                                  ),
                                                );

                                            bool matchedImei = cont.paginationStock.any((e)=>e.imei == scanData.rawContent);
                                            if(!matchedImei){
                                              customSnackBar("Failed", "Invalid Imei", true);
                                            }
                                            final data = cont.paginationStock
                                                .firstWhere(
                                                  (e) =>
                                                      e.imei ==
                                                      scanData.rawContent,
                                                );

                                            if (data.salePart ==
                                                "Accessories") {
                                              productName.text =
                                                  data.accessories!;
                                              partType = data.salePart;
                                            } else {
                                              productName.text =
                                                  '${data.brand} ${data.model!}';
                                            }
                                            imeiCont.text = scanData.rawContent;
                                            print(
                                              'scan--->${scanData.rawContent}',
                                            );
                                            salePrice.text =
                                                data.price.toString();

                                            setstate(() {});
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black26,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12.0,
                                                    horizontal: 12,
                                                  ),
                                              child: Icon(Icons.qr_code),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                AppTextField(
                                  hint: 'Product Name',
                                  controller: productName,
                                ),
                                AppTextField(
                                  hint: 'Select Date',
                                  controller: saleDate,
                                  onTap: () async {
                                    var res = await customDatePicker();
                                    if (res != null) {
                                      saleDate.text = dateFormatWithName(
                                        res.toString(),
                                      );
                                    }
                                    setstate(() {});
                                  },
                                ),
                                AppTextField(
                                  hint: 'Customer Name',
                                  controller: customerName,
                                ),
                                AppTextField(
                                  textInputType: TextInputType.number,
                                  hint: 'Contact',
                                  controller: contact,
                                ),

                                partType == 'Accessories'
                                    ? AppTextField(
                                      textInputType: TextInputType.number,
                                      hint: 'Qty',
                                      onChanged: (val) {
                                        var qtyI = qty.text;
                                        var price = salePrice.text;

                                        var cal =
                                            (int.tryParse(qtyI))! *
                                            (int.tryParse(price)!.toDouble());
                                        totalPrice.text = cal.toString();
                                        setState(() {});
                                      },
                                      controller: qty,
                                    )
                                    : SizedBox.shrink(),

                                AppTextField(
                                  hint: 'Sale Price',
                                  onChanged: (val) {
                                    if (val!.isNotEmpty) {
                                      final plain = val.replaceAll(
                                        ',',
                                        '',
                                      ); // remove old commas
                                      final formatted = numberFormat(
                                        int.parse(plain),
                                      );
                                      // Avoid recursive updates
                                      if (formatted != salePrice.text) {
                                        final cursorPos = formatted.length;
                                        salePrice.value = TextEditingValue(
                                          text: formatted,
                                          selection: TextSelection.collapsed(
                                            offset: cursorPos,
                                          ),
                                        );
                                      }

                                      setstate(() {});

                                      final qtyP = int.tryParse(qty.text);
                                      final saleP = int.tryParse(
                                        salePrice.text,
                                      );

                                      totalPrice.text =
                                          (qtyP! * saleP!).toString();
                                    }
                                  },
                                  textInputType:
                                      TextInputType.numberWithOptions(),
                                  controller: salePrice,
                                ),

                                partType == 'Accessories'
                                    ? AppTextField(
                                      textInputType: TextInputType.number,
                                      hint: 'Total Price',
                                      controller: totalPrice,
                                    )
                                    : SizedBox.shrink(),
                                CustomDropdown(
                                  filled: true,
                                  title: payment ?? 'Select Payment Method',
                                  items: mop,
                                  onTap: (v) {
                                    payment = v;

                                    setstate(() {});
                                  },
                                ),

                                SizedBox(height: 20),

                                AppButton(
                                  width: double.infinity,
                                  height: 45,
                                  onTap: () {
                                    sale.pickSaleFilePick();
                                  },
                                  txt: 'Pick sale file',
                                ),
                                SizedBox(height: 10),

                                InkWell(
                                  onTap: () async {
                                    bool matchData = cont!.paginationStock.any(
                                      (element) =>
                                          element.imei == imeiCont.text,
                                    );

                                    print('cond---${matchData}');

                                    if (matchData) {
                                      Map<String, dynamic> body = {
                                        "imei": imeiCont.text.trim(),
                                        'userId': loginModelUser!.user!.sId,
                                        'shopId':
                                            shopData?.sId ??
                                            loginModelUser!.user!.shopData!.sId,
                                        "customerName":
                                            customerName.text.trim(),
                                        "customerPhone": contact.text.trim(),
                                        "salePrice":
                                            partType == 'Accessories'
                                                ? salePrice.text
                                                : salePrice.text.trim(),
                                        "qty": qty.text.trim(),
                                        "paymentMethod": payment,
                                        "salePart":
                                            partType == 'Accessories'
                                                ? "Accessories"
                                                : "Mobile",
                                        "date": saleDate.text.trim(),
                                      };

                                      sale.addSale(
                                        SaleProductModel(
                                          imei: imeiCont.text.trim(),
                                          customerName:
                                              customerName.text.trim(),
                                          customerPhone: contact.text.trim(),
                                          date: saleDate.text.trim(),
                                          paymentMethod: payment,
                                          salePrice: salePrice.text.trim(),
                                          qty:
                                              partType == "Accessories"
                                                  ? qty.text
                                                  : "0",
                                          salePart: partType,
                                        ),
                                      );

                                      await cont.saleItem(body);

                                      final dailyReport = await SaleReport()
                                          .saleReport(
                                            sale.sale,
                                            productName.text.trim(),
                                          );

                                      final dir =
                                          await getApplicationDocumentsDirectory();
                                      final pdfFilePath =
                                          '${dir.path}/Sale Receipt.pdf';
                                      final pdfFile = File(pdfFilePath);

                                      await pdfFile.writeAsBytes(dailyReport);
                                      // Safely open file
                                      try {
                                        final result = await OpenFile.open(
                                          pdfFilePath,
                                        ).then((v) {
                                          sale.sale.clear();
                                          print('saleClear--->${sale.sale}');
                                          setState(() {});
                                        });
                                        if (result.type != ResultType.done) {
                                          Get.snackbar(
                                            'Error',
                                            'No PDF viewer app found on your device',
                                          );
                                        }
                                      } catch (e) {
                                        print('Error opening PDF: $e');
                                        Get.snackbar(
                                          'Error',
                                          'Failed to open PDF file',
                                        );
                                      }
                                    } else {
                                      Get.snackbar('Failed', 'Imei Failed');
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(
                                        child: Text(
                                          'Sale',
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget stockWidget(final item, int index) {
    return Stack(
      children: [
        SnapshotWidget(
          controller: snapshotControllerStock,
          child: Card(
            surfaceTintColor: Colors.white,
            color: Colors.white,
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== IMAGE =====
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey.shade200,
                      child:
                          (item.images != null && item.images!.isNotEmpty)
                              ? CachedNetworkImage(
                                placeholder:
                                    (context, url) => Container(
                                      width: 90,
                                      height: 90,
                                      alignment: Alignment.center,
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                fit: BoxFit.cover,
                                imageUrl: '$apiBaseUrl${item.images!.first}',
                              )
                              : const Icon(
                                Icons.phone_android,
                                size: 50,
                                color: Colors.grey,
                              ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // ===== DETAILS =====
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 155,
                          child: Text(
                            item.salePart == 'Accessories'
                                ? "${item.accessories}"
                                : "${item.brand} ${item.model}",
                            style: const TextStyle(
                              // overflow: TextOverflow.ellipsis,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.date ?? "N/A",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: item.salePart == 'Accessories' ? 5 : 15,
                        ),

                        Row(
                          children: [
                            Text(
                              "IMEI: ${item.imei}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: item.imei ?? ""),
                                );
                                Get.snackbar(
                                  "Copied",
                                  "IMEI copied to clipboard",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.teal.shade100,
                                  colorText: Colors.black87,
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(bottom: 4.0),
                                child: Icon(Icons.copy, size: 17),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: item.salePart == 'Accessories' ? 5 : 10,
                        ),

                        item.salePart == "Accessories"
                            ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Remaining Qty: ${item.qty}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      (int.tryParse(item.qty ?? "0") ?? 0) > 0
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ),
                            )
                            : SizedBox.shrink(),

                        Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: [
                            item.salePart == 'Accessories'
                                ? SizedBox.shrink()
                                : _buildChip("RAM: ${item.ram}"),
                            item.salePart == 'Accessories'
                                ? SizedBox.shrink()
                                : _buildChip("Storage: ${item.storage}"),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _buildChip("Condition: ${item.condition}"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Price: Rs ${item.price}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.paymentMethod ?? "N/A",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Accessories: ${item.accessories}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // ===== POPUP MENU =====
        loginModelUser?.user?.role == "admin"
            ? Positioned(
              top: 6,
              right: 4,
              child: PopupMenuButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // Get.to(PurchaseEntryCard(purchaseModel: item,index: index));
                            Get.to(AddPurchaseScreen(purchaseModel: item));
                          });
                        },
                      ),
                      // const PopupMenuItem(child: Text('Clone')),
                      PopupMenuItem(
                        child: Text('Delete'),
                        onTap: () {
                          showCupertinoDialog(
                            context: context,
                            builder:
                                (context) => CupertinoAlertDialog(
                                  title: Column(
                                    children: const [
                                      Text(
                                        'Delete Item',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Are you sure you want to delete this item?\nThis action cannot be undone.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      isDefaultAction: true,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    GetBuilder(
                                      init: purchaseInventoryController,
                                      builder: (pur) {
                                        return CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          onPressed: () {
                                            Map<String, dynamic> body = {
                                              "itemId": "${item.sId}",
                                            };

                                            pur.deleteItem(
                                              body,
                                              startDate.text,
                                              endDate.text,
                                            );

                                            // 🔥 call delete API here
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                    ],
                elevation: 15,
                position: PopupMenuPosition.under,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            )
            : SizedBox(),
      ],
    );
  }

  Widget lengthShowing(String? txt, Color? color) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(txt!, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget saleWidget(int index, SaleProducts l) {
    return Stack(
      children: [
        Card(
          surfaceTintColor: Colors.white,
          color: Colors.white,
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== IMAGE =====
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade200,
                    child:
                        (l.images != null && l.images!.isNotEmpty)
                            ? CachedNetworkImage(
                              placeholder:
                                  (context, url) => Container(
                                    width: 90,
                                    height: 90,
                                    alignment: Alignment.center,
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        width: 90,
                                        height: 90,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              fit: BoxFit.cover,
                              imageUrl: '$apiBaseUrl${l.images!.first}',
                            )
                            : const Icon(
                              Icons.phone_android,
                              size: 50,
                              color: Colors.grey,
                            ),
                  ),
                ),

                const SizedBox(width: 15),

                // ===== DETAILS =====
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 155,
                        child: Text(
                          (l.salePart == 'Accessories')
                              ? "${l.accessories}"
                              : "${l.brand} ${l.model}",
                          style: const TextStyle(
                            // overflow: TextOverflow.ellipsis,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l.customerData?.date ?? "N/A",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Text(
                            "IMEI: ${l.imei}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          // const SizedBox(width: 10),
                          // InkWell(
                          //   onTap: () {
                          //     Clipboard.setData(
                          //       ClipboardData(text: l.value.imei ?? ""),
                          //     );
                          //     Get.snackbar(
                          //       "Copied",
                          //       "IMEI copied to clipboard",
                          //       snackPosition: SnackPosition.BOTTOM,
                          //       backgroundColor: Colors.teal.shade100,
                          //       colorText: Colors.black87,
                          //       duration: const Duration(seconds: 2),
                          //     );
                          //   },
                          //   child: const Padding(
                          //     padding: EdgeInsets.only(bottom: 4.0),
                          //     child: Icon(Icons.copy, size: 15),
                          //   ),
                          // ),
                        ],
                      ),

                      (l.salePart == 'Accessories')
                          ? SizedBox.shrink()
                          : const SizedBox(height: 5),

                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: [
                          (l.salePart == 'Accessories')
                              ? SizedBox.shrink()
                              : _buildChip("RAM: ${l.ram}"),
                          (l.salePart == 'Accessories')
                              ? SizedBox.shrink()
                              : _buildChip("Storage: ${l.storage}"),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _buildChip("Condition: ${l.condition}"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Price: Rs ${l.price}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l.paymentMethod ?? "N/A",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Accessories: ${l.accessories}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      // ===== ✨ BEAUTIFUL CUSTOMER INFO SECTION =====
                      if (currentIndex == 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Customer Details",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.teal,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        l.customerData?.customerName ?? "N/A",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: Colors.teal,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        l.customerData?.customerPhone ?? "N/A",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.inventory,
                                      size: 16,
                                      color: Colors.teal,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        l.customerData?.qty ?? "N/A",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.payment,
                                      size: 16,
                                      color: Colors.teal,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        l.customerData?.paymentMethod ?? "N/A",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.currency_rupee,
                                      size: 16,
                                      color: Colors.teal,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "Sale Price: ${l.customerData?.salePrice ?? 'N/A'}",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ===== POPUP MENU =====
        Positioned(
          top: 10,
          right: 10,
          child: PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    child: Text('Return'),
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showCupertinoDialog(
                          context: context,
                          builder:
                              (context) => CupertinoAlertDialog(
                                title: Text(
                                  'Do you want return this item?',
                                  style: TextStyle(fontSize: 15),
                                ),
                                content: Column(
                                  children: [
                                    Text(
                                      "Once return this item then it will be deleted from all records.",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    onPressed: () {
                                      Get.back();
                                    },
                                  ),
                                  GetBuilder(
                                    init: saleController,
                                    builder: (cont) {
                                      return CupertinoDialogAction(
                                        onPressed: () {
                                          Map<String, dynamic> body = {
                                            "saleImei": l.imei,
                                            "qty": l.customerData?.qty,
                                          };
                                          cont.updateSalePart(body);
                                        },
                                        child: Text(
                                          'OK',

                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                        );
                      });
                    },
                  ),
                ],
            elevation: 10,
            position: PopupMenuPosition.under,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }
}
