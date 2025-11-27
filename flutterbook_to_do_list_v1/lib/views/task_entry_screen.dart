import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/task_model.dart';
import '../viewmodels/tasks_viewmodel.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/navigation_tabs.dart';

class TaskEntryScreen extends StatefulWidget {
  const TaskEntryScreen({super.key});

  @override
  State<TaskEntryScreen> createState() => _TaskEntryScreenState();
}

class _TaskEntryScreenState extends State<TaskEntryScreen> {
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _saveTask(BuildContext context) {
    if (_descriptionController.text.isEmpty) return;

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: _descriptionController.text,
      dueDate: _selectedDate,
    );

    context.read<TasksViewModel>().addTask(task);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Task saved',
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
      appBar: CustomAppBar(bottom: const NavigationTabs(selectedIndex: 3)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.description, style: AppTheme.subtitleStyle),
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.description,
                  size: AppSizes.iconSizeLarge,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
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
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: AppSizes.iconSizeLarge,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.dueDate, style: AppTheme.bodyStyle),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(_selectedDate),
                        style: AppTheme.bodySecondaryStyle,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: AppColors.accent,
                    size: AppSizes.iconSize,
                  ),
                  onPressed: () => _selectDate(context),
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
              onPressed: () => _saveTask(context),
              child: Text(AppStrings.save, style: AppTheme.buttonStyle),
            ),
          ],
        ),
      ),
    );
  }
}
