import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../export/domain/entities/sheet_type.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../domain/usecases/process_photo_usecase.dart';
import 'photo_workflow_state.dart';

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

final processPhotoUseCaseProvider = Provider<ProcessPhotoUseCase>(
  (ref) => ProcessPhotoUseCase(ref.read(photoRepositoryProvider)),
);

final photoWorkflowControllerProvider =
    StateNotifierProvider<PhotoWorkflowController, PhotoWorkflowState>((ref) {
  return PhotoWorkflowController(
    picker: ref.read(imagePickerProvider),
    processPhotoUseCase: ref.read(processPhotoUseCaseProvider),
  );
});

class PhotoWorkflowController extends StateNotifier<PhotoWorkflowState> {
  PhotoWorkflowController({
    required ImagePicker picker,
    required ProcessPhotoUseCase processPhotoUseCase,
  })  : _picker = picker,
        _processPhotoUseCase = processPhotoUseCase,
        super(const PhotoWorkflowState());

  final ImagePicker _picker;
  final ProcessPhotoUseCase _processPhotoUseCase;

  Future<void> pickFromGallery() async {
    await _pickAndStore(ImageSource.gallery);
  }

  Future<void> captureWithCamera() async {
    await _pickAndStore(ImageSource.camera);
  }

  Future<void> _pickAndStore(ImageSource source) async {
    state = state.copyWith(isProcessing: true, clearError: true);
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (pickedFile == null) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      await setSelectedImagePath(pickedFile.path);
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to pick image: $e',
      );
    }
  }

  Future<void> processCurrentPhoto() async {
    final originalPath = state.originalImagePath;
    if (originalPath == null) {
      return;
    }

    state = state.copyWith(isProcessing: true, clearError: true);
    try {
      final processed = await _processPhotoUseCase(
        input: File(originalPath),
        removeBackground: state.backgroundRemoved,
      );
      state = state.copyWith(
        processedPhoto: processed,
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to process photo: $e',
      );
    }
  }

  Future<void> setSelectedImagePath(String imagePath) async {
    state = state.copyWith(
      originalImagePath: imagePath,
      processedPhoto: null,
      isProcessing: false,
      clearError: true,
    );
    await processCurrentPhoto();
  }

  Future<void> reprocessWithBackgroundOption(bool removeBackground) async {
    state = state.copyWith(backgroundRemoved: removeBackground);
    if (state.originalImagePath != null) {
      await processCurrentPhoto();
    }
  }

  Future<void> toggleBackgroundRemoval(bool enabled) async {
    await reprocessWithBackgroundOption(enabled);
  }

  void setSheetType(SheetType type) {
    state = state.copyWith(sheetType: type);
  }
}
