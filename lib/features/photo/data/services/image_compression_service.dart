import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressionService {
  const ImageCompressionService();

  Future<File> compress(String imagePath) async {
    final input = File(imagePath);
    final targetPath =
        '${input.parent.path}/cmp_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final compressed = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      targetPath,
      minWidth: 1600,
      minHeight: 1600,
      quality: 85,
      format: CompressFormat.jpeg,
    );

    if (compressed == null) {
      throw Exception('Compression failed');
    }

    return File(compressed.path);
  }
}
