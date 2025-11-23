import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/providers.dart';
import 'providers/theme_notifier.dart';
import 'screens/root_screen.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart'; // Import the service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notifications
  await NotificationService().init();

  runApp(const ProviderScope(child: MindSpiceApp()));
}

class MindSpiceApp extends ConsumerStatefulWidget {
  const MindSpiceApp({super.key});
  @override
  ConsumerState<MindSpiceApp> createState() => _MindSpiceAppState();
}

class _MindSpiceAppState extends ConsumerState<MindSpiceApp> {
  @override
  void initState() {
    super.initState();
    _initialization();
  }

  Future<void> _initialization() async {
    await Future.wait([
      ref.read(categoriesProvider.notifier).loadFromStorage(),
      ref.read(entriesProvider.notifier).loadFromStorage(),
      ref.read(themeProvider.notifier).loadFromStorage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'MindSpice',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(themeState.font),
      darkTheme: AppTheme.dark(themeState.font),
      themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const RootScreen(),
    );
  }
}
