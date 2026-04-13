import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;

import 'background_removal_service.dart';

class PhotoProcessingIsolate {
  Future<Uint8List> process({
    required Uint8List imageBytes,
    required Rect? faceBoundingBox,
    required bool removeBackground,
    required BackgroundRemovalService backgroundRemovalService,
  }) async {
    final receivePort = ReceivePort();
    final workingBytes = removeBackground
        ? await backgroundRemovalService.apply(imageBytes)
        : imageBytes;

    await Isolate.spawn<_IsolateInput>(
      _isolateEntry,
      _IsolateInput(
        imageBytes: workingBytes,
        faceRect: faceBoundingBox == null
            ? null
            : _FaceRect(
                left: faceBoundingBox.left,
                top: faceBoundingBox.top,
                width: faceBoundingBox.width,
                height: faceBoundingBox.height,
              ),
        sendPort: receivePort.sendPort,
      ),
    );

    final result = await receivePort.first as _IsolateOutput;
    receivePort.close();

    if (result.error != null) {
      throw Exception(result.error);
    }
    return result.outputBytes!;
  }

  static void _isolateEntry(_IsolateInput input) {
    try {
      final decoded = img.decodeImage(input.imageBytes);
      if (decoded == null) {
        throw Exception('Could not decode image');
      }

      final cropped = _cropWithFacePriority(decoded, input.faceRect);

      // 3.5x4.5cm at 300dpi ~ 413x531 px
      final resized = img.copyResize(
        cropped,
        width: 413,
        height: 531,
        interpolation: img.Interpolation.average,
      );

      final encoded = Uint8List.fromList(img.encodeJpg(resized, quality: 95));
      input.sendPort.send(_IsolateOutput(outputBytes: encoded));
    } catch (e) {
      input.sendPort.send(_IsolateOutput(error: e.toString()));
    }
  }

  static img.Image _cropWithFacePriority(img.Image source, _FaceRect? face) {
    // Indian passport ratio (width / height) = 3.5 / 4.5
    const targetRatio = 3.5 / 4.5;
    int targetWidth = source.width;
    int targetHeight = (targetWidth / targetRatio).round();

    if (targetHeight > source.height) {
      targetHeight = source.height;
      targetWidth = (targetHeight * targetRatio).round();
    }

    int x = (source.width - targetWidth) ~/ 2;
    int y = (source.height - targetHeight) ~/ 2;

    if (face != null) {
      final faceCenterX = face.left + (face.width / 2);
      final faceTop = face.top;
      x = (faceCenterX - (targetWidth / 2)).round();
      y = (faceTop - targetHeight * 0.22).round();
    }

    x = x.clamp(0, source.width - targetWidth).toInt();
    y = y.clamp(0, source.height - targetHeight).toInt();

    return img.copyCrop(
      source,
      x: x,
      y: y,
      width: targetWidth,
      height: targetHeight,
    );
  }
}

class _IsolateInput {
  const _IsolateInput({
    required this.imageBytes,
    required this.faceRect,
    required this.sendPort,
  });

  final Uint8List imageBytes;
  final _FaceRect? faceRect;
  final SendPort sendPort;
}

class _FaceRect {
  const _FaceRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}

class _IsolateOutput {
  const _IsolateOutput({this.outputBytes, this.error});

  final Uint8List? outputBytes;
  final String? error;
}
