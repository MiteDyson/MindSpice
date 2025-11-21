import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/entry.dart';
import 'package:intl/intl.dart';

class EditEntryScreen extends ConsumerStatefulWidget {
  final String? entryId;
  final bool isCreateMode;

  const EditEntryScreen({super.key, required this.entryId})
    : isCreateMode = false;
  const EditEntryScreen.create({super.key})
    : entryId = null,
      isCreateMode = true;

  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  late TextEditingController _title;
  late TextEditingController _desc;
  DateTime? _date;
  Entry? _entry;
  final Set<String> _selectedCategories = {};
  bool _isLoaded = false;
  bool _hasChanges = false; // Track changes manually

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _desc = TextEditingController();
    // Listen to changes to enable "Discard" warning
    _title.addListener(_markChanged);
    _desc.addListener(_markChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _loadInitial() async {
    if (!widget.isCreateMode && widget.entryId != null) {
      final state = ref.read(entriesProvider);
      try {
        final found = state.entries.firstWhere((e) => e.id == widget.entryId);
        _entry = found;
        _title.text = found.title;
        _desc.text = found.description;
        _date = found.date;
        _selectedCategories.addAll(found.categories);
        // Reset change flag after loading data
        setState(() => _hasChanges = false);
      } catch (_) {}
    } else {
      _date = DateTime.now();
    }
    setState(() => _isLoaded = true);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.isEmpty && _desc.text.isEmpty) return; // Don't save empty

    final notifier = ref.read(entriesProvider.notifier);

    if (widget.isCreateMode) {
      final newEntry = notifier.createForDate(_date ?? DateTime.now());
      newEntry
        ..title = _title.text.trim()
        ..description = _desc.text.trim()
        ..date = _date ?? DateTime.now()
        ..categories = _selectedCategories.toList();
      notifier.update(newEntry);
    } else if (_entry != null) {
      _entry!
        ..title = _title.text.trim()
        ..description = _desc.text.trim()
        ..date = _date ?? _entry!.date
        ..categories = _selectedCategories.toList();
      notifier.update(_entry!);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final categories = ref.watch(categoriesProvider);

    return PopScope(
      canPop: !_hasChanges, // If no changes, allow pop. If changes, block it.
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Discard changes?'),
                content: const Text(
                  'You have unsaved changes. Are you sure you want to leave?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Keep Editing'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Discard'),
                  ),
                ],
              ),
        );
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isCreateMode ? 'New Entry' : 'Edit Entry'),
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _date = picked;
                      _hasChanges = true;
                    });
                  }
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _date == null
                          ? 'Select Date'
                          : DateFormat.yMMMEd().format(_date!),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title Input
              TextField(
                controller: _title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
              ),

              // Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      categories.map((c) {
                        final isSelected = _selectedCategories.contains(c.name);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(c.name),
                            selected: isSelected,
                            onSelected:
                                (v) => setState(() {
                                  _hasChanges = true;
                                  v
                                      ? _selectedCategories.add(c.name)
                                      : _selectedCategories.remove(c.name);
                                }),
                            backgroundColor: Color(
                              c.colorValue,
                            ).withOpacity(0.1),
                            selectedColor: Color(c.colorValue).withOpacity(0.3),
                            checkmarkColor: Color(c.colorValue),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              const Divider(),

              // Content Input
              TextField(
                controller: _desc,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
