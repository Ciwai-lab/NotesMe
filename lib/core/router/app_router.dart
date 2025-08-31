import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/notes/presentation/notes_list_screen.dart';
import '../../features/notes/presentation/note_editor_screen.dart';
import '../../features/calc/presentation/calc_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'notes_list',
      pageBuilder: (context, state) => const MaterialPage(
        child: NotesListScreen(),
      ),
    ),
    GoRoute(
      path: '/note/new',
      name: 'note_new',
      pageBuilder: (context, state) => const MaterialPage(
        child: NoteEditorScreen(),
      ),
    ),
    GoRoute(
      path: '/note/:id',
      name: 'note_edit',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'];
        return MaterialPage(
          child: NoteEditorScreen(noteId: id),
        );
      },
    ),
    GoRoute(
      path: '/calc',
      name: 'calc',
      pageBuilder: (context, state) => const MaterialPage(
        child: CalcScreen(),
      ),
    ),
  ],
  // (opsional) observer/log untuk debug route
  observers: [
    GoRouterObserver(),
  ],
);

class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    // debugPrint('[router] push: ${route.settings.name}');
    super.didPush(route, previousRoute);
  }
}
