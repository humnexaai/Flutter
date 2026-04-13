import 'dart:io';

import '../entities/processed_photo.dart';
import '../repositories/photo_repository.dart';

class ProcessPhotoUseCase {
  const ProcessPhotoUseCase(this._repository);

  final PhotoRepository _repository;

  Future<ProcessedPhoto> call({
    required File input,
    required bool removeBackground,
  }) {
    return _repository.processImage(
      source: input,
      removeBackground: removeBackground,
    );
  }
}
