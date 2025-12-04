import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../viewmodels/notes_viewmodel.dart';
import 'note_entry_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  Color _getColorFromString(String colorName) {
    final colorMap = {
      'red': const Color(0xFFEF5350),
      'green': const Color(0xFF66BB6A),
      'blue': const Color(0xFF42A5F5),
      'yellow': const Color(0xFFFFEE58),
      'grey': const Color(0xFF9E9E9E),
      'purple': const Color(0xFFAB47BC),
    };
    return colorMap[colorName] ?? const Color(0xFFFFEE58);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Consumer<NotesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.notes.isEmpty) {
            return const Center(child: Text(''));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: viewModel.notes.length,
              itemBuilder: (context, index) {
                final note = viewModel.notes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteEntryScreen(note: note),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getColorFromString(note.color),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (note.content.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            note.content,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEntryScreen()),
          );
        },
        backgroundColor: AppColors.secondary,
        elevation: 4,
        child: const Icon(Icons.add, color: AppColors.background),
      ),
    );
  }
}
