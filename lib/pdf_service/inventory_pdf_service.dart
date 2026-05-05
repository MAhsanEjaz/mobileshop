import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shopapp/utils.dart';

import '../main.dart';
import '../models/product_model.dart';

class InventoryPdfService {
  static inventoryPdfService(
    List<StockProducts> purchase,
    bool? purchaseEnable,
    bool? saleEnable,
    List<SaleProducts> sale,
  ) {
    print('pur-->$purchaseEnable');
    print('sale-->$saleEnable');

    num totalSalePrice = 0;
    num totalPurchasePrice = 0;

    num totalAccessoriesPrice = 0;
    num totalMobilesPrice = 0;

    /////
    num saleTotalAccessoriesPrice = 0;
    num saleTotalMobilesPrice = 0;

    for (var l in sale) {
      totalSalePrice += num.parse(l.price!.replaceAll(',', ''));
    }
    for (var l in purchase) {
      totalPurchasePrice += num.parse(l.price!.replaceAll(',', ''));
    }

    final pdf = pw.Document();
    //forStock---
    final filterAccessories =
        purchase.where((e) => e.salePart == "Accessories").toList();
    final filterMobiles =
        purchase.where((e) => e.salePart == "Mobile").toList();

    //forSoldItem---->

    final saleAccessories =
        sale.where((e) => e.salePart == "Accessories").toList();
    final saleMobile = sale.where((e) => e.salePart == "Mobile").toList();

    ///for Stock InHand

    for (var l in filterAccessories) {
      final price = int.tryParse(l.price ?? '0') ?? 0;
      final qty = int.tryParse(l.qty ?? '1') ?? 1;
      final itemTotal = price * qty;
      totalAccessoriesPrice += itemTotal;
    }

    for (var l in filterMobiles) {
      final cleanPrice = l.price!.replaceAll(',', '');

      final price = num.tryParse(cleanPrice ?? '0') ?? 0;

      totalMobilesPrice += price;

      print("mobiles --> ${l.model}");
      print("prices --> ${l.price}");
      print("totalMobilesPrice --> ${totalMobilesPrice}");
    }

    //for Sale Items Calculations------>>>>>>>>

    for (var l in saleAccessories) {
      final price = int.tryParse(l.customerData!.salePrice ?? '0') ?? 0;
      final qty = int.tryParse(l.customerData!.qty ?? '1') ?? 1;
      final itemTotal = price * qty;
      saleTotalAccessoriesPrice += itemTotal;
    }

    for (var l in saleMobile) {
      final cleanPrice = l.customerData!.salePrice!.replaceAll(',', '');

      final price = num.tryParse(cleanPrice ?? '0') ?? 0;

      saleTotalMobilesPrice += price;

      print("mobiles --> ${l.model}");
      print("prices --> ${l.price}");
      print("totalMobilesPrice --> $totalMobilesPrice");
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // ======= HEADER =======
            pw.Center(
              child: pw.Text(
                saleEnable == true ? "SALE REPORT" : "INVENTORY REPORT",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color:
                      saleEnable == true ? PdfColors.red800 : PdfColors.blue900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            pw.SizedBox(height: 6),

            _invoiceInfoSection(),

            purchase.isEmpty
                ? pw.SizedBox.shrink()
                : pw.Center(
                  child: pw.Text(
                    saleEnable == true
                        ? "Sale Summary"
                        : "Stock In Hand Summary",
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey700,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                ),
            purchase.isEmpty
                ? pw.SizedBox.shrink()
                : pw.SizedBox(height: saleEnable == true ? 0 : 10),
            purchase.isEmpty
                ? pw.SizedBox.shrink()
                : pw.Divider(thickness: 2, color: PdfColors.blue900),

            purchase.isEmpty
                ? pw.SizedBox.shrink()
                : pw.SizedBox(height: saleEnable == true ? 0 : 20),

            // ======= PURCHASE TABLE =======
            purchase.isEmpty ? pw.SizedBox.shrink() : pw.SizedBox(height: 8),

            pw.SizedBox(height: purchaseEnable == true ? 10 : 0),
            (purchaseEnable == true)
                ? pw.Text(
                  "Accessories Details",

                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                )
                : pw.SizedBox.shrink(),
            pw.SizedBox(height: purchaseEnable == true ? 10 : 0),

            // ======= TABLE HEADER =======
            (purchaseEnable == false)
                ? pw.SizedBox.shrink()
                : pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey600,
                    width: 0.8,
                  ),
                  columnWidths: const {
                    0: pw.FixedColumnWidth(30),
                    1: pw.FlexColumnWidth(2),
                    2: pw.FlexColumnWidth(2),
                    3: pw.FlexColumnWidth(1),
                    4: pw.FlexColumnWidth(1.5),
                    5: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue900,
                      ),
                      children: [
                        _headerCell('Sr'),
                        _headerCell('Imei'),
                        _headerCell('Name'),
                        _headerCell('Qty'),
                        _headerCell('Unit Price'),
                        _headerCell('Total Price'),
                      ],
                    ),
                  ],
                ),

            // ======= PURCHASE LIST =======
            (purchaseEnable == false)
                ? pw.SizedBox.shrink()
                : pw.ListView.builder(
                  itemBuilder: (context, index) {
                    final isEven = index % 2 == 0;
                    final pData = filterAccessories[index];

                    final qty = int.tryParse(pData.qty ?? '1') ?? 1;

                    final cleanPrice = (pData.price ?? '0').replaceAll(',', '');


                    final price = int.tryParse(cleanPrice) ?? 0;

                    final totalPrice = qty * price;

                    return pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.grey600,
                        width: 0.8,
                      ),
                      columnWidths: const {
                        0: pw.FixedColumnWidth(30),
                        1: pw.FlexColumnWidth(2),
                        2: pw.FlexColumnWidth(2),
                        3: pw.FlexColumnWidth(1),
                        4: pw.FlexColumnWidth(1.5),
                        5: pw.FlexColumnWidth(1.5),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: isEven ? PdfColors.grey100 : PdfColors.white,
                          ),
                          children: [
                            _bodyCell(
                              '${index + 1}',
                              align: pw.TextAlign.center,
                            ),
                            _bodyCell('${pData.imei}'),
                            _bodyCell('${pData.accessories}'),
                            _bodyCell('${pData.qty}'),
                            _bodyCell('PKR ${pData.price}', bold: true),
                            _bodyCell(
                              'PKR ${numberFormat(totalPrice)}',
                              bold: true,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  itemCount: filterAccessories.length,
                ),

            (saleEnable == true)
                ? pw.SizedBox.shrink()
                : pw.SizedBox(height: 10),
            (saleEnable == true)
                ? pw.SizedBox.shrink()
                : pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Accessories Total Price:"),
                    pw.Text(
                      "${numberFormat(totalAccessoriesPrice)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),

            // forMobiles----
            pw.SizedBox(height: purchaseEnable == true ? 10 : 0),
            (purchaseEnable == true)
                ? pw.Text(
                  "Mobile Details",

                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                )
                : pw.SizedBox.shrink(),
            pw.SizedBox(height: 10),

            // ======= TABLE HEADER =======
            (purchaseEnable == false)
                ? pw.SizedBox.shrink()
                : pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey600,
                    width: 0.8,
                  ),
                  columnWidths: const {
                    0: pw.FixedColumnWidth(30),
                    1: pw.FlexColumnWidth(2),
                    2: pw.FlexColumnWidth(2),
                    3: pw.FlexColumnWidth(1.5),
                    4: pw.FlexColumnWidth(1.5),
                    5: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue900,
                      ),
                      children: [
                        _headerCell('Sr'),
                        _headerCell('Imei'),
                        _headerCell('Name'),
                        _headerCell('Ram'),
                        _headerCell('Storage'),
                        _headerCell('Price'),
                      ],
                    ),
                  ],
                ),

