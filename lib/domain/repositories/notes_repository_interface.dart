import '../models/note_model.dart';

abstract class INotesRepository {
  Future<List<NoteModel>> fetchNotes(String userId);
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note); // ✅ Accept the whole updated note
  Future<void> deleteNote(String id);
}
