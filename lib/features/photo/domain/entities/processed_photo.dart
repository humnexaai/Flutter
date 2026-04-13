import 'dart:io';
import 'dart:typed_data';

class ProcessedPhoto {
  const ProcessedPhoto({
    required this.originalPath,
    required this.processedPath,
    required this.processedBytes,
    required this.hasBackgroundRemoved,
    required this.faceConfidence,
    required this.generatedAt,
    required this.width,
    required this.height,
  });

  final String originalPath;
  final String processedPath;
  final Uint8List processedBytes;
  final bool hasBackgroundRemoved;
  final double? faceConfidence;
  final DateTime generatedAt;
  final int width;
  final int height;

  File get file => File(processedPath);
}
