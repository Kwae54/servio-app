import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/billing/model/bill.dart';

class ThermalPrintService {
  static const double _paperWidth = 80 * PdfPageFormat.mm;

  static const double _margin = 2 * PdfPageFormat.mm;

  static const double _printerOffsetQrX = -4 * PdfPageFormat.mm;

  static const double _printerOffsetBillX = -1 * PdfPageFormat.mm;

  static Future<pw.Font> _regularFont() async {
    final data = await rootBundle.load('assets/fonts/NotoSansThai-Regular.ttf');

    return pw.Font.ttf(data);
  }

  static Future<pw.Font> _boldFont() async {
    final data = await rootBundle.load('assets/fonts/NotoSansThai-Bold.ttf');

    return pw.Font.ttf(data);
  }

  // =========================================================
  // QR
  // =========================================================

  static Future<void> printSessionQR({
    required String restaurantName,
    required String tableNo,
    required String orderUrl,
  }) async {
    final regular = await _regularFont();
    final bold = await _boldFont();

    final pdf = pw.Document();

    final format = PdfPageFormat(
      _paperWidth,
      100 * PdfPageFormat.mm,
      marginLeft: _margin,
      marginRight: _margin,
      marginTop: _margin,
      marginBottom: _margin,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (_) {
          final contentWidth = _paperWidth - (_margin * 2);

          return pw.Transform.translate(
            offset: PdfPoint(_printerOffsetQrX, 0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: contentWidth,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    restaurantName,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: bold, fontSize: 18),
                  ),
                ),

                pw.SizedBox(height: 5),

                pw.Container(
                  width: contentWidth,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'โต๊ะ $tableNo',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: bold, fontSize: 16),
                  ),
                ),

                pw.SizedBox(height: 5),

                pw.Container(
                  width: contentWidth,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'สแกน QR เพื่อสั่งอาหาร',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: regular, fontSize: 10),
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Container(
                  width: contentWidth,
                  alignment: pw.Alignment.center,
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: orderUrl,
                    width: 48 * PdfPageFormat.mm,
                    height: 48 * PdfPageFormat.mm,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.Container(
                  width: contentWidth,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'กรุณาเก็บ QR นี้ไว้จนกว่าจะชำระเงิน',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: regular, fontSize: 8),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'servio-qr-$tableNo.pdf',
      format: format,
      onLayout: (_) async {
        return pdf.save();
      },
    );
  }

  // =========================================================
  // Receipt
  // =========================================================

  static Future<void> printBill({required Bill bill}) async {
    final regular = await _regularFont();

    final bold = await _boldFont();

    final pdf = pw.Document();

    final heightMm =
        105 + (bill.items.length * 12) + (bill.discounts.length * 8);

    final format = PdfPageFormat(
      _paperWidth,
      heightMm * PdfPageFormat.mm,
      marginLeft: 4 * PdfPageFormat.mm,
      marginRight: 12 * PdfPageFormat.mm,
      marginTop: 4 * PdfPageFormat.mm,
      marginBottom: 4 * PdfPageFormat.mm,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (_) {
          return pw.Container(
            width: 64 * PdfPageFormat.mm,
            child: pw.DefaultTextStyle(
              style: pw.TextStyle(font: regular, fontSize: 9),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Center(
                    child: pw.Text(
                      bill.restaurantName,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(font: bold, fontSize: 16),
                    ),
                  ),

                  pw.SizedBox(height: 3),

                  pw.Center(
                    child: pw.Text(
                      'ใบแจ้งยอด',
                      style: pw.TextStyle(font: bold, fontSize: 12),
                    ),
                  ),

                  pw.Center(
                    child: pw.Text(
                      'BILL',
                      style: pw.TextStyle(font: regular, fontSize: 8),
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  _textRow('โต๊ะ', bill.tableNo, regular),

                  _textRow('วันที่', _formatDateTime(DateTime.now()), regular),

                  pw.SizedBox(height: 6),

                  _divider(),

                  pw.SizedBox(height: 5),

                  // =========================
                  // Items
                  // =========================
                  ...bill.items.map((item) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 7),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          pw.Text(
                            item.menuItemName,
                            style: pw.TextStyle(font: regular, fontSize: 9),
                          ),

                          pw.SizedBox(height: 2),

                          pw.SizedBox(
                            width: 64 * PdfPageFormat.mm,
                            child: pw.Row(
                              children: [
                                pw.Text(
                                  '${item.quantity} x '
                                  '${_money(item.unitPriceSatang)}',
                                  style: pw.TextStyle(
                                    font: regular,
                                    fontSize: 8,
                                  ),
                                ),

                                pw.Spacer(),

                                pw.Text(
                                  _money(item.totalSatang),
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    font: regular,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  _divider(),

                  pw.SizedBox(height: 5),

                  // =========================
                  // Summary
                  // =========================
                  _moneyRow(
                    label: 'ยอดรวม',
                    value: bill.subtotalSatang,
                    font: regular,
                  ),

                  ...bill.discounts.map(
                    (discount) => _moneyRow(
                      label: discount.discountName,
                      value: -discount.discountAmountSatang,
                      font: regular,
                    ),
                  ),

                  if (bill.discountTotalSatang > 0)
                    _moneyRow(
                      label: 'ส่วนลดรวม',
                      value: -bill.discountTotalSatang,
                      font: regular,
                    ),

                  pw.SizedBox(height: 4),

                  _divider(),

                  pw.SizedBox(height: 5),

                  _moneyRow(
                    label: 'ยอดสุทธิ',
                    value: bill.totalSatang,
                    font: bold,
                    fontSize: 12,
                  ),

                  pw.SizedBox(height: 12),

                  pw.Center(
                    child: pw.Text(
                      'กรุณาตรวจสอบรายการก่อนชำระเงิน',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(font: regular, fontSize: 8),
                    ),
                  ),

                  pw.SizedBox(height: 3),

                  pw.Center(
                    child: pw.Text(
                      'ขอบคุณที่ใช้บริการ',
                      style: pw.TextStyle(font: regular, fontSize: 8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'bill-${bill.tableNo}.pdf',
      format: format,
      onLayout: (_) async {
        return pdf.save();
      },
    );
  }

  // static const double _printerOffsetX = 3 * PdfPageFormat.mm;

  static pw.Widget _divider() {
    return pw.Container(height: 0.5, color: PdfColors.grey600);
  }

  static pw.Widget _textRow(String left, String right, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.Text(left, style: pw.TextStyle(font: font, fontSize: 8)),

          pw.Spacer(),

          pw.Text(
            right,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(font: font, fontSize: 8),
          ),
        ],
      ),
    );
  }

  static pw.Widget _moneyRow({
    required String label,
    required int value,
    required pw.Font font,
    double fontSize = 9,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(font: font, fontSize: fontSize),
          ),

          pw.Spacer(),

          pw.Text(
            value < 0 ? '-${_money(-value)}' : _money(value),
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(font: font, fontSize: fontSize),
          ),
        ],
      ),
    );
  }

  static String _money(int satang) {
    final baht = satang ~/ 100;
    final decimal = satang % 100;

    return '$baht.${decimal.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime date) {
    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');

    final month = local.month.toString().padLeft(2, '0');

    final hour = local.hour.toString().padLeft(2, '0');

    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/${local.year} '
        '$hour:$minute';
  }
}
