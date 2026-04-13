import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/photo_workflow_controller.dart';
import 'camera_capture_screen.dart';
import 'preview_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photoWorkflowControllerProvider);
    final controller = ref.read(photoWorkflowControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasveer AI')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create passport-ready photos instantly',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        title: 'Instant Camera',
                        subtitle: 'Capture with circular face guide',
                        icon: Icons.camera_alt_rounded,
                        onTap: state.isProcessing
                            ? null
                            : () => Navigator.pushNamed(
                                  context,
                                  CameraCaptureScreen.routeName,
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _ActionCard(
                        title: 'Gallery Upload',
                        subtitle: 'Pick an existing photo',
                        icon: Icons.photo_library_rounded,
                        onTap: state.isProcessing
                            ? null
                            : () async {
                                await controller.pickFromGallery();
                                if (!context.mounted) return;
                                if (ref.read(photoWorkflowControllerProvider).originalImagePath !=
                                    null) {
                                  Navigator.pushNamed(context, PreviewScreen.routeName);
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isProcessing) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              if (state.errorMessage != null)
                Text(
                  state.errorMessage!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.secondary.withOpacity(0.16),
                child: Icon(icon, size: 34),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
