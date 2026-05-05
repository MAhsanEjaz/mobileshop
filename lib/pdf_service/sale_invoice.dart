import 'dart:async';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shopapp/utils.dart';

import '../main.dart';
import '../models/sale_product_model.dart';

class SaleReport {
  Future<Uint8List> saleReport(
    List<SaleProductModel> sales,
    String? productName,
  ) async {
    final pdf = pw.Document();

    if (sales.isEmpty) {
      throw Exception('Sales list is empty');
    }

    final customer = sales.first;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          58 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 4 * PdfPageFormat.mm,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _headerSection(),
              _divider(),
              _invoiceSection(sales),
              _divider(),
              _customerSection(customer),
              _divider(),
              _saleListSection(sales, productName),
              _divider(thick: true),
              _totalSection(sales),
              _divider(),
              _footerSection(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ---------------- HEADER ----------------
  static pw.Widget _headerSection() {
    return pw.Column(
      children: [
        pw.Text(
          shopData?.name ?? 'SHOP NAME',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text('Sales Receipt', style: pw.TextStyle(fontSize: 9)),
      ],
    );
  }




  // ---------------- INVOICE ----------------
  static pw.Widget _invoiceSection(dynamic sales) {
    final now = DateTime.now();
    return pw.Column(
      children: [
        _infoRow('Invoice', '#${now.millisecondsSinceEpoch}'),
        _infoRow('Date', '${sales[0].date}'),
        _infoRow(
          'Time',
          '${formatTimeAmPm(now)}',
        ),
      ],
    );
  }

  // ---------------- CUSTOMER ----------------
  static pw.Widget _customerSection(SaleProductModel sale) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Customer Info',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 3),
        _infoRow('Name', sale.customerName ?? '-'),
        _infoRow('Phone', sale.customerPhone ?? '-'),
      ],
    );
  }

  // ---------------- SALE LIST ----------------
  static pw.Widget _saleListSection(
    List<SaleProductModel> sales,
    String? productName,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Items',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 3),
        ...sales.map(
          (sale) => pw.Column(
            children: [
              _infoRow('IMEI', sale.imei ?? '-'),
              _infoRow('Product Name', productName! ?? '-'),
              sale.salePart == "Accessories"
                  ? _infoRow('Qty', sale.qty! ?? '-')
                  : pw.SizedBox.shrink as pw.Widget,
              _infoRow('Payment', sale.paymentMethod ?? '-'),
              _infoRow('Price', sale.salePrice ?? '0'),
              pw.SizedBox(height: 3),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- TOTAL ----------------
  static pw.Widget _totalSection(List<SaleProductModel> sales) {
    double total = 0;

    for (var sale in sales) {
      final priceString = (sale.salePrice ?? '0').replaceAll(',', '');
      final price = double.tryParse(priceString) ?? 0;
      final qty = int.tryParse(sale.qty ?? '0') ?? 0;

      total +=
          (double.tryParse(priceString) ?? 0) *
          (int.tryParse(sale.qty ?? '0') ?? 0);
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'TOTAL',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          numberFormat(total),
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  // ---------------- FOOTER ----------------
  static pw.Widget _footerSection() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 6),
        pw.Text(
          'Thank you for your purchase!',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Powered by ${shopData!.name}',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 7),
        ),
      ],
    );
  }

  // ---------------- COMMON ----------------
  static pw.Widget _infoRow(String left, String right) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(child: pw.Text(left, style: pw.TextStyle(fontSize: 8))),
        pw.Text(right, style: pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  static pw.Widget _divider({bool thick = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Divider(thickness: thick ? 1.2 : 0.6),
    );
  }
}
