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
  final String newText;
  UpdateNote(this.id, this.newText);
}

class DeleteNote extends NotesEvent {
  final String id;
  DeleteNote(this.id);
}
