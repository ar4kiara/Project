import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart' show TextDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import '../../../data/models/debt_entry.dart';
import '../../../utils/currency_formatter.dart';

final exportControllerProvider = Provider((ref) => ExportController());

class ExportController {
  final _currency = CurrencyFormatter();

  Future<String> exportExcel(List<DebtEntry> entries) async {
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').setText('Ara Shop - MyTagiheun');
    sheet.getRangeByName('A2').setText('Histori Hutang');
    sheet.getRangeByName('A4').setText('Nama');
    sheet.getRangeByName('B4').setText('Jenis');
    sheet.getRangeByName('C4').setText('Nominal');
    sheet.getRangeByName('D4').setText('Tanggal');
    sheet.getRangeByName('E4').setText('Jatuh Tempo');

    for (var i = 0; i < entries.length; i++) {
      final row = i + 5;
      final entry = entries[i];
      sheet.getRangeByName('A$row').setText(entry.contactName);
      sheet.getRangeByName('B$row').setText(entry.flow.name.toUpperCase());
      sheet.getRangeByName('C$row').setNumber(entry.nominal.toDouble());
      sheet.getRangeByName('D$row').setDateTime(entry.dibuatPada);
      sheet.getRangeByName('E$row').setDateTime(entry.jatuhTempo ?? entry.dibuatPada);
    }

    sheet.getRangeByName('C:C').numberFormat = r'"Rp" #,##0';
    final bytes = workbook.saveAsStream();
    workbook.dispose();
    final file = await _writeFile('mytagiheun.xlsx', bytes);
    return file.path;
  }

  Future<String> exportPdf(List<DebtEntry> entries) async {
    final doc = pw.Document();
    final currency = _currency;
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Ara Shop - Rekap Hutang', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Tanggal cetak: ${DateTime.now()}'),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['Nama', 'Jenis', 'Nominal', 'Tanggal', 'Jatuh Tempo'],
            data: entries
                .map(
                  (e) => [
                    e.contactName,
                    e.flow.name,
                    currency.format(e.nominal),
                    e.dibuatPada.toIso8601String(),
                    e.jatuhTempo?.toIso8601String() ?? '-',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final file = await _writeFile('mytagiheun.pdf', bytes);
    return file.path;
  }

  Future<String> exportReceipt(List<DebtEntry> entries) async {
    // Hitung tinggi canvas berdasarkan jumlah entries
    final baseHeight = 200.0;
    final entryHeight = 120.0;
    final totalHeight = baseHeight + (entries.length * entryHeight) + 300;
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 400, totalHeight));
    final painter = _ReceiptPainter(entries: entries, currency: _currency);
    painter.paint(canvas, Size(400, totalHeight));
    final picture = recorder.endRecording();
    final image = await picture.toImage(400, totalHeight.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw Exception('Gagal membuat gambar struk');
    final file = await _writeFile('struk_arashop_${DateTime.now().millisecondsSinceEpoch}.png', bytes.buffer.asUint8List());
    return file.path;
  }

  Future<void> shareFile(String path, {String? text}) async {
    await Share.shareXFiles([XFile(path)], text: text);
  }

  Future<void> shareFileToWhatsApp(String path, {String? text}) async {
    // Share file dengan text khusus untuk WhatsApp
    final message = text ?? 'Rekap Hutang dari Ara Shop';
    await Share.shareXFiles(
      [XFile(path)],
      text: message,
      subject: 'Rekap Hutang Ara Shop',
    );
  }

  Future<void> shareText(List<DebtEntry> entries) async {
    final summary = entries.map((e) => '- ${e.contactName} ${e.flow.name} ${_currency.format(e.nominal)}').join('\n');
    final totalPinjam = entries.where((e) => e.isPinjam).fold<int>(0, (sum, e) => sum + e.nominal);
    final totalBayar = entries.where((e) => e.isBayar).fold<int>(0, (sum, e) => sum + e.nominal);
    final sisa = totalPinjam - totalBayar;
    
    await Share.share(
      '📋 *Rekap Hutang Ara Shop*\n\n'
      '📥 Total Pinjam: ${_currency.format(totalPinjam)}\n'
      '📤 Total Bayar: ${_currency.format(totalBayar)}\n'
      '💰 Sisa Hutang: ${_currency.format(sisa)}\n\n'
      'Detail:\n$summary\n\n'
      '_via MyTagiheun App_',
      subject: 'Rekap Hutang Ara Shop',
    );
  }

  Future<File> _writeFile(String name, List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}

class _ReceiptPainter extends CustomPainter {
  _ReceiptPainter({required this.entries, required this.currency});

  final List<DebtEntry> entries;
  final CurrencyFormatter currency;

