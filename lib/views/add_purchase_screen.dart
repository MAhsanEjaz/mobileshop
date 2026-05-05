import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopapp/controllers/inventory_controller.dart';
import 'package:shopapp/models/product_model.dart';
import 'package:shopapp/widgets/animated_widget.dart';

import '../utils.dart';
import '../widgets/purchase_entry_card.dart';

class AddPurchaseScreen extends StatefulWidget {
  StockProducts? purchaseModel;

  AddPurchaseScreen({super.key, this.purchaseModel});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  PurchaseInventoryController purchaseInventoryController = Get.find();
  final i = 0;

  getEditAbleData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.purchaseModel != null) {
        final cont = purchaseInventoryController;

        cont.removePurchaseEntryCard();
        cont.addPurchaseInventory(); // 🔥 REQUIRED

        final m = widget.purchaseModel!;

        cont.salePart[i] = m.salePart ?? 'Mobile';
        cont.date[i].text = m.date ?? '';
        cont.purchaserName[i].text = m.purchaserName ?? '';
        cont.imeiCont[i].text = m.imei ?? '';
        cont.brandCont[i].text = m.brand ?? '';
        cont.modelCont[i].text = m.model ?? '';
        cont.storage[i] = m.storage ?? '4GB';
        cont.ram[i] = m.ram ?? '1GB';
        cont.condition[i] = m.condition ?? '';
        cont.priceCont[i].text = m.price ?? '';
        cont.payment[i] = m.paymentMethod ?? '';
        cont.accessCont[i].text = m.accessories ?? '';
        cont.qty[i].text = m.qty ?? '';
        final int qty = int.tryParse(cont.qty[i].text.trim()) ?? 0;
        final int price = int.tryParse(cont.priceCont[i].text.trim()) ?? 0;

        cont.accesoriesTotalPrice[i].text = (qty * price).toString();

        cont.update(); // 🔥 VERY IMPORTANT
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getEditAbleData();
    });
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.purchaseModel != null) {
          purchaseInventoryController.removePurchaseEntryCard();
          purchaseInventoryController.updateImageFile.clear();
          purchaseInventoryController.update();
        }
        return true;
      },
      child: GetBuilder(
        init: purchaseInventoryController,
        builder: (cont) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              actions: [
                widget.purchaseModel != null
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        style: ButtonStyle(
                          elevation: WidgetStatePropertyAll(5),
                          backgroundColor: WidgetStatePropertyAll(Colors.green),
                        ),
                        onPressed: () {
                          cont.updateInventory(widget.purchaseModel!, i);
                        },
                        child: Text(
                          "Update",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    : (cont.purchase.isNotEmpty)
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        elevation: 0,

                        backgroundColor: Colors.white,
                        onPressed: () {
                          // purchaseInventoryController.saveModelData();
                          if (cont.validation()) {
                            cont.purchaseService();
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(444),
                        ),
                        child: Icon(Icons.check),
                      ),
                    )
                    : SizedBox.shrink(),
              ],
              title: const Text(
                "Add Purchases",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: SizedBox(),
              backgroundColor: appColor,
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            floatingActionButton:
                widget.purchaseModel != null
                    ? SizedBox.shrink()
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          elevation: 0,

                          backgroundColor: appColor,
                          onPressed: () {
                            // purchaseInventoryController.saveModelData();
                            purchaseInventoryController.filePick();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(444),
                          ),
                          child: Icon(Icons.file_copy, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        FloatingActionButton(
                          backgroundColor: appColor,
                          child: const Icon(Icons.add, color: Colors.white),

                          onPressed: () {
                            cont.addPurchaseInventory();
                          },
                        ),
                      ],
                    ),
            body: CustomAnimatedCard(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child:
                    cont.purchase.isEmpty
                        ? Center(
                          child: Text(
                            "No purchase entries yet.\nTap + to add a new one.",
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: appColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),

                          itemCount: cont.purchase.length,
                          padding: const EdgeInsets.only(bottom: 80),

                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                PurchaseEntryCard(
                                  index: index,
                                  purchaseModel: widget.purchaseModel,
                                ),
                                widget.purchaseModel != null
                                    ? SizedBox.shrink()
                                    : Positioned(
                                      right: 30,
                                      top: 40,
                                      child: InkWell(
                                        onTap: () {
                                          cont.removePurchaseEntryCard();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 2,
                                                spreadRadius: 2,
                                                offset: Offset(.2, .3),
                                              ),
                                            ],
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.black26,
                                                Colors.black54,
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 13,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              ],
                            );
                          },
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}
