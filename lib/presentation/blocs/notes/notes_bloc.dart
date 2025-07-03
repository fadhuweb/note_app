import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../domain/models/note_model.dart';
import '../../../domain/repositories/notes_repository_interface.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final INotesRepository notesRepository;

  NotesBloc({required this.notesRepository}) : super(NotesInitial()) {
    on<FetchNotes>(_onFetchNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onFetchNotes(FetchNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await notesRepository.fetchNotes(event.userId);
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError("Failed to load notes"));
    }
  }

  Future<void> _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    try {
      await notesRepository.addNote(event.note);
      add(FetchNotes(event.note.userId));
    } catch (e) {
      emit(NotesError("Failed to add note"));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    try {
      await notesRepository.updateNote(event.id, event.newText);
      final userId = (state as NotesLoaded).notes.first.userId;
      add(FetchNotes(userId));
    } catch (e) {
      emit(NotesError("Failed to update note"));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await notesRepository.deleteNote(event.id);
      final userId = (state as NotesLoaded).notes.first.userId;
      add(FetchNotes(userId));
    } catch (e) {
      emit(NotesError("Failed to delete note"));
    }
  }
}
