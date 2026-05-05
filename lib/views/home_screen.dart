import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shopapp/controllers/cash_controller.dart';
import 'package:shopapp/pdf_service/home_report.dart';
import 'package:shopapp/utils.dart';
import 'package:shopapp/widgets/app_button.dart';
import 'package:shopapp/widgets/app_text_field.dart';
import '../pdf_service/home_customer_report.dart';
import 'expenses/expense_home.dart' show ExpenseHome;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CashController cashController = Get.find();

  getPurchase() {
    if (cashController.logout == true) {
      log('api-->${cashController.logout}');

      return null;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final date = DateTime.now();
        final start = DateTime(date.year, date.month, 1);
        final end = DateTime(date.year, date.month + 1, 0);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cashController.getPurchases(
            dateFormatWithName(start.toString()),
            dateFormatWithName(end.toString()),
          );
        });
      });
    }
    log('api-->${cashController.logout}');

    setState(() {});
  }

  bool cashVisible = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPurchase();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: cashController,
      builder: (cont) {
        return Scaffold(
          backgroundColor: appColor,
          body: Column(
            children: [
              topCard(cont),
              customHeight(0.02),
              Expanded(
                child: Container(
                  height: MediaQuery.sizeOf(context).height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(40),
                      topLeft: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [SafeArea(child: bottomPart(cont))],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget topCard(CashController cash) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Rs: ${cashVisible ? "*******" : numberFormat(cash.totalProfit)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            cashVisible = !cashVisible;
                            setState(() {});
                          },
                          child: Icon(
                            cashVisible
                                ? Icons.remove_red_eye
                                : Icons.visibility_off,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Net Income',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(CupertinoIcons.bell_fill, color: Colors.white),
                SizedBox(width: 17),
                Icon(CupertinoIcons.person_alt, color: Colors.white),
                SizedBox(width: 5),
              ],
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                dashboardCard(
                  CupertinoIcons.money_dollar_circle,
                  'Expenses',
                  () {
                    Get.to(ExpenseHome());
                  },
                ),
                Spacer(),
                // for Expense
                dashboardCard(CupertinoIcons.chart_bar, 'Reports', () {}),
                Spacer(),
                // for Reports
                dashboardCard(CupertinoIcons.person_2, 'Users', () {
                  cash.onChangedState(3);
                }),
              ],
            ),
          ),

          // for Users
        ],
      ),
    );
  }

  bool showPurchase = false;
  bool showSale = false;
  final GlobalKey _key = GlobalKey();

  void _showPopover() {
    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + 40,
              child: CupertinoPopupSurface(
                isSurfacePainted: true,
                child: Container(
                  width: 145,
                  color: CupertinoColors.systemBackground,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoListTile(
                        onTap: () async {
                          log('pdfFile--->');
                          final dailyReport = await HomeReport.homeReport(
                            cashController.searchModelList,
                            false,
                          );

                          final dir = await getApplicationDocumentsDirectory();
                          final pdfFilePath =
                              '${dir.path}/Daily Activity Report.pdf';
                          final pdfFile = File(pdfFilePath);

                          await pdfFile.writeAsBytes(dailyReport);
                          // Safely open file
                          try {
                            final result = await OpenFile.open(pdfFilePath);
                          } catch (e) {
                            print('Error opening PDF: $e');
                          }
                        },

                        trailing: Icon(
                          CupertinoIcons.cart_badge_plus,
                          size: 18,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        title: Text("Daily Report"),
                      ),
                      Container(height: 1, color: CupertinoColors.separator),

                      CupertinoListTile(
                        onTap: () async {
                          log('pdfFile--->');
                          final dailyReport =
                              await HomeCustomerReport.homeReport(
                                cashController.searchModelList,
                                true,
                              );

                          final dir = await getApplicationDocumentsDirectory();
                          final pdfFilePath = '${dir.path}/Ledger.pdf';
                          final pdfFile = File(pdfFilePath);

                          await pdfFile.writeAsBytes(dailyReport);
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
                        },

                        trailing: Icon(
                          CupertinoIcons.cart_badge_plus,
                          size: 18,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        title: Text("Daily Sale "),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget bottomPart(CashController cash) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                (startDate.text.isEmpty || endDate.text.isEmpty)
                    ? 'Monthly Summary'
                    : '${startDate.text.toString()} - ${endDate.text.toString()}',
                style: TextStyle(
                  color: appColor,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      (startDate.text.isNotEmpty || endDate.text.isNotEmpty)
                          ? 14
                          : 22,
                ),
              ),

              SizedBox(width: 10),
              GestureDetector(
                key: _key,

                onTap: () async {
                  _showPopover();
                },
                child: Icon(
                  CupertinoIcons.doc_fill,
                  color: Colors.red,
                  size: 20,
                ),
              ),

              Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    startDate.clear();
                    endDate.clear();
                  });
                  customDialogInterFace(
                    filterDialog(
                      onTap: () async {
                        await cash.getPurchases(startDate.text, endDate.text);
                        exitLoader();
                      },
                      endDate: endDate,
                      startDate: startDate,
                    ),
                  );
                },
                child: Icon(CupertinoIcons.slider_horizontal_3),
              ),
            ],
          ),

          customHeight(0.02),
          dashboardContainer(
            Column(
              children: [
                dashboardListTile(
                  CupertinoIcons.cart_badge_plus,
                  'Purchase',
                  '${cash.totalPurchase.length}',
                  () {
                    showPurchase = !showPurchase;

                    cash.getSearchData();
                    showSale = false;

                    setState(() {});
                  },
                ),

                showPurchase
                    ? purchaseAndSaleWidget(cash, false, showPurchase)
                    : SizedBox(),

                Divider(),
                dashboardListTile(
                  CupertinoIcons.cart_badge_minus,
                  'Sale',
                  '${cash.totalSale.length}',
                  () {
                    showSale = !showSale;
                    showPurchase = false;
                    cash.getSearchData();

                    setState(() {});
                  },
                ),

                showSale
                    ? purchaseAndSaleWidget(cash, true, showSale)
                    : SizedBox(),
                SizedBox(height: 9),
              ],
            ),
          ),
          customHeight(0.02),

          dashboardContainer(
            Column(
              children: [
                dashboardListTile(
                  CupertinoIcons.cube_box, // better for stock representation
                  'Available Stock',
                  '${cash.inStockItems}',
                  () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboardCard(IconData? icon, String? title, Function()? onTap) {
    return Expanded(
      child: InkWell(
        onTap: (onTap),
        child: Column(
          children: [
            Card(
              surfaceTintColor: Colors.white,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Icon(icon, color: appColor),
              ),
            ),
            Text(
              title!,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardListTile(
    IconData? icon,
    String? title,
    String? trailing,
    Function()? onTap,
  ) {
    return ListTile(
      onTap: (onTap),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      leading: Icon(icon, color: appColor),
      title: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Text(title!, style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          trailing!,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
    );
  }

  Widget dashboardContainer(Widget child) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: appColor.withOpacity(0.2),
            offset: const Offset(-2, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }

  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();

  Widget purchaseAndSaleWidget(CashController cash, bool sale, bool status) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
          child: CupertinoSearchTextField(onChanged: cash.searchFunction),
        ),
        customHeight(0.01),

        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: cash.searchModelList.length,
          itemBuilder: (context, index) {
            final data = cash.searchModelList[index];

            String status = sale == true ? 'sale' : 'stock';

            return data.status == status
                ? Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 1,
                      ),
                      child: Row(
                        children: [
                          /// IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                (data.mobileDetail!.images!.isEmpty)
                                    ? Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black12,
                                      ),
                                      height: 30,
                                      width: 30,
                                      child: Icon(Icons.phone_android),
                                    )
                                    : CachedNetworkImage(
                                      height: 30,
                                      width: 30,
                                      fit: BoxFit.cover,
                                      imageUrl:
                                          '$apiBaseUrl${data.mobileDetail?.images?.first}',
                                      placeholder:
                                          (ctx, url) => Container(
                                            color: Colors.grey.shade200,
                                          ),
                                      errorWidget:
                                          (ctx, url, err) => Icon(Icons.error),
                                    ),
                          ),

                          SizedBox(width: 12),

                          /// TEXT DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (data.mobileDetail?.salePart == "Accessories")
                                      ? data.mobileDetail?.accessories ?? ''
                                      : '${data.mobileDetail?.brand} ${data.mobileDetail?.model}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                  ),
                                ),
                                data.mobileDetail?.salePart == "Accessories"
                                    ? Text(
                                      (data.mobileDetail?.salePart ==
                                              "Accessories")
                                          ? 'Qty: ${data.qty ?? data.mobileDetail!.qty!}' ??
                                              ''
                                          : '${data.mobileDetail!.qty}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                    )
                                    : SizedBox.shrink(),

                                SizedBox(height: 3),
                                Text(
                                  data.imei ?? '',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// PRICE
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sale
                                    ? numberFormat(
                                      ((double.tryParse(
                                                data.salePrice?.replaceAll(
                                                      ',',
                                                      '',
                                                    ) ??
                                                    '0',
                                              ) ??
                                              0) *
                                          (int.tryParse(
                                                data.qty?.toString() ?? '1',
                                              ) ??
                                              1)),
                                    )
                                    : numberFormat(
                                      (double.tryParse(
                                                data.mobileDetail!.price!
                                                    .replaceAll(',', ''),
                                              ) ??
                                              0) *
                                          (int.tryParse(
                                                data.mobileDetail!.qty
                                                        .toString() ??
                                                    '1',
                                              ) ??
                                              1),
                                    ),

                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),

                              sale == true
                                  ? Text(
                                    '${numberFormat((double.tryParse(data.profit?.replaceAll(',', '') ?? '0') ?? 0) * (int.tryParse(data.qty ?? '1') ?? 1))}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          (double.tryParse(
                                                        data.profit?.replaceAll(
                                                              ',',
                                                              '',
                                                            ) ??
                                                            '0',
                                                      ) ??
                                                      0) <
                                                  0
                                              ? Colors.red
                                              : Colors.blue,
                                    ),
                                  )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    data.mobileDetail!.productStatus == 'sale'
                        ? Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(6),
                              bottomRight: Radius.circular(6),
                            ),
                          ),
                          child: Icon(
                            CupertinoIcons.minus,
                            color: Colors.white,
                            size: 13,
                          ),
                        )
                        : SizedBox.shrink(),
                  ],
                )
                : SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

