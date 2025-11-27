import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../viewmodels/tasks_viewmodel.dart';
import 'task_entry_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Consumer<TasksViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.tasks.isEmpty) {
            return const Center(child: Text(''));
          }
          return ListView.builder(
            itemCount: viewModel.tasks.length,
            itemBuilder: (context, index) {
              final task = viewModel.tasks[index];
              return Container(
                color: Colors.grey.shade200,
                margin: const EdgeInsets.only(bottom: 1),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      if (value != null) {
                        final updatedTask = task.copyWith(isCompleted: value);
                        viewModel.updateTask(task.id, updatedTask);
                      }
                    },
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  title: Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      decoration:
                          task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                    _formatDate(task.dueDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      decoration:
                          task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskEntryScreen()),
          );
        },
        backgroundColor: AppColors.secondary,
        elevation: 4,
        child: const Icon(Icons.add, color: AppColors.background),
      ),
    );
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
}
