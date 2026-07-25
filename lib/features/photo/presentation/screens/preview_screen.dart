import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../export/presentation/screens/export_screen.dart';
import '../providers/photo_workflow_controller.dart';

class PreviewScreen extends ConsumerWidget {
  const PreviewScreen({super.key});

  static const routeName = '/preview';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final originalImagePath = ref.watch(photoWorkflowControllerProvider.select((s) => s.originalImagePath));
    final processedPhoto = ref.watch(photoWorkflowControllerProvider.select((s) => s.processedPhoto));
    final backgroundRemoved = ref.watch(photoWorkflowControllerProvider.select((s) => s.backgroundRemoved));
    final isProcessing = ref.watch(photoWorkflowControllerProvider.select((s) => s.isProcessing));
    final errorMessage = ref.watch(photoWorkflowControllerProvider.select((s) => s.errorMessage));
    final controller = ref.read(photoWorkflowControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
      ),
      body: originalImagePath == null
          ? const Center(
              child: Text('No image selected'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: processedPhoto != null
                          ? Image.file(
                              File(processedPhoto.processedPath),
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(originalImagePath),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    value: backgroundRemoved,
                    onChanged: controller.reprocessWithBackgroundOption,
                    title: const Text('Background Removal (White)'),
                    subtitle: const Text('AI offline processing'),
                  ),
                  if (isProcessing)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(),
                    ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: isProcessing
                        ? null
                        : () {
                            Navigator.pushNamed(context, ExportScreen.routeName);
                          },
                    child: const Text('Continue to Export'),
                  ),
                ],
              ),
            ),
    );
  }
}
