import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../widgets/settings/category_manager.dart';
import '../widgets/settings/data_manager.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // List of cool fonts
  static const Map<String, String> _fonts = {
    'Roboto': 'Standard',
    'Open Sans': 'Clean',
    'Lato': 'Modern',
    'Comic Neue': 'Comic (Fun)', // Good Comic Sans alternative
    'Lobster': 'Fancy',
    'Pacifico': 'Handwriting',
    'Oswald': 'Bold',
    'Space Mono': 'Coding',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "APPEARANCE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

          // Theme Toggle
          Card(
            elevation: 0,
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: themeState.isDark,
                  onChanged: (v) => ref.read(themeProvider.notifier).setDark(v),
                  secondary: Icon(
                    themeState.isDark ? Icons.dark_mode : Icons.light_mode,
                  ),
                ),
                const Divider(height: 1),

                // Font Selector
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('App Font'),
                  subtitle: Text(
                    _fonts[themeState.font] ?? themeState.font,
                    style: GoogleFonts.getFont(
                      themeState.font,
                    ), // Preview the font
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFontPicker(context, ref, themeState.font),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "CONTENT",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const CategoryManager(),

          const SizedBox(height: 24),
          const Text(
            "DATA",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const DataManager(),
        ],
      ),
    );
  }

  void _showFontPicker(
    BuildContext context,
    WidgetRef ref,
    String currentFont,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Font",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children:
                        _fonts.entries.map((entry) {
                          final fontName = entry.key;
                          final label = entry.value;
                          final isSelected = fontName == currentFont;

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            title: Text(
                              fontName,
                              // Show the font name IN that font so user can preview it
                              style: GoogleFonts.getFont(
                                fontName,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              label,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing:
                                isSelected
                                    ? const Icon(
                                      Icons.check,
                                      color: Colors.indigo,
                                    )
                                    : null,
                            onTap: () {
                              ref
                                  .read(themeProvider.notifier)
                                  .setFont(fontName);
                              Navigator.pop(ctx);
                            },
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
