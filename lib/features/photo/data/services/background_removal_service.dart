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
      return _applyTfliteSegmentation(source, _interpreter);
    }

    return _fallbackWhiteBackground(source);
  }

  Uint8List _applyTfliteSegmentation(img.Image source, Interpreter interpreter) {
    try {
      final inputShape = interpreter.getInputTensor(0).shape;
      final outputShape = interpreter.getOutputTensor(0).shape;

      final width = inputShape[1];
      final height = inputShape[2];

      final resized = img.copyResize(source, width: width, height: height);
      final inputData = _imageToByteListFloat32(resized, width, height, 127.5, 127.5);

      final outputData = List.generate(
        1,
        (i) => List.generate(
          height,
          (j) => List.generate(
            width,
            (k) => List.filled(outputShape[3], 0.0),
          ),
        ),
      );

      interpreter.run(inputData, outputData);

      final mask = img.Image(width: width, height: height);
      var maskIter = mask.iterator;
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          maskIter.moveNext();
          final isForeground = outputData[0][y][x][0] > 0.5;
          if (isForeground) {
             maskIter.current.r = 255;
             maskIter.current.g = 255;
             maskIter.current.b = 255;
             maskIter.current.a = 255;
          } else {
             maskIter.current.r = 0;
             maskIter.current.g = 0;
             maskIter.current.b = 0;
             maskIter.current.a = 255;
          }
        }
      }

      final maskResized = img.copyResize(mask, width: source.width, height: source.height);
      final output = img.Image(width: source.width, height: source.height);
      img.fill(output, color: img.ColorRgb8(255, 255, 255));

      for (var y = 0; y < source.height; y++) {
        for (var x = 0; x < source.width; x++) {
          final p = source.getPixel(x, y);
          final m = maskResized.getPixel(x, y);
          if (m.r > 127) {
             output.setPixel(x, y, p);
          }
        }
      }

      return Uint8List.fromList(img.encodeJpg(output, quality: 95));
    } catch (e) {
      return _fallbackWhiteBackground(source);
    }
  }

  Float32List _imageToByteListFloat32(img.Image image, int width, int height, double mean, double std) {
    var convertedBytes = Float32List(1 * width * height * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < height; i++) {
      for (var j = 0; j < width; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - mean) / std;
        buffer[pixelIndex++] = (pixel.g - mean) / std;
        buffer[pixelIndex++] = (pixel.b - mean) / std;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  Uint8List _fallbackWhiteBackground(img.Image source) {
    final output = img.Image(width: source.width, height: source.height);
    img.fill(output, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(output, source);
    return Uint8List.fromList(img.encodeJpg(output, quality: 95));
  }
}
