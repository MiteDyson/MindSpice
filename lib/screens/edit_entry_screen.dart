import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/entry.dart';
import 'package:intl/intl.dart';

class EditEntryScreen extends ConsumerStatefulWidget {
  final String? entryId;
  final bool isCreateMode;

  const EditEntryScreen({
    Key? key,
    required this.entryId,
    this.isCreateMode = false,
  }) : super(key: key);

  const EditEntryScreen.create({Key? key})
    : entryId = null,
      isCreateMode = true,
      super(key: key);

  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  DateTime? _date;
  Entry? _entry;
  final Set<String> _selectedCategories = {};

  String? _titleError;
  String? _descError;
  String? _dateError;
  String? _catsError;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
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
      } catch (_) {
        // entry not found
      }
    } else {
      _entry = null;
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return (_title.text.trim().isNotEmpty) &&
        (_desc.text.trim().isNotEmpty) &&
        (_date != null) &&
        _selectedCategories.isNotEmpty;
  }

  void _validateAll() {
    setState(() {
      _titleError = _title.text.trim().isEmpty ? 'Title is required' : null;
      _descError = _desc.text.trim().isEmpty ? 'Description is required' : null;
      _dateError = _date == null ? 'Date is required' : null;
      _catsError =
          _selectedCategories.isEmpty ? 'Select at least one category' : null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
      if (_dateError != null) _dateError = null;
    }
  }

  Future<void> _confirmAndDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Entry'),
            content: const Text(
              'Are you sure you want to delete this entry? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      ref.read(entriesProvider.notifier).delete(id);
      // Ensure app returns to Home
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  Future<void> _onSave() async {
    _validateAll();
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    final entriesNotifier = ref.read(entriesProvider.notifier);

    if (widget.isCreateMode) {
      final newEntry = entriesNotifier.createForDate(_date ?? DateTime.now());
      newEntry
        ..title = _title.text.trim()
        ..description = _desc.text.trim()
        ..date = _date ?? DateTime.now()
        ..categories = _selectedCategories.toList()
        ..updatedAt = DateTime.now();

      entriesNotifier.update(newEntry);

      // go back to Home (pop everything until root)
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      if (_entry == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Entry not found.')));
        if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
        return;
      }
      final e = _entry!;
      e
        ..title = _title.text.trim()
        ..description = _desc.text.trim()
        ..date = _date ?? e.date
        ..categories = _selectedCategories.toList()
        ..updatedAt = DateTime.now();

      entriesNotifier.update(e);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!widget.isCreateMode && _entry == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Entry'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ),
        body: const Center(child: Text('Entry not found')),
      );
    }

    final effectiveDate = _date;
    final dateText =
        effectiveDate == null
            ? 'Pick a date'
            : DateFormat('dd MMMM, yyyy').format(effectiveDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreateMode ? 'Create Entry' : 'Edit Entry'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
        actions: [
          TextButton(
            onPressed: _isFormValid ? _onSave : null,
            child: Text(
              'Save',
              style: TextStyle(
                color:
                    _isFormValid
                        ? theme.colorScheme.onPrimary
                        : theme.disabledColor,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                      child: ListTile(
                        title: Text(dateText),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today_outlined),
                          onPressed: _pickDate,
                        ),
                        onTap: _pickDate,
                      ),
                    ),
                    if (_dateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 6),
                        child: Text(
                          _dateError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        'Categories',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          categories.map((c) {
                            final selected = _selectedCategories.contains(
                              c.name,
                            );
                            return FilterChip(
                              label: Text(c.name),
                              selected: selected,
                              avatar: CircleAvatar(
                                backgroundColor: Color(c.colorValue),
                                radius: 12,
                              ),
                              selectedColor: theme.colorScheme.primary
                                  .withOpacity(0.14),
                              onSelected: (v) {
                                setState(() {
                                  if (v)
                                    _selectedCategories.add(c.name);
                                  else
                                    _selectedCategories.remove(c.name);
                                  if (_catsError != null &&
                                      _selectedCategories.isNotEmpty)
                                    _catsError = null;
                                });
                              },
                            );
                          }).toList(),
                    ),
                    if (_catsError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 6),
                        child: Text(
                          _catsError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        'Title',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextField(
                      controller: _title,
                      decoration: InputDecoration(
                        hintText: 'Enter title',
                        errorText: _titleError,
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.8),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (s) {
                        if (_titleError != null && s.trim().isNotEmpty)
                          setState(() => _titleError = null);
                        setState(() {});
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 160),
                      child: TextField(
                        controller: _desc,
                        decoration: InputDecoration(
                          hintText: 'Write your note...',
                          errorText: _descError,
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary.withOpacity(0.8),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        onChanged: (s) {
                          if (_descError != null && s.trim().isNotEmpty)
                            setState(() => _descError = null);
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_desc.text.trim().isEmpty ? 0 : _desc.text.trim().split(RegExp(r"\\s+")).where((w) => w.isNotEmpty).length} words',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          'Updated: ${DateFormat.yMd().add_jm().format((_entry?.updatedAt ?? _entry?.date ?? DateTime.now()))}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!widget.isCreateMode && _entry != null)
                    TextButton.icon(
                      onPressed: () => _confirmAndDelete(context, _entry!.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  else
                    const SizedBox(width: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed:
                            () => Navigator.of(
                              context,
                            ).popUntil((r) => r.isFirst),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed:
                            _isFormValid
                                ? _onSave
                                : () {
                                  _validateAll();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please complete all required fields.',
                                      ),
                                    ),
                                  );
                                },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 12.0,
                          ),
                          child: Text('Save'),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
