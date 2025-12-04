import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'note_entry_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: const Center(child: Text('Notes')),
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
