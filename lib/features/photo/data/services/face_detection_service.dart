import 'dart:io';
import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class DetectedFaceData {
  const DetectedFaceData({
    required this.boundingBox,
    required this.confidence,
  });

  final Rect boundingBox;
  final double? confidence;
}

class FaceDetectionService {
  FaceDetectionService()
      : _detector = FaceDetector(
          options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.fast,
            enableContours: false,
            enableClassification: false,
          ),
        );

  final FaceDetector _detector;

  Future<DetectedFaceData?> detectPrimaryFace(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _detector.processImage(inputImage);
    if (faces.isEmpty) return null;

    faces.sort(
      (a, b) => (b.boundingBox.width * b.boundingBox.height)
          .compareTo(a.boundingBox.width * a.boundingBox.height),
    );
    final primary = faces.first;
    return DetectedFaceData(
      boundingBox: primary.boundingBox,
      confidence: primary.headEulerAngleY,
    );
  }

  Future<void> dispose() async => _detector.close();
}
