import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:shopapp/main.dart';

import '../models/cash_model.dart';

class HomeReport {
  static homeReport(List<CashData> cashData, bool status) async {
    final pdf = pw.Document();

    // Typical thermal receipt width: 58mm = 165pt, height can be dynamic
    final pageWidth = 150 * PdfPageFormat.mm;
    final pageHeight = 200 * PdfPageFormat.mm; // can be bigger if needed

    final tableHeaders = [
      'Sr',
      'Date',
      'Purchaser Name',
      'PName',
      'IMEI',
      'Amount',
      'Status',
      'Sale Amount',
      'Qty',
      'Profit',
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        // pageFormat: PdfPageFormat(
        //   150 * PdfPageFormat.mm, // your custom width
        //   3000 * PdfPageFormat.mm, // very tall height
        // ),
        margin: const pw.EdgeInsets.all(20),
        build:
            (context) => [
              _headerSection(),
              pw.SizedBox(height: 8),
              _invoiceInfoSection(),
              pw.SizedBox(height: 18),
              _tableSection(tableHeaders, cashData, status),
              pw.SizedBox(height: 18),
              _summarySection(cashData),
              pw.Divider(),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  "Thank you for your business!",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey700,
                  ),
                ),
              ),
            ],
      ),
    );

    return pdf.save();
  }

  // ---------------------------------------------------------------
  // HEADER SECTION
  // ---------------------------------------------------------------
  static pw.Widget _headerSection() {
    return pw.Column(
      children: [
        pw.Text(
          "Daily Activity Report",
          style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Container(height: 1.5, color: PdfColors.blueGrey900),
        pw.SizedBox(height: 10),
      ],
    );
  }

  // ---------------------------------------------------------------
  // COMPANY + CUSTOMER DETAILS
  // ---------------------------------------------------------------
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

  // ---------------------------------------------------------------
  // TABLE SECTION
  // ---------------------------------------------------------------
  static pw.Widget _tableSection(
    List<String> headers,
    List<CashData> cashData,
    bool sale,
  ) {
    final filteredList =
        cashData.where((e) {
          final salePrice = int.tryParse(e.profit ?? '0') ?? 0;

          // KEEP stock
          if (e.mobileDetail?.productStatus == 'stock') {
            return true;
          }

          // KEEP sale ONLY if salePrice > 0
          if (e.mobileDetail?.productStatus == 'sale' && e.profit != null) {
            return true;
          }

          // REMOVE everything else (sale with 0)
          return false;
        }).toList();

    int totalSaleAmount = 0;
    int totalProfitAmount = 0;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FixedColumnWidth(25),
        1: const pw.FixedColumnWidth(60),
        2: const pw.FlexColumnWidth(),
        3: const pw.FlexColumnWidth(),
        4: const pw.FixedColumnWidth(55),
        5: const pw.FixedColumnWidth(45),
        6: const pw.FixedColumnWidth(60),
        7: const pw.FixedColumnWidth(45),
      },
      children: [
        // HEADER
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue100),
          children: headers.map((e) => _tableHeader(e)).toList(),
        ),

        // BODY ROWS
        ...List.generate(filteredList.length, (index) {
          final data = filteredList[index];

          final price = int.tryParse(data.mobileDetail?.price ?? '0') ?? 0;
          final sale = int.tryParse(data.salePrice ?? '0') ?? 0;
          final profitPrice = sale - price;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 0 ? PdfColors.grey100 : PdfColors.white,
            ),
            children: [
              _cell("${index + 1}", bold: true),
              _cell(data.date ?? ''),
              _cell(data.mobileDetail!.purchaserName ?? ''),

              _cell(
                (data.mobileDetail!.model!.isEmpty ||
                        data.mobileDetail!.brand!.isEmpty)
                    ? data.mobileDetail!.accessories!
                    : "${data.mobileDetail?.model ?? ''} ${data.mobileDetail?.brand ?? ''}",
              ),
              _cell(data.imei ?? ''),
              _cell(data.mobileDetail?.price ?? ''),
              _cell(data.mobileDetail!.productStatus ?? ''),
              _cell(data.salePrice ?? '0'),
              _cell(data.mobileDetail!.qty ?? '1'),

              _cell(data.profit ?? '-'),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey900,
        ),
      ),
    );
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // SUMMARY SECTION
  // ---------------------------------------------------------------
  static pw.Widget _summarySection(List<CashData> cashData) {
    double totalSale = 0;
    double totalProfit = 0;

    // Filter cashData for 'sale' items with profit
    var saleData =
        cashData
            .where(
              (e) =>
                  e.mobileDetail?.productStatus == 'sale' && e.profit != null,
            )
            .toList();

    // Sum totalSale and totalProfit
    for (var v in saleData) {
      print('profitData--->${v.salePrice}');
      totalSale += double.tryParse(v.salePrice ?? "0") ?? 0;
      totalProfit += double.tryParse(v.profit ?? "0") ?? 0;
    }

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            "Summary",
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 8),
          _summaryRow("Total Sale:", totalSale.toStringAsFixed(2)),
          _summaryRow("Total Profit:", totalProfit.toStringAsFixed(2)),
        ],
      ),
    );
  }

  static pw.Widget _summaryRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(width: 10),
          pw.Text(
            "Rs $value",
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.normal,
              color: PdfColors.blueGrey900,
            ),
          ),
        ],
      ),
    );
  }
}
