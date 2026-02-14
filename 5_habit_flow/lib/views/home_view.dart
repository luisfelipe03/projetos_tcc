import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/habit_viewmodel.dart';
import 'habits/create_habit_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Carrega os hábitos quando a tela é criada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitViewModel>().loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final habitViewModel = Provider.of<HabitViewModel>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Flow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.signOut();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
        ],
      ),
      body: habitViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : habitViewModel.habits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No habits yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first habit',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: habitViewModel.habits.length,
              itemBuilder: (context, index) {
                final habit = habitViewModel.habits[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: habit.habitColor.color,
                      child: Icon(
                        _getCategoryIcon(habit.category),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      habit.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${habit.frequency.displayName} • ${habit.category.displayName}',
                    ),
                    trailing: Checkbox(
                      value: habit.isCompleted,
                      onChanged: (value) {
                        habitViewModel.toggleHabitCompletion(habit.id);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateHabitView()),
          );
          // Recarrega os hábitos após voltar da tela de criação
          if (context.mounted) {
            context.read<HabitViewModel>().loadHabits();
          }
        },
        backgroundColor: isDark
            ? const Color(0xFFA855F7)
            : const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getCategoryIcon(category) {
    switch (category.toString()) {
      case 'HabitCategory.health':
        return Icons.favorite;
      case 'HabitCategory.study':
        return Icons.school;
      case 'HabitCategory.finance':
        return Icons.attach_money;
      case 'HabitCategory.personal':
        return Icons.person;
      case 'HabitCategory.social':
        return Icons.people;
      default:
        return Icons.check_circle;
    }
  }
}
