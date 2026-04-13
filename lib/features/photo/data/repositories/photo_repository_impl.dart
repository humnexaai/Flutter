import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/processed_photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../services/background_removal_service.dart';
import '../services/face_detection_service.dart';
import '../services/image_compression_service.dart';
import '../services/photo_processing_isolate.dart';

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepositoryImpl(
    faceDetectionService: FaceDetectionService(),
    compressionService: const ImageCompressionService(),
    backgroundRemovalService: BackgroundRemovalService(),
    processingIsolate: PhotoProcessingIsolate(),
  );
});

class PhotoRepositoryImpl implements PhotoRepository {
  PhotoRepositoryImpl({
    required FaceDetectionService faceDetectionService,
    required ImageCompressionService compressionService,
    required BackgroundRemovalService backgroundRemovalService,
    required PhotoProcessingIsolate processingIsolate,
  })  : _faceDetectionService = faceDetectionService,
        _compressionService = compressionService,
        _backgroundRemovalService = backgroundRemovalService,
        _processingIsolate = processingIsolate;

  final FaceDetectionService _faceDetectionService;
  final ImageCompressionService _compressionService;
  final BackgroundRemovalService _backgroundRemovalService;
  final PhotoProcessingIsolate _processingIsolate;

  @override
  Future<ProcessedPhoto> processImage({
    required File source,
    required bool removeBackground,
  }) async {
    final compressed = await _compressionService.compress(source.path);
    final faceData = await _faceDetectionService.detectPrimaryFace(compressed);
    final resultBytes = await _processingIsolate.process(
      imageBytes: await compressed.readAsBytes(),
      faceBoundingBox: faceData?.boundingBox,
      removeBackground: removeBackground,
      backgroundRemovalService: _backgroundRemovalService,
    );

    final outputFile = File(
      '${source.parent.path}/tasveer_processed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await outputFile.writeAsBytes(resultBytes, flush: true);

    return ProcessedPhoto(
      originalPath: source.path,
      processedPath: outputFile.path,
      processedBytes: resultBytes,
      hasBackgroundRemoved: removeBackground,
      faceConfidence: faceData?.confidence,
      generatedAt: DateTime.now(),
      width: 413,
      height: 531,
    );
  }
}