  @override
  void paint(Canvas canvas, Size size) {
    // Background putih
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Watermark background
    final watermarkPaint = Paint()
      ..color = Colors.pink.shade50.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final watermarkText = TextPainter(
      text: const TextSpan(
        text: 'ARA SHOP',
        style: TextStyle(
          color: Color(0x11F05A7E),
          fontSize: 60,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 4; j++) {
        watermarkText.layout();
        watermarkText.paint(
          canvas,
          Offset(50 + i * 120, 200 + j * 300),
        );
      }
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    void drawText(String text, double x, double y, {
      bool bold = false,
      double fontSize = 14,
      Color color = Colors.black87,
      TextAlign align = TextAlign.left,
    }) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: fontSize,
        ),
      );
      textPainter.layout(maxWidth: size.width - (x * 2));
      if (align == TextAlign.center) {
        textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, y));
      } else {
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    var y = 40.0;

    // Header
    drawText('ARA SHOP', 0, y, bold: true, fontSize: 28, color: Colors.pink.shade700, align: TextAlign.center);
    y += 35;
    drawText('MyTagiheun - Pencatat Hutang', 0, y, fontSize: 12, color: Colors.grey.shade600, align: TextAlign.center);
    y += 30;

    // Divider
    final dividerPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2;
    canvas.drawLine(Offset(30, y), Offset(size.width - 30, y), dividerPaint);
    y += 20;

    // Date
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    drawText(dateFormat.format(DateTime.now()), 0, y, fontSize: 11, color: Colors.grey.shade600, align: TextAlign.center);
    y += 25;

    // Title
    drawText('STRUK REKAP HUTANG', 0, y, bold: true, fontSize: 16, align: TextAlign.center);
    y += 30;

    // Entries
    for (final entry in entries.take(15)) {
      final isPinjam = entry.isPinjam;
      final bgColor = isPinjam ? Colors.red.shade50 : Colors.green.shade50;
      final borderColor = isPinjam ? Colors.red.shade200 : Colors.green.shade200;
      final textColor = isPinjam ? Colors.red.shade700 : Colors.green.shade700;

      // Background box
      final boxPaint = Paint()..color = bgColor;
      final boxRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(30, y, size.width - 60, 100),
        const Radius.circular(8),
      );
      canvas.drawRRect(boxRect, boxPaint);
      
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(boxRect, borderPaint);

      y += 12;
      // Nama dan jenis
      drawText(entry.contactName, 40, y, bold: true, fontSize: 13);
      final typeText = entry.flow.name.toUpperCase();
      textPainter.text = TextSpan(
        text: typeText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isPinjam ? Colors.red.shade900 : Colors.green.shade900,
        ),
      );
      textPainter.layout();
      final typeBgPaint = Paint()..color = borderColor;
      final typeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 30 - textPainter.width - 16, y - 2, textPainter.width + 16, 18),
        const Radius.circular(4),
      );
      canvas.drawRRect(typeRect, typeBgPaint);
      textPainter.paint(canvas, Offset(size.width - 30 - textPainter.width - 8, y));
      
      y += 20;
      // Nominal
      drawText(currency.format(entry.nominal), 40, y, bold: true, fontSize: 15, color: textColor);
      y += 20;
      
      if (entry.keterangan != null) {
        drawText(entry.keterangan!, 40, y, fontSize: 10, color: Colors.grey.shade600);
        y += 15;
      }
      
      if (entry.jatuhTempo != null) {
        final dueDate = DateFormat('dd MMM yyyy').format(entry.jatuhTempo!);
        drawText('Jatuh Tempo: $dueDate', 40, y, fontSize: 9, color: Colors.orange.shade700);
        y += 15;
      }
      
      y += 12;
    }

    if (entries.length > 15) {
      drawText('... dan ${entries.length - 15} entri lainnya', 0, y, fontSize: 10, color: Colors.grey.shade600, align: TextAlign.center);
      y += 20;
    }

    y += 10;
    // Divider
    canvas.drawLine(Offset(30, y), Offset(size.width - 30, y), dividerPaint);
    y += 20;

    // Summary
    final totalPinjam = entries.where((e) => e.isPinjam).fold<int>(0, (sum, e) => sum + e.nominal);
    final totalBayar = entries.where((e) => e.isBayar).fold<int>(0, (sum, e) => sum + e.nominal);
    final sisaHutang = totalPinjam - totalBayar;

    drawText('Total Pinjam', 40, y, fontSize: 12, color: Colors.grey.shade700);
    drawText(currency.format(totalPinjam), size.width - 40, y, fontSize: 13, bold: true, color: Colors.red.shade700);
    y += 18;

    drawText('Total Bayar', 40, y, fontSize: 12, color: Colors.grey.shade700);
    drawText(currency.format(totalBayar), size.width - 40, y, fontSize: 13, bold: true, color: Colors.green.shade700);
    y += 25;

    // Sisa hutang box
    final sisaColor = sisaHutang > 0 ? Colors.orange : Colors.green;
    final sisaBgPaint = Paint()..color = sisaColor.shade50;
    final sisaBorderPaint = Paint()
      ..color = sisaColor.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final sisaRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(30, y, size.width - 60, 40),
      const Radius.circular(8),
    );
    canvas.drawRRect(sisaRect, sisaBgPaint);
    canvas.drawRRect(sisaRect, sisaBorderPaint);

    y += 12;
    drawText('Sisa Hutang', 40, y, fontSize: 12, bold: true, color: sisaColor.shade900);
    drawText(currency.format(sisaHutang), size.width - 40, y, fontSize: 16, bold: true, color: sisaColor.shade900);
    y += 35;

    // Divider
    canvas.drawLine(Offset(30, y), Offset(size.width - 30, y), dividerPaint);
    y += 20;

    // Footer
    drawText('Terima kasih atas kepercayaannya!', 0, y, fontSize: 11, color: Colors.grey.shade600, align: TextAlign.center);
    y += 18;
    drawText('www.arashop.com', 0, y, fontSize: 9, color: Colors.grey.shade500, align: TextAlign.center);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


