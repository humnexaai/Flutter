import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/photo_workflow_controller.dart';
import '../widgets/camera_face_overlay.dart';
import 'preview_screen.dart';

class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({super.key});

  static const routeName = '/camera-capture';

  @override
  ConsumerState<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  CameraController? _cameraController;
  bool _initializing = true;
  bool _capturing = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _cameraError = 'No camera available on this device.';
          _initializing = false;
        });
        return;
      }

      final front = cameras.where((e) => e.lensDirection == CameraLensDirection.front);
      final selected = front.isNotEmpty ? front.first : cameras.first;

      final controller = CameraController(
        selected,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _cameraController = controller;
        _initializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = 'Failed to initialize camera: $e';
        _initializing = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = ref.watch(photoWorkflowControllerProvider.select((s) => s.isProcessing));
    final errorMessage = ref.watch(photoWorkflowControllerProvider.select((s) => s.errorMessage));

    return Scaffold(
      appBar: AppBar(title: const Text('Instant Camera')),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : _cameraError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(_cameraError!, textAlign: TextAlign.center),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(_cameraController!),
                          const CameraFaceOverlay(),
                        ],
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _capturing || isProcessing ? null : _captureAndProcess,
                              icon: _capturing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.camera_alt_outlined),
                              label: Text(_capturing ? 'Capturing...' : 'Capture'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<void> _captureAndProcess() async {
    if (_cameraController == null) return;
    setState(() => _capturing = true);
    try {
      final file = await _cameraController!.takePicture();
      await ref.read(photoWorkflowControllerProvider.notifier).setSelectedImagePath(file.path);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, PreviewScreen.routeName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Capture failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _capturing = false);
      }
    }
  }
}
