import 'package:flutter/material.dart';
import '../../notes/data/notes_repository.dart';
import '../../notes/data/note_model.dart';
import 'package:go_router/go_router.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = InMemoryNotesRepository.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            tooltip: 'Calculator',
            onPressed: () => context.push('/calc'),
            icon: const Icon(Icons.calculate_outlined),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Note>>(
        valueListenable: repo.listenable,
        builder: (context, notes, _) {
          if (notes.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = notes[index];
              return Dismissible(
                key: ValueKey(n.id),
                background: _slideBg(Colors.red, Icons.delete_outline, 'Delete'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete note?'),
                      content: Text('“${n.title.isEmpty ? 'Untitled' : n.title}” will be deleted.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  return ok ?? false;
                },
                onDismissed: (_) => repo.delete(n.id),
                child: ListTile(
                  title: Text(
                    n.title.isEmpty ? '(Untitled)' : n.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _preview(n),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(_fmt(n.updatedAt),
                      style: Theme.of(context).textTheme.labelSmall),
                  onTap: () => context.push('/note/${n.id}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/note/new'),
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
    );
  }

  static Widget _slideBg(Color color, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: color.withOpacity(0.85),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text, style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }

  static String _preview(Note n) {
    final lines = n.body.trim().split('\n');
    return lines.isEmpty || lines.first.isEmpty ? 'No content' : lines.first;
  }

  static String _fmt(DateTime dt) {
    final now = DateTime.now();
    final sameDay = now.year == dt.year && now.month == dt.month && now.day == dt.day;
    if (sameDay) {
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.note_alt_outlined, size: 64),
            const SizedBox(height: 12),
            Text('No notes yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Tap the + button to create your first note.'),
          ],
        ),
      ),
    );
  }
}
