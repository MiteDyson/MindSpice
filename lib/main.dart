import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/providers.dart';
import 'screens/root_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MindSpiceApp()));
}

class MindSpiceApp extends ConsumerStatefulWidget {
  const MindSpiceApp({Key? key}) : super(key: key);
  @override
  ConsumerState<MindSpiceApp> createState() => _MindSpiceAppState();
}

class _MindSpiceAppState extends ConsumerState<MindSpiceApp> {
  @override
  void initState() {
    super.initState();
    // load stored state
    Future.microtask(() async {
      await ref.read(categoriesProvider.notifier).loadFromStorage();
      await ref.read(entriesProvider.notifier).loadFromStorage();
      await ref.read(themeProvider.notifier).loadFromStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = ref.watch(themeProvider);
    return MaterialApp(
      title: 'MindSpice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.indigo,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(useMaterial3: true),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const RootScreen(),
    );
  }
}
