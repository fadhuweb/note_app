import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/notes_repository.dart';
import 'domain/repositories/auth_repository_interface.dart';
import 'domain/repositories/notes_repository_interface.dart';

import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/notes/notes_bloc.dart';

import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/notes/notes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthRepository>(
          create: (_) => AuthRepository(FirebaseAuth.instance),
        ),
        RepositoryProvider<INotesRepository>(
          create: (_) => NotesRepository(FirebaseFirestore.instance),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<IAuthRepository>(),
            ),
          ),
          BlocProvider<NotesBloc>(
            create: (context) => NotesBloc(
              notesRepository: context.read<INotesRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Note App',
          theme: ThemeData(primarySwatch: Colors.indigo),
          initialRoute: '/login',
          routes: {
            '/login': (_) => const LoginScreen(),
            '/signup': (_) => const SignupScreen(),
            '/notes': (_) => const NotesScreen(),
          },
        ),
      ),
    );
  }
}
