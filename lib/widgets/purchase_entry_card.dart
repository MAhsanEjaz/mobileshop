import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopapp/controllers/inventory_controller.dart';
import 'package:shopapp/models/product_model.dart';
import 'package:shopapp/utils.dart';
import 'package:shopapp/widgets/app_text_field.dart';
import 'package:shopapp/widgets/custom_dropdown.dart';
import 'package:shopapp/widgets/custom_radio.dart';

class PurchaseEntryCard extends StatefulWidget {
  StockProducts? purchaseModel;
  int? index;

  PurchaseEntryCard({super.key, this.purchaseModel, this.index});

  @override
  State<PurchaseEntryCard> createState() => _PurchaseEntryCardState();
}

class _PurchaseEntryCardState extends State<PurchaseEntryCard> {
  List<String> condition = ['New', 'Used', 'Refurnished'];
  List<String> mop = ['Cash', 'Transfer', 'Debit Card', 'Credit Card'];

  List<Color> allMaterialColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.yellow,
    Colors.teal,
    Colors.cyan,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
    Colors.black,
    Colors.white,
  ];

  PurchaseInventoryController purchaseInventoryController = Get.find();

  List<String> storage = [
    '4GB',
    '8GB',
    '16GB',
    '32GB',
    '64GB',
    '128GB',
    '256GB',
    '512GB',
    '1TB',
    '2TB',
  ];

  List<String> ram = [
    '1GB',
    '2GB',
    '3GB',
    '4GB',
    '6GB',
    '8GB',
    '12GB',
    '16GB',
    '24GB',
    '32GB',
    '64GB',
    '128GB',
    '256GB',
    '512GB',
  ];

  List<String> mobileBrands = [
    'Apple',
    'Samsung',
    'Huawei',
    'Xiaomi',
    'Oppo',
    'Vivo',
    'Realme',
    'OnePlus',
    'Google',
    'Motorola',
    'Nokia',
    'Sony',
    'LG',
    'Asus',
    'Lenovo',
    'HTC',
    'ZTE',
    'Tecno',
    'Infinix',
    'Honor',
  ];

  List<String> searchBrands = []; // this one updates

  List<String> initialChoice = ['Accessories', 'Mobile'];

  searchFunction(String typeLower) {
    final lowerCase = typeLower.toLowerCase();
    setState(() {
      searchBrands =
          mobileBrands.where((element) {
            final name = element.toLowerCase();

            return name.contains(lowerCase);
          }).toList();
    });
  }

  getBrands() {
    if (widget.purchaseModel != null) {
      searchBrands = mobileBrands;
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getBrands();
  }

  SnapshotController snapshotController = SnapshotController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: purchaseInventoryController,
      builder: (cont) {
        return SnapshotWidget(
          controller: snapshotController,
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title
                      Text(
                        'New Purchase Entry',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,

                          color: appColor,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Image Picker Section
                      Text(
                        "Upload Images",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (widget.purchaseModel != null) {
                                cont.updateWithImageGalPick();
                              } else {
                                purchaseInventoryController.imagePickFunction(
                                  widget.index!,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade400),
                                color: Colors.grey.shade100,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 20,
                                  color: appColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              if (widget.purchaseModel != null) {
                                cont.updateWithImageCamPick();
                              } else {
                                purchaseInventoryController.imagePickCamera(
                                  widget.index!,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade400),
                                color: Colors.grey.shade100,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: appColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      if (widget.purchaseModel != null)
                        Wrap(
                          children: [
                            for (var l in widget.purchaseModel!.images!) ...[
                              CachedNetworkImage(
                                imageUrl: '$apiBaseUrl$l',
                                height: 80,
                                width: 90,
                                placeholder:
                                    (url, context) => Shimmer.fromColors(
                                      baseColor: Colors.black26,
                                      highlightColor: Colors.pink.shade50,
                                      child: SizedBox(height: 80, width: 90),
                                    ),
                              ),
                            ],
                          ],
                        )
                      else
                        Wrap(
                          children: [
                            for (var l
                                in purchaseInventoryController
                                    .files[widget.index!]
                                    .asMap()
                                    .entries) ...[
                              Padding(
                                padding: EdgeInsets.only(
                                  left: l.key > 0 ? 4.0 : 0,
                                  top: l.key > 0 ? 4.0 : 0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    height: 80,
                                    width: 80,
                                    File(
                                      purchaseInventoryController
                                          .files[widget.index!][l.key]
                                          .path,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                      /// Preview images
                      const SizedBox(height: 24),

                      if (cont.updateImageFile.isNotEmpty) ...[
                        Text(
                          'New Images',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 7),
                        Wrap(
                          children: [
                            for (var l in cont.updateImageFile) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(l.path),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var l in initialChoice.asMap().entries) ...[
                            CustomRadio(
                              groupValue: cont.salePart[widget.index!],
                              onTap: (v) {
                                cont.salePart[widget.index!] = v;

                                log(
                                  'selectedPart-->${jsonEncode(cont.salePart[widget.index!])}',
                                );
                                setState(() {});
                              },
                              title: l.value,
                            ),
                          ],
                        ],
                      ),

                      /// Form Fields
                      if (cont.salePart[widget.index!] == 'Accessories')
                        _sectionTitle("Accessories Details")
                      else
                        _sectionTitle("Mobile Details"),

                      AppTextField(
                        readOnly: true,
                        onTap: () async {
                          var res = await customDatePicker();
                          if (res != null) {
                            res = dateFormatWithName(res.toString());
                            cont.date[widget.index!].text = res;
                            setState(() {});
                          }
                        },
                        hint: 'Select Date',
                        controller: cont.date[widget.index!],
                        textInputType: TextInputType.numberWithOptions(),
                      ),

                      AppTextField(
                        hint: 'Purchase Name',
                        controller: cont.purchaserName[widget.index!],
                      ),
                      cont.salePart[widget.index!] == 'Accessories'
                          ? AppTextField(
                            hint: 'Qty',
                            textInputType: TextInputType.number,
                            controller: cont.qty[widget.index!],
                          )
                          : SizedBox.shrink(),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              hint:
                                  cont.salePart[widget.index!] == 'Accessories'
                                      ? 'Product Code'
                                      : 'IMEI',
                              controller: cont.imeiCont[widget.index!],
                              textInputType: TextInputType.numberWithOptions(),
                            ),
                          ),

                          SizedBox(width: 10),
                          GetBuilder(
                            init: purchaseInventoryController,
                            builder: (cont) {
                              return InkWell(
                                onTap: () async {
                                  var scanData = await BarcodeScanner.scan(

                                    options: const ScanOptions(
                                      restrictFormat:[] ,
                                      android: AndroidOptions(
                                        useAutoFocus: true,
                                      ),
                                    ),
                                  );
                                  log('scanBar-->${scanData.rawContent}');

                                  cont.imeiCont[widget.index!].text =
                                      scanData.rawContent;
                                  setState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black26),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
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

                      if (cont.salePart[widget.index!] == 'Accessories')
                        SizedBox.shrink()
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Brand"),

                            SizedBox(
                              height: 35,
                              child: SearchBar(
                                elevation: WidgetStateProperty.all(4),
                                leading: Icon(Icons.search),
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                surfaceTintColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                onChanged: (val) {
                                  if (val.isEmpty) {
                                    searchBrands = [];
                                  } else {
                                    searchFunction(val);
                                  }
                                  setState(() {});
                                },
                                hintText: 'Search Brand',
                              ),
                            ),
                            SizedBox(height: 9),

                            mobileBrands.isEmpty
                                ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      'Search Brands',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                : Wrap(
                                  children: [
                                    for (var l
                                        in searchBrands.asMap().entries) ...[
                                      InkWell(
                                        onTap: () {
                                          purchaseInventoryController
                                                  .brandIndex[widget.index!] =
                                              l.key;

                                          cont.brandCont[widget.index!].text =
                                              l.value;
                                          purchaseInventoryController
                                              .brandCont[widget.index!]
                                              .text = l.value;

                                          log(
                                            'brand-->${purchaseInventoryController.brandCont[widget.index!].text}',
                                          );

                                          setState(() {});
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.black26,
                                              ),
                                              boxShadow:
                                                  purchaseInventoryController
                                                              .brandCont[widget
                                                                  .index!]
                                                              .text ==
                                                          l.value
                                                      // ✅ only selected one is colored
                                                      ? [
                                                        BoxShadow(
                                                          color: Colors.black26,
                                                          offset: Offset(
                                                            .3,
                                                            .4,
                                                          ),
                                                          spreadRadius: 1,
                                                          blurRadius: 2,
                                                        ),
                                                        BoxShadow(
                                                          color: Colors.black12,
                                                          offset: Offset(
                                                            .3,
                                                            .4,
                                                          ),
                                                          spreadRadius: 1,
                                                          blurRadius: 2,
                                                        ),
                                                      ]
                                                      : null,
                                              color:
                                                  purchaseInventoryController
                                                              .brandCont[widget
                                                                  .index!]
                                                              .text ==
                                                          l.value
                                                      ? Colors
                                                          .teal // ✅ only selected one is colored
                                                      : Colors.transparent,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                l.value,
                                                style: TextStyle(
                                                  color:
                                                      purchaseInventoryController
                                                                  .brandCont[widget
                                                                      .index!]
                                                                  .text ==
                                                              l.value
                                                          // ✅ only selected one is colored
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                            AppTextField(
                              hint: 'Model',
                              controller: cont.modelCont[widget.index!],
                            ),
                            SizedBox(height: 7),

                            _sectionTitle("Storage"),

                            SizedBox(height: 7),

                            Wrap(
                              children: [
                                for (var l in storage.asMap().entries) ...[
                                  InkWell(
                                    onTap: () {
                                      purchaseInventoryController
                                              .storageIndex[widget.index!] =
                                          l.key;
                                      cont.storage[widget.index!] = l.value;

                                      /// ✅ Save into controller
                                      purchaseInventoryController.storage[widget
                                              .index!] =
                                          l.value;

                                      log(
                                        'storage--->${cont.storage[widget.index!]}',
                                      );

                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: AnimatedContainer(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.black26,
                                          ),
                                          color:
                                              purchaseInventoryController
                                                          .storage[widget
                                                          .index!] ==
                                                      l.value
                                                  ? appColor
                                                  : Colors.transparent,
                                          boxShadow:
                                              purchaseInventoryController
                                                          .storage[widget
                                                          .index!] ==
                                                      l.value
                                                  ? [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      offset: Offset(.3, .4),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      offset: Offset(.3, .4),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                    ),
                                                  ]
                                                  : null,
                                        ),

                                        duration: Duration(milliseconds: 300),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            l.value,
                                            style: TextStyle(
                                              color:
                                                  purchaseInventoryController
                                                              .storage[widget
                                                              .index!] ==
                                                          l.value
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 7),

                            _sectionTitle("RAM"),

                            SizedBox(height: 7),

                            Wrap(
                              children: [
                                for (var l in ram.asMap().entries) ...[
                                  InkWell(
                                    onTap: () {
                                      purchaseInventoryController
                                              .ramIndex[widget.index!] =
                                          l.key;
                                      cont.ram[widget.index!] = l.value;
                                      purchaseInventoryController.ram[widget
                                              .index!] =
                                          l.value;
                                      log('ram--->${cont.ram[widget.index!]}');

                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: AnimatedContainer(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.black26,
                                          ),
                                          color:
                                              purchaseInventoryController
                                                          .ram[widget.index!] ==
                                                      l.value
                                                  ? appColor
                                                  : Colors.transparent,
                                          boxShadow:
                                              purchaseInventoryController
                                                          .ram[widget.index!] ==
                                                      l.value
                                                  ? [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      offset: Offset(.3, .4),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      offset: Offset(.3, .4),
                                                      spreadRadius: 1,
                                                      blurRadius: 2,
                                                    ),
                                                  ]
                                                  : null,
                                        ),

                                        duration: Duration(milliseconds: 300),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            l.value,
                                            style: TextStyle(
                                              color:
                                                  purchaseInventoryController
                                                              .ram[widget
                                                              .index!] ==
                                                          l.value
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 7),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Text(
                                'Color',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 7),

                            Wrap(
                              children: [
                                for (var l
                                    in allMaterialColors.asMap().entries) ...[
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: InkWell(
                                      onTap: () {
                                        purchaseInventoryController
                                                .colorIndex[widget.index!] =
                                            l.key;

                                        print(
                                          "colorVal 0x${l.value.value.toRadixString(16).padLeft(8, '0')}",
                                        );

                                        setState(() {});
                                      },
                                      child: AnimatedContainer(
                                        height: 25,
                                        width: 25,
                                        decoration: BoxDecoration(
                                          color: l.value,
                                          border: Border.all(
                                            color: Colors.black26,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                        ),
                                        duration: Duration(milliseconds: 3000),
                                        child: Center(
                                          child:
                                              purchaseInventoryController
                                                          .colorIndex[widget
                                                          .index!] ==
                                                      l.key
                                                  ? Icon(
                                                    Icons.check,
                                                    color:
                                                        l.value == Colors.white
                                                            ? Colors.black
                                                            : Colors.white,
                                                    size: 13,
                                                  )
                                                  : SizedBox(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),

                      CustomDropdown(
                        items: condition,
                        title:
                            cont.condition[widget.index!] == ''
                                ? 'Select Condition'
                                : cont.condition[widget.index!],
                        onTap: (val) {
                          cont.condition[widget.index!] = val!;

                          purchaseInventoryController.condition[widget.index!] =
                              val;
                          setState(() {});
                        },
                      ),
                      AppTextField(
                        hint: 'Accessories Details',
                        controller: cont.accessCont[widget.index!],
                      ),

                      const SizedBox(height: 20),
                      _sectionTitle("Pricing"),
                      AppTextField(
                        hint: 'Unit Price',
                        onChanged: (val) {
                          if (val!.isNotEmpty) {
                            // 2️⃣ Parse unit price safely
                            final unitPrice =
                                int.tryParse(
                                  cont.priceCont[widget.index!].text,
                                ) ??
                                0;

                            // 3️⃣ Parse quantity
                            final quantity =
                                int.tryParse(cont.qty[widget.index!].text) ?? 1;

                            // 4️⃣ Multiply
                            final total = unitPrice * quantity;

                            cont.accesoriesTotalPrice[widget.index!].text =
                                total.toString();
                            print(
                              'price-->${cont.accesoriesTotalPrice[widget.index!].text}',
                            );

                            final plain = val.replaceAll(
                              ',',
                              '',
                            ); // remove old commas
                            final formatted = numberFormat(int.parse(plain));
                            // Avoid recursive updates
                            if (formatted !=
                                cont.priceCont[widget.index!].text) {
                              final cursorPos = formatted.length;
                              cont
                                  .priceCont[widget.index!]
                                  .value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: cursorPos,
                                ),
                              );
                            }
                          }
                        },
                        controller: cont.priceCont[widget.index!],
                        textInputType: TextInputType.numberWithOptions(),
                      ),
                      AppTextField(
                        readOnly: true,
                        hint: 'Total Price',
                        controller:
                            cont.salePart[widget.index!] == 'Accessories'
                                ? cont.accesoriesTotalPrice[widget.index!]
                                : cont.priceCont[widget.index!],
                        textInputType: TextInputType.numberWithOptions(),
                      ),
                      CustomDropdown(
                        items: mop,
                        title:
                            cont.payment[widget.index!] == ''
                                ? 'Select Payment Method'
                                : cont.payment[widget.index!],
                        onTap: (val) {
                          cont.payment[widget.index!] = val!;
                          purchaseInventoryController.payment[widget.index!] =
                              val;
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: appColor,
        ),
      ),
    );
  }
}
