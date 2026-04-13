import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasveer_ai/core/theme/app_theme.dart';
import 'package:tasveer_ai/features/export/presentation/screens/export_screen.dart';
import 'package:tasveer_ai/features/photo/presentation/screens/camera_capture_screen.dart';
import 'package:tasveer_ai/features/photo/presentation/screens/home_screen.dart';
import 'package:tasveer_ai/features/photo/presentation/screens/preview_screen.dart';
import 'package:tasveer_ai/features/photo/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TasveerAiApp()));
}

class TasveerAiApp extends StatelessWidget {
  const TasveerAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasveer AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        CameraCaptureScreen.routeName: (_) => const CameraCaptureScreen(),
        PreviewScreen.routeName: (_) => const PreviewScreen(),
        ExportScreen.routeName: (_) => const ExportScreen(),
      },
    );
  }
}
