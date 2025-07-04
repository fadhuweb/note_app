import '../../../domain/models/note_model.dart';

abstract class NotesEvent {}

class FetchNotes extends NotesEvent {
  final String userId;
  FetchNotes(this.userId);
}

class AddNote extends NotesEvent {
  final NoteModel note;
  AddNote(this.note);
}

class UpdateNote extends NotesEvent {
  final String id;
  final String newTitle;
  final String newContent;
  final String userId;
  final String newTag; // ✅ Added tag
  UpdateNote(this.id, this.newTitle, this.newContent, this.userId, this.newTag); // ✅ Updated
}

class DeleteNote extends NotesEvent {
  final String id;
  final String userId;
  DeleteNote(this.id, this.userId);
}
