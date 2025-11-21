import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'edit_entry_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;
  final _pages = const [HomeScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves state (scroll position, text input) of tabs
      body: IndexedStack(index: _index, children: _pages),

      // FAB only appears on the Home/Journal tab
      floatingActionButton:
          _index == 0
              ? FloatingActionButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditEntryScreen.create(),
                      ),
                    ),
                child: const Icon(Icons.add),
              )
              : null,

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