            // ======= PURCHASE LIST =======
            (purchaseEnable == false)
                ? pw.SizedBox.shrink()
                : pw.ListView.builder(
                  itemBuilder: (context, index) {
                    final isEven = index % 2 == 0;
                    final pData = filterMobiles[index];

                    return pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.grey600,
                        width: 0.8,
                      ),
                      columnWidths: const {
                        0: pw.FixedColumnWidth(30),
                        1: pw.FlexColumnWidth(2),
                        2: pw.FlexColumnWidth(2),
                        3: pw.FlexColumnWidth(1.5),
                        4: pw.FlexColumnWidth(1.5),
                        5: pw.FlexColumnWidth(1.5),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: isEven ? PdfColors.grey100 : PdfColors.white,
                          ),
                          children: [
                            _bodyCell(
                              '${index + 1}',
                              align: pw.TextAlign.center,
                            ),
                            _bodyCell('${pData.imei}'),
                            _bodyCell('${pData.brand} ${pData.model}'),
                            _bodyCell('${pData.ram}'),
                            _bodyCell('${pData.storage}'),
                            _bodyCell('PKR ${pData.price}', bold: true),
                          ],
                        ),
                      ],
                    );
                  },
                  itemCount: filterMobiles.length,
                ),

            (saleEnable == true)
                ? pw.SizedBox.shrink()
                : pw.SizedBox(height: 10),
            (saleEnable == true)
                ? pw.SizedBox.shrink()
                : pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Mobiles Total Price:"),
                    pw.Text(
                      "${numberFormat(totalMobilesPrice)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
            filterAccessories.isEmpty
                ? pw.SizedBox.shrink()
                : pw.SizedBox(height: saleEnable == true ? 0 : 25),

            // ======= SALES TABLE =======
            (saleEnable == false)
                ? pw.SizedBox.shrink()
                : pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red50,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: pw.Text(
                    "Accessories Sold Details",
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red800,
                    ),
                  ),
                ),
            sale.isEmpty ? pw.SizedBox.shrink() : pw.SizedBox(height: 8),

            (saleEnable == false)
                ? pw.SizedBox.shrink()
                : pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey600,
                    width: 0.8,
                  ),
                  columnWidths: const {
                    0: pw.FixedColumnWidth(30),
                    1: pw.FlexColumnWidth(2),
                    2: pw.FlexColumnWidth(2),
                    3: pw.FlexColumnWidth(1.5),
                    4: pw.FlexColumnWidth(1.5),
                    5: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.red800,
                      ),
                      children: [
                        _headerCell('Sr', color: PdfColors.white),
                        _headerCell('Imei', color: PdfColors.white),
                        _headerCell('Name', color: PdfColors.white),
                        _headerCell('Qty', color: PdfColors.white),
                        _headerCell('Price', color: PdfColors.white),
                        _headerCell('Total Price', color: PdfColors.white),
                      ],
                    ),
                  ],
                ),

            (saleEnable == false)
                ? pw.SizedBox.shrink()
                : pw.ListView.builder(
                  itemBuilder: (context, index) {
                    final even = index % 2 == 0;
                    final sData = saleAccessories[index];

                    final qty = int.tryParse(sData.customerData!.qty!);
                    final salePrice = sData.customerData?.salePrice ?? "0";
                    final cleanPrice = salePrice.replaceAll(",", "");
                    final price = double.tryParse(
                        (cleanPrice ?? "0").replaceAll(",", "")
                    ) ?? 0;


                    return pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.grey600,
                        width: 0.8,
                      ),
                      columnWidths: const {
                        0: pw.FixedColumnWidth(30),
                        1: pw.FlexColumnWidth(2),
                        2: pw.FlexColumnWidth(2),
                        3: pw.FlexColumnWidth(2),
                        4: pw.FlexColumnWidth(1.5),
                        5: pw.FlexColumnWidth(1.5),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color:
                                even == index
                                    ? PdfColors.grey100
                                    : PdfColors.white,
                          ),
                          children: [
                            _bodyCell(
                              '${index + 1}',
                              align: pw.TextAlign.center,
                            ),

                            _bodyCell('${sData.imei}'),
                            _bodyCell('${sData.accessories}'),
                            _bodyCell('${sData.customerData!.qty}'),
                            _bodyCell(
                              'PKR ${sData.customerData!.salePrice}',
                              bold: true,
                            ),
                            _bodyCell(
                              'PKR ${numberFormat(qty! * price!)}',
                              bold: true,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  itemCount: saleAccessories.length,
                ),

            pw.SizedBox(height: saleEnable == true ? 12 : 0),

            (saleEnable == true)
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Accessories Total Sales:"),
                    pw.Text(
                      "${numberFormat(saleTotalAccessoriesPrice)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                )
                : pw.SizedBox.shrink(),

            (saleEnable == true)
                ? pw.SizedBox(height: 10)
                : pw.SizedBox.shrink(),
            (saleEnable == false)
                ? pw.SizedBox.shrink()
                : pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red50,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: pw.Text(
                    "Mobiles Sold Details",
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red800,
                    ),
                  ),
                ),
            pw.SizedBox(height: saleEnable == false ? 0 : 10),
            (saleEnable == false)
                ? pw.SizedBox.shrink()
                : pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey600,
                    width: 0.8,
                  ),
                  columnWidths: const {
                    0: pw.FixedColumnWidth(30),
                    1: pw.FlexColumnWidth(2),
                    2: pw.FlexColumnWidth(2),
                    3: pw.FlexColumnWidth(1.5),
                    4: pw.FlexColumnWidth(1.5),
                    5: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.red800,
                      ),
                      children: [
                        _headerCell('Sr'),
                        _headerCell('Imei'),
                        _headerCell('Name'),
                        _headerCell('Ram'),
                        _headerCell('Storage'),
                        _headerCell('Price'),
                      ],
                    ),
                  ],
                ),

            (saleEnable == false)
                ? pw.SizedBox.shrink()
                : pw.ListView.builder(
                  itemBuilder: (context, index) {
                    final even = index % 2 == 0;
                    final sData = saleMobile[index];

                    return pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.grey600,
                        width: 0.8,
                      ),
                      columnWidths: const {
                        0: pw.FixedColumnWidth(30),
                        1: pw.FlexColumnWidth(2),
                        2: pw.FlexColumnWidth(2),
                        3: pw.FlexColumnWidth(1.5),
                        4: pw.FlexColumnWidth(1.5),
                        5: pw.FlexColumnWidth(1.5),
                      },

                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color:
                                even == index
                                    ? PdfColors.grey100
                                    : PdfColors.white,
                          ),
                          children: [
                            _bodyCell(
                              '${index + 1}',
                              align: pw.TextAlign.center,
                            ),

                            _bodyCell('${sData.imei}'),
                            _bodyCell('${sData.brand} ${sData.model}'),
                            _bodyCell('${sData.ram}'),
                            _bodyCell('${sData.storage}'),
                            _bodyCell(
                              'PKR ${sData.customerData!.salePrice}',
                              bold: true,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  itemCount: saleMobile.length,
                ),

            pw.SizedBox(height: saleEnable == true ? 12 : 0),

            (saleEnable == true)
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Mobiles Total Sales:"),
                    pw.Text(
                      "${numberFormat(saleTotalMobilesPrice)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                )
                : pw.SizedBox.shrink(),
            pw.SizedBox(height: 30),

            // ======= FOOTER =======
            pw.Divider(thickness: 1, color: PdfColors.grey500),

            saleEnable == true
                ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Grand Total Sales'),
                    pw.Text(
                      'Rs: ${numberFormat(saleTotalMobilesPrice + saleTotalAccessoriesPrice)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                )
                : pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Grand Total Stock In Hand'),
                    pw.Text(
                      'Rs: ${numberFormat(totalMobilesPrice + totalAccessoriesPrice)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),

            pw.SizedBox(height: 5),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Generated on ${DateTime.now().toString().split(' ')[0]}",
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ======= Reusable Header Cell =======
  static pw.Widget _headerCell(
    String text, {
    PdfColor color = PdfColors.white,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: color,
          fontWeight: pw.FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.3,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // ======= Reusable Body Cell =======
  static pw.Widget _bodyCell(
    String text, {
    bool bold = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: PdfColors.blueGrey900,
          ),
          textAlign: align,
        ),
      ),
    );
  }

  static pw.Widget _invoiceInfoSection() {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _title("Company Info"),
            _text(
              "${shopData?.name ?? loginModelUser!.user!.shopData!.name}",
              font: pw.FontWeight.bold,
            ),
            // _text("Johar Town Lahore, Pakistan"),
            // _text("Phone: +92 300 1234567"),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // _title("Customer Info"),
            // _text("Walk-in Customer"),
            // _text("Payment Status: Paid"),
            // _text("Invoice No: #${DateTime.now().millisecondsSinceEpoch}"),
          ],
        ),
      ],
    );
  }

  static pw.Widget _title(String text) => pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blueGrey800,
    ),
  );

  static pw.Widget _text(String text, {pw.FontWeight? font}) => pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 11,
      color: PdfColors.grey800,
      fontWeight: font,
    ),
  );

  static pw.Widget _totalRow(String title, num amount) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.blue900, width: 0.8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Icon(
                pw.IconData(0xf30a), // Cupertino money icon (dollar/bank note)
                size: 16,
                color: PdfColors.blue900,
              ),
              pw.SizedBox(width: 6),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ],
          ),
          pw.Text(
            "PKR ${amount.toString()}",
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
        ],
      ),
    );
  }
}