Widget filterDialog({
  Function()? onTap,
  TextEditingController? startDate,
  TextEditingController? endDate,
}) {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
    child: Padding(
      padding: const EdgeInsets.all(18.0),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: StatefulBuilder(
          builder: (context, setstate) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: appColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: appColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      width: double.infinity,
                      height: 50,
                      child: Center(
                        child: Text(
                          'Filter Inventory by Date',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: startDate,
                              onTap: () async {
                                var res = await customDatePicker();
                                if (res != null) {
                                  startDate!.text = dateFormatWithName(
                                    res.toString(),
                                  );
                                }
                                setstate(() {});
                              },
                              hint: 'Select Date',
                              readOnly: true,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: AppTextField(
                              controller: endDate,
                              onTap: () async {
                                var res = await customDatePicker();
                                if (res != null) {
                                  endDate!.text = dateFormatWithName(
                                    res.toString(),
                                  );
                                }
                                setstate(() {});
                              },
                              hint: 'Select Date',
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, right: 13),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(
                            txt: 'Cancel',
                            height: 40,
                            width: 80,
                            color: Colors.red,
                            onTap: () {
                              exitLoader();
                            },
                          ),
                          SizedBox(width: 10),
                          AppButton(
                            txt: 'Go',
                            height: 40,
                            width: 80,
                            onTap: (onTap!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
