import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'edit_entry_screen.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openEditor());
  }

  Future<void> _openEditor() async {
    if (_started) return;
    _started = true;

    try {
      // Replace CreateScreen with EditEntryScreen so stack becomes: Home -> EditEntryScreen
      await Navigator.pushReplacement<bool, void>(
        context,
        MaterialPageRoute(builder: (_) => const EditEntryScreen.create()),
      );
      // after this returns, either the pushed route was popped or some navigation happened.
    } catch (_) {
      // ignore
    }
    // No explicit pop here — replacement already removed this route.
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
