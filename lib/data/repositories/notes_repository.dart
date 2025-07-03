import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/note_model.dart';
import '../../domain/repositories/notes_repository_interface.dart';

class NotesRepository implements INotesRepository {
  final FirebaseFirestore firestore;

  NotesRepository(this.firestore);

  @override
  Future<List<NoteModel>> fetchNotes(String userId) async {
    final snapshot = await firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => NoteModel.fromMap(doc.data())).toList();
  }

  @override
  Future<void> addNote(NoteModel note) async {
    await firestore.collection('notes').doc(note.id).set(note.toMap());
  }

  @override
  Future<void> updateNote(String id, String newTitle, String newContent) async {
    await firestore.collection('notes').doc(id).update({
      'title': newTitle,
      'text': newContent,
      'timestamp': DateTime.now().toIso8601String(), // Optional: update timestamp
    });
  }

  @override
  Future<void> deleteNote(String id) async {
    await firestore.collection('notes').doc(id).delete();
  }
}
