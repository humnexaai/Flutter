import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/sheet_type.dart';

class PdfGenerationService {
  const PdfGenerationService();

  Future<Uint8List> generatePhotoSheetPdf({
    required Uint8List photoBytes,
    required SheetType sheetType,
  }) async {
    final doc = pw.Document();
    final image = pw.MemoryImage(photoBytes);

    switch (sheetType) {
      case SheetType.fourBySix:
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(
              sheetType.widthInch * PdfPageFormat.inch,
              sheetType.heightInch * PdfPageFormat.inch,
            ),
            margin: const pw.EdgeInsets.all(10),
            build: (_) => _buildGrid(
              image,
              totalPhotos: 8,
              columns: 4,
              spacing: 4,
            ),
          ),
        );
        break;
      case SheetType.a4:
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(16),
            build: (_) => _buildGrid(
              image,
              totalPhotos: 32,
              columns: 4,
              spacing: 3,
            ),
          ),
        );
        break;
    }

    return doc.save();
  }

  pw.Widget _buildGrid(
    pw.MemoryImage image, {
    required int totalPhotos,
    required int columns,
    required double spacing,
  }) {
    return pw.GridView(
      crossAxisCount: columns,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: 35 / 45,
      children: List.generate(
        totalPhotos,
        (_) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.4),
          ),
          child: pw.Image(image, fit: pw.BoxFit.cover),
        ),
      ),
    );
  }
}
