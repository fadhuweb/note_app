import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/note_model.dart';
import '../../blocs/notes/notes_bloc.dart';
import '../../blocs/notes/notes_event.dart';
import '../../blocs/notes/notes_state.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _selectedTag = 'All';

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<NotesBloc>().add(FetchNotes(userId));
        }
      });
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Do you want to logout or exit the app?"),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
            child: const Text("Logout"),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text("Exit"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  void _showNoteDialog({NoteModel? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    String selectedTag = note?.tag ?? 'General';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(note == null ? 'Add Note' : 'Edit Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Write your note...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedTag,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  border: OutlineInputBorder(),
                ),
                items: ['General', 'Work', 'School', 'Personal', 'Other']
                    .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedTag = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              final userId = FirebaseAuth.instance.currentUser?.uid;

              if (title.isNotEmpty && content.isNotEmpty && userId != null) {
                if (note == null) {
                  final newNote = NoteModel(
                    id: const Uuid().v4(),
                    title: title,
                    content: content,
                    timestamp: DateTime.now(),
                    userId: userId,
                    tag: selectedTag,
                  );
                  context.read<NotesBloc>().add(AddNote(newNote));
                } else {
                  final updatedNote = note.copyWith(
                    title: title,
                    content: content,
                    tag: selectedTag,
                  );
                  context.read<NotesBloc>().add(UpdateNote(
                    updatedNote.id,
                    updatedNote.title,
                    updatedNote.content,
                    updatedNote.userId,
                    updatedNote.tag,
                  ));
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(NoteModel note) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<NotesBloc>().add(DeleteNote(note.id, userId));
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Note deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      context.read<NotesBloc>().add(AddNote(note));
                    },
                  ),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
          actions: [
            DropdownButton<String>(
              value: _selectedTag,
              underline: const SizedBox(),
              dropdownColor: Theme.of(context).colorScheme.surface,
              items: ['All', 'General', 'Work', 'School', 'Personal', 'Other']
                  .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedTag = value);
                }
              },
            ),
            TextButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully 🚪')),
                  );
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                }
              },
              icon: Icon(
                Icons.logout,
                color: isDark ? Colors.white : Colors.black,
              ),
              label: Text(
                "Logout",
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
        body: BlocListener<NotesBloc, NotesState>(
          listener: (context, state) {
            if (state is NotesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
              );
            } else if (state is NotesActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note saved ✅')),
              );
            }
          },
          child: BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NotesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is NotesLoaded) {
                final notes = _selectedTag == 'All'
                    ? state.notes
                    : state.notes.where((note) => note.tag == _selectedTag).toList();

                if (notes.isEmpty) {
                  return const Center(
                    child: Text("Nothing here yet—tap ➕ to add a note."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final formattedDate =
                        DateFormat('MMM d, y – h:mm a').format(note.timestamp);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      note.tag,
                                      style: TextStyle(
                                        color: isDark ? Colors.black : Colors.white,
                                      ),
                                    ),
                                    backgroundColor: isDark
                                        ? Colors.purple[200]
                                        : Colors.deepPurple,
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.deepPurple),
                                    onPressed: () => _showNoteDialog(note: note),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _confirmDelete(note),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                note.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                note.content,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDate,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else if (state is NotesError) {
                return Center(child: Text('Error: ${state.message}'));
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showNoteDialog(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
