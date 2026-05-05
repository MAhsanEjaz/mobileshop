import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:shopapp/main.dart';
import 'package:shopapp/utils.dart';

import '../models/cash_model.dart';

class HomeCustomerReport {
  static homeReport(List<CashData> cashData, bool status) async {
    final pdf = pw.Document();

    getApplicationCacheDirectory();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          58 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 4 * PdfPageFormat.mm,
        ),
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _headerSection(),
                _divider(),
                _invoiceInfoSection(),
                _divider(),
                _itemsSection(cashData, status),
                // _divider(thick: true),
                // _summarySection(cashData),
                _divider(),
                pw.Center(
                  child: pw.Text(
                    "Thank you",
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
      ),
    );

    return pdf.save();
  }

  // ---------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------
  static pw.Widget _headerSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          "${shopData!.name}",
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
      ],
    );
  }

  // ---------------------------------------------------------------
  // INVOICE INFO
  // ---------------------------------------------------------------
  static pw.Widget _invoiceInfoSection() {
    final now = DateTime.now();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _infoRow("Invoice", "#${now.millisecondsSinceEpoch}"),
        _infoRow("Date", "${now.day}/${now.month}/${now.year}"),
        _infoRow("Time", "${now.hour}:${now.minute}"),
      ],
    );
  }

  static pw.Widget _infoRow(String left, String right) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(left, style: pw.TextStyle(fontSize: 8)),
        pw.Text(right, style: pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  // ---------------------------------------------------------------
  // ITEMS (REPLACED TABLE → THERMAL STYLE)
  // ---------------------------------------------------------------
  static pw.Widget _itemsSection(List<CashData> cashData, bool sale) {
    final filterItem =
        cashData.where((e) {
          if (sale) {
            return e.status == 'sale';
          } else {
            return e.status == 'stock';
          }
        }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: List.generate(filterItem.length, (index) {
        final data = filterItem[index];

        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "${(data.mobileDetail!.salePart == "Accessories") ? data.mobileDetail!.accessories : ("${data.mobileDetail!.brand}${data.mobileDetail!.model}")}",

                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                "IMEI: ${data.imei ?? ''}",
                style: pw.TextStyle(fontSize: 8),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Price", style: pw.TextStyle(fontSize: 8)),
                  pw.Text(
                    "Rs ${data.salePrice ?? data.purchasePrice}",
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------
  // SUMMARY (LOGIC UNCHANGED)
  // ---------------------------------------------------------------
  // static pw.Widget _summarySection(List<CashData> cashData) {
  //   double totalSale = 0;
  //   double totalProfit = 0;
  //
  //   for (var v in cashData) {
  //     totalSale += double.tryParse(v.purchasePrice ?? "0") ?? 0;
  //     totalProfit += double.tryParse(v.profit ?? "0") ?? 0;
  //   }
  //
  //   return pw.Column(
  //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //     children: [
  //       _summaryRow("TOTAL SALE", numberFormat(double.parse(totalSale.toString()))),
  //       _summaryRow("TOTAL PROFIT", numberFormat(double.parse(totalProfit.toString()))),
  //     ],
  //   );
  // }

  static pw.Widget _summaryRow(String title, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          "Rs ${value}",
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // DIVIDER
  // ---------------------------------------------------------------
  static pw.Widget _divider({bool thick = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Container(height: thick ? 1.4 : 0.8, color: PdfColors.black),
    );
  }
}
