import 'dart:async';
import 'package:flutter/foundation.dart';

import 'note_model.dart';

abstract class NotesRepository {
  ValueListenable<List<Note>> get listenable; // observe changes
  Future<List<Note>> list();
  Future<Note> getById(String id);
  Future<Note> create(String title, String body);
  Future<Note> update(Note note);
  Future<void> delete(String id);
}

/// Simple in-memory repo (dummy) — nanti gampang diganti Hive/SQLite.
class InMemoryNotesRepository implements NotesRepository {
  InMemoryNotesRepository._internal() {
    // Seed contoh 2 catatan (boleh hapus)
    final now = DateTime.now();
    _notes = [
      Note(
        id: _genId(),
        title: 'Welcome to NotesMe',
        body: 'This is your first note. Tap to edit, swipe to delete.',
        updatedAt: now,
      ),
      Note(
        id: _genId(),
        title: 'Roadmap',
        body: '- Add Hive persistence\n- Add calculator tab\n- Sync/backup',
        updatedAt: now.subtract(const Duration(minutes: 5)),
      ),
    ];
    _notifier.value = List.unmodifiable(_notes);
  }

  static final InMemoryNotesRepository instance =
      InMemoryNotesRepository._internal();

  final ValueNotifier<List<Note>> _notifier =
      ValueNotifier<List<Note>>(const []);
  late List<Note> _notes;

  @override
  ValueListenable<List<Note>> get listenable => _notifier;

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();

  void _emit() => _notifier.value = List.unmodifiable(_notes);

  @override
  Future<List<Note>> list() async => List.unmodifiable(_notes);

  @override
  Future<Note> getById(String id) async {
    final n = _notes.where((e) => e.id == id).cast<Note?>().firstOrNull;
    if (n == null) {
      throw StateError('Note not found: $id');
    }
    return n;
  }

  @override
  Future<Note> create(String title, String body) async {
    final note = Note(
      id: _genId(),
      title: title,
      body: body,
      updatedAt: DateTime.now(),
    );
    _notes = [note, ..._notes]; // prepend
    _emit();
    return note;
  }

  @override
  Future<Note> update(Note note) async {
    final idx = _notes.indexWhere((e) => e.id == note.id);
    if (idx == -1) throw StateError('Note not found: ${note.id}');
    _notes[idx] = note.copyWith(updatedAt: DateTime.now());
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _emit();
    return _notes[idx];
  }

  @override
  Future<void> delete(String id) async {
    _notes.removeWhere((e) => e.id == id);
    _emit();
  }
}

// Small helper for firstOrNull without extra deps
extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
