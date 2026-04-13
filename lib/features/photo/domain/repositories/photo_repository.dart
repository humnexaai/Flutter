import 'dart:io';

import 'package:tasveer_ai/features/photo/domain/entities/processed_photo.dart';

abstract class PhotoRepository {
  Future<ProcessedPhoto> processImage({
    required File source,
    required bool removeBackground,
  });
}
