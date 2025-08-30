import 'package:flutter/material.dart';

class NoteEditorScreen extends StatelessWidget {
  final String? noteId;
  const NoteEditorScreen({super.key, this.noteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(noteId == null ? 'New Note' : 'Edit Note')),
      body: const Center(child: Text('Editor (coming soon)')),
    );
  }
}
