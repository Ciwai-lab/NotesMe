import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../notes/data/notes_repository.dart';
import '../../notes/data/note_model.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  const NoteEditorScreen({super.key, this.noteId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _repo = InMemoryNotesRepository.instance;

  Note? _original;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.noteId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final note = await _repo.getById(widget.noteId!);
      _original = note;
      _titleCtrl.text = note.title;
      _bodyCtrl.text = note.body;
    } catch (_) {
      // If missing, treat as new
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (_original == null) {
      await _repo.create(title, body);
    } else {
      await _repo.update(_original!.copyWith(title: title, body: body));
    }
    if (mounted) context.pop();
  }

  Future<void> _deleteIfExisting() async {
    if (_original != null) {
      await _repo.delete(_original!.id);
      if (mounted) context.pop();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.noteId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'New Note' : 'Edit Note'),
        actions: [
          if (!isNew)
            IconButton(
              tooltip: 'Delete',
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete note?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (ok == true) _deleteIfExisting();
              },
              icon: const Icon(Icons.delete_outline),
            ),
          IconButton(
            tooltip: 'Save',
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bodyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 12,
                    minLines: 6,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
    );
  }
}
