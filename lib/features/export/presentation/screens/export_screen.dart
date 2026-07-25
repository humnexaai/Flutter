import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../photo/presentation/providers/photo_workflow_controller.dart';
import '../../domain/entities/sheet_type.dart';
import '../../domain/usecases/generate_sheet_pdf_usecase.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  static const routeName = '/export';

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _isGenerating = false;
  Uint8List? _pdfBytes;
  String? _savedPath;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoWorkflowControllerProvider);
    final controller = ref.read(photoWorkflowControllerProvider.notifier);
    final photo = state.processedPhoto;
    final sheetType = state.sheetType;

    return Scaffold(
      appBar: AppBar(title: const Text('Export Sheet')),
      body: photo == null
          ? const Center(child: Text('No processed photo available'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SegmentedButton<SheetType>(
                    segments: const [
                      ButtonSegment<SheetType>(
                        value: SheetType.fourBySix,
                        label: Text('4x6'),
                      ),
                      ButtonSegment<SheetType>(
                        value: SheetType.a4,
                        label: Text('A4'),
                      ),
                    ],
                    selected: {sheetType},
                    onSelectionChanged: (selection) {
                      controller.setSheetType(selection.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      itemCount: sheetType.copiesPerPage,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: sheetType.columns,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 35 / 45,
                      ),
                      itemBuilder: (_, __) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.55),
                          ),
                          color: AppColors.card,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.memory(
                            photo.processedBytes,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_savedPath != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Saved: $_savedPath',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _isGenerating ? null : _generateAndSave,
                          child: _isGenerating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Generate & Save PDF'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pdfBytes == null
                              ? null
                              : () => Printing.layoutPdf(
                                    onLayout: (_) async => _pdfBytes!,
                                  ),
                          icon: const Icon(Icons.print_outlined),
                          label: const Text('Print Now'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _generateAndSave() async {
    final state = ref.read(photoWorkflowControllerProvider);
    final photo = state.processedPhoto;
    if (photo == null) return;

    setState(() => _isGenerating = true);
    try {
      final generatePdf = ref.read(generateSheetPdfUseCaseProvider);
      final result = await generatePdf(
        photo: photo,
        sheetType: state.sheetType,
      );
      if (!mounted) return;
      setState(() {
        _pdfBytes = result.bytes;
        _savedPath = result.savedFile.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${result.savedFile.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
