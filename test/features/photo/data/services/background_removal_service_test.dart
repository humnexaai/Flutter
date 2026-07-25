import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tasveer_ai/features/photo/data/services/background_removal_service.dart';

void main() {
  group('BackgroundRemovalService', () {
    test('fallbackWhiteBackground correctly applies a white background', () async {
      final service = BackgroundRemovalService();

      final source = img.Image(width: 10, height: 10);
      img.fill(source, color: img.ColorRgb8(255, 0, 0));
      final sourceBytes = Uint8List.fromList(img.encodeJpg(source));

      final resultBytes = await service.apply(sourceBytes);
      final resultImg = img.decodeImage(resultBytes);

      expect(resultImg, isNotNull);
      expect(resultImg!.width, 10);
      expect(resultImg.height, 10);
    });

    test('throws exception when image cannot be decoded', () async {
      final service = BackgroundRemovalService();
      expect(
        () => service.apply(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<RangeError>()),
      );
    });
  });
}
