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
    final state = ref.watch(photoWorkflowControllerProvider);
    final controller = ref.read(photoWorkflowControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
      ),
      body: state.originalImagePath == null
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
                      child: state.processedPhoto != null
                          ? Image.file(
                              File(state.processedPhoto!.processedPath),
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(state.originalImagePath!),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    value: state.backgroundRemoved,
                    onChanged: controller.reprocessWithBackgroundOption,
                    title: const Text('Background Removal (White)'),
                    subtitle: const Text('AI offline processing'),
                  ),
                  if (state.isProcessing)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(),
                    ),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: state.isProcessing
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
