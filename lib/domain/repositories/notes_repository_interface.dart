import '../models/note_model.dart';

abstract class INotesRepository {
  Future<List<NoteModel>> fetchNotes(String userId);
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(String id, String newTitle, String newContent); // ✅ update this
  Future<void> deleteNote(String id);
}

