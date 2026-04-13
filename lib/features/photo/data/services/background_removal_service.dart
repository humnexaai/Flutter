import "dart:typed_data";

import "package:image/image.dart" as img;
import "package:tflite_flutter/tflite_flutter.dart";

class BackgroundRemovalService {
  BackgroundRemovalService({Interpreter? interpreter})
      : _interpreter = interpreter;

  final Interpreter? _interpreter;

  Future<Uint8List> apply(Uint8List inputBytes) async {
    final source = img.decodeImage(inputBytes);
    if (source == null) throw Exception("Unable to decode image");

    // Hook for a bundled segmentation model. If a model is present,
    // use it here and blend foreground with white background.
    if (_interpreter != null) {
      return _fallbackWhiteBackground(source);
    }

    return _fallbackWhiteBackground(source);
  }

  Uint8List _fallbackWhiteBackground(img.Image source) {
    final output = img.Image(width: source.width, height: source.height);
    img.fill(output, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(output, source);
    return Uint8List.fromList(img.encodeJpg(output, quality: 95));
  }
}
