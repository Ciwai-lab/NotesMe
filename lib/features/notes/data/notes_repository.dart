import 'note_model.dart';

abstract class NotesRepository {
  Future<List<Note>> list();
  Future<Note> getById(String id);
  Future<Note> create(String title, String body);
  Future<Note> update(Note note);
  Future<void> delete(String id);
}

// Nanti Step 4 kita isi DummyNotesRepository untuk sementara.
