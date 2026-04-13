import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../../core/utils/local_storage_service.dart';
import '../../data/services/pdf_generation_service.dart';
import '../entities/sheet_type.dart';
import '../../../photo/domain/entities/processed_photo.dart';

final generateSheetPdfUseCaseProvider = Provider<GenerateSheetPdfUseCase>((ref) {
  return GenerateSheetPdfUseCase(const PdfGenerationService());
});

class GenerateSheetPdfUseCase {
  const GenerateSheetPdfUseCase(this._service);

  final PdfGenerationService _service;

  Future<PdfGenerationResult> call({
    required ProcessedPhoto photo,
    required SheetType sheetType,
  }) async {
    final bytes = await _service.generatePhotoSheetPdf(
      photoBytes: photo.processedBytes,
      sheetType: sheetType,
    );
    final savedFile = await LocalStorageService.savePdfToDownloads(
      bytes,
      fileName: 'tasveer_ai_${sheetType.name}.pdf',
    );
    return PdfGenerationResult(bytes: bytes, savedFile: savedFile);
  }
}

class PdfGenerationResult {
  const PdfGenerationResult({
    required this.bytes,
    required this.savedFile,
  });

  final Uint8List bytes;
  final File savedFile;
}
