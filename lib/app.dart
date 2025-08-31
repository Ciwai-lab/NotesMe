import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class NotesMeApp extends StatelessWidget {
  const NotesMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appName = dotenv.maybeGet('APP_NAME') ?? 'NotesMe';

    return MaterialApp.router(
      title: appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
