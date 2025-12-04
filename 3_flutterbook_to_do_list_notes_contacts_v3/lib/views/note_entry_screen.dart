import 'package:flutter/material.dart';
import '../core/constants.dart';

class NoteEntryScreen extends StatefulWidget {
  const NoteEntryScreen({super.key});

  @override
  State<NoteEntryScreen> createState() => _NoteEntryScreenState();
}

class _NoteEntryScreenState extends State<NoteEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedColor = 'yellow';

  final Map<String, Color> _colorOptions = {
    'red': const Color(0xFFEF5350),
    'green': const Color(0xFF66BB6A),
    'blue': const Color(0xFF42A5F5),
    'yellow': const Color(0xFFFFEE58),
    'grey': const Color(0xFF9E9E9E),
    'purple': const Color(0xFFAB47BC),
  };

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header customizado sem AppBar padrão
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // Corpo da tela
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ícone de texto com título
                      Row(
                        children: [
                          Icon(
                            Icons.text_fields,
                            size: 40,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _titleController,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Title',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32, thickness: 1),

                      // Ícone de conteúdo com campo de texto
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.content_paste,
                            size: 40,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _contentController,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              maxLines: null,
                              minLines: 5,
                              decoration: const InputDecoration(
                                hintText: 'Content',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32, thickness: 1),

                      // Paleta de cores
                      Row(
                        children: [
                          Icon(
                            Icons.palette,
                            size: 40,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children:
                                  _colorOptions.entries.map((entry) {
                                    final isSelected =
                                        _selectedColor == entry.key;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedColor = entry.key;
                                        });
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: entry.value,
                                          border:
                                              isSelected
                                                  ? Border.all(
                                                    color: Colors.black87,
                                                    width: 3,
                                                  )
                                                  : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botões inferiores
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implementar lógica de salvar nota
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
