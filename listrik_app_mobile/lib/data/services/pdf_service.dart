import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/order_model.dart';

class PdfService {
  static Future<void> generateCertificate(OrderModel order) async {
    final pdf = pw.Document();

    // Load fonts if necessary, or use default
    final font = await PdfGoogleFonts.plusJakartaSansBold();
    final regularFont = await PdfGoogleFonts.plusJakartaSansRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('SERTIFIKAT RESMI', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.blue900)),
                        pw.Text('LAIK OPERASI', style: pw.TextStyle(font: font, fontSize: 24, color: PdfColors.blue700)),
                      ],
                    ),
                    pw.Container(
                      height: 60,
                      width: 60,
                      color: PdfColors.blue900,
                      child: pw.Center(child: pw.Text('LOGO', style: pw.TextStyle(color: PdfColors.white, fontSize: 10))),
                    ),
                  ],
                ),
                pw.Divider(thickness: 2, color: PdfColors.blue900),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('NOMOR SERTIFIKAT:', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.blue700)),
                      pw.Text('SLO/${order.agendaNumber}', style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.blue700)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                _buildPdfRow('Nama Pemohon', 'Budi Santoso', regularFont, font),
                _buildPdfRow('Alamat', order.address, regularFont, font),
                _buildPdfRow('Daya Listrik', '${order.powerCapacity} Watt', regularFont, font),
                _buildPdfRow('Jenis Layanan', order.serviceTypeLabel, regularFont, font),
                _buildPdfRow('Tanggal Terbit', '06 Mar 2026', regularFont, font),
                pw.SizedBox(height: 40),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    children: [
                      pw.Text('Diterbitkan Secara Digital oleh:', style: pw.TextStyle(font: regularFont, fontSize: 10)),
                      pw.SizedBox(height: 40),
                      pw.Text('LIT-TR INDONESIA', style: pw.TextStyle(font: font, fontSize: 12)),
                      pw.Text('Listrik App Platform', style: pw.TextStyle(font: regularFont, fontSize: 10)),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  color: PdfColors.green50,
                  child: pw.Row(
                    children: [
                      pw.Text('✓', style: pw.TextStyle(color: PdfColors.green700, fontSize: 14)),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: pw.Text(
                          'Sertifikat ini sah dan dapat diverifikasi melalui aplikasi Listrik App menggunakan kode unik agenda ${order.agendaNumber}',
                          style: pw.TextStyle(font: regularFont, fontSize: 8, color: PdfColors.green700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildPdfRow(String label, String value, pw.Font reg, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 120, child: pw.Text(label, style: pw.TextStyle(font: reg, fontSize: 10, color: PdfColors.grey600))),
          pw.Text(':', style: pw.TextStyle(font: reg, fontSize: 10)),
          pw.SizedBox(width: 10),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 10, color: PdfColors.grey800))),
        ],
      ),
    );
  }
}
