import 'package:flutter/foundation.dart';
import 'package:tasveer_ai/features/export/domain/entities/sheet_type.dart';
import 'package:tasveer_ai/features/photo/domain/entities/processed_photo.dart';

@immutable
class PhotoWorkflowState {
  const PhotoWorkflowState({
    this.originalImagePath,
    this.processedPhoto,
    this.sheetType = SheetType.fourBySix,
    this.backgroundRemoved = true,
    this.isProcessing = false,
    this.errorMessage,
  });

  final String? originalImagePath;
  final ProcessedPhoto? processedPhoto;
  final SheetType sheetType;
  final bool backgroundRemoved;
  final bool isProcessing;
  final String? errorMessage;

  PhotoWorkflowState copyWith({
    String? originalImagePath,
    ProcessedPhoto? processedPhoto,
    SheetType? sheetType,
    bool? backgroundRemoved,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PhotoWorkflowState(
      originalImagePath: originalImagePath ?? this.originalImagePath,
      processedPhoto: processedPhoto ?? this.processedPhoto,
      sheetType: sheetType ?? this.sheetType,
      backgroundRemoved: backgroundRemoved ?? this.backgroundRemoved,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
