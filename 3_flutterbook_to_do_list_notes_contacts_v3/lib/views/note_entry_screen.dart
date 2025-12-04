import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/navigation_tabs.dart';

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

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty) return;

    // TODO: Implementar lógica de salvar nota no banco de dados

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Note saved',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(bottom: const NavigationTabs(selectedIndex: 2)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title', style: AppTheme.subtitleStyle),
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.subject,
                  size: AppSizes.iconSizeLarge,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '',
                    ),
                    style: AppTheme.bodyStyle,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.content_paste,
                  size: AppSizes.iconSizeLarge,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Content', style: AppTheme.bodyStyle),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '',
                        ),
                        style: AppTheme.bodySecondaryStyle,
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.palette,
                  size: AppSizes.iconSizeLarge,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _colorOptions.entries.map((entry) {
                          final isSelected = _selectedColor == entry.key;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = entry.key;
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: entry.value,
                                border:
                                    isSelected
                                        ? Border.all(
                                          color: Colors.black87,
                                          width: 3,
                                        )
                                        : null,
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLarge,
          vertical: AppSizes.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.cancel, style: AppTheme.buttonStyle),
            ),
            TextButton(
              onPressed: _saveNote,
              child: Text(AppStrings.save, style: AppTheme.buttonStyle),
            ),
          ],
        ),
      ),
    );
  }
}
