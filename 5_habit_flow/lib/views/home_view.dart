import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../models/habit.dart';
import '../widgets/home_widgets.dart';
import 'habits/create_habit_view.dart';
import 'stats_view.dart';
import 'settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentNavIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<HabitViewModel>();
      viewModel.loadHabits();
      viewModel.loadCompletionsForDate(_selectedDate);
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return const StatsView();
      case 2:
        return const SettingsView();
      default:
        return _buildHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0D15)
          : const Color(0xFFF8F9FA),
      body: _getCurrentScreen(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateHabitView()),
          );
          if (context.mounted) {
            context.read<HabitViewModel>().loadHabits();
          }
        },
        backgroundColor: isDark
            ? const Color(0xFFA855F7)
            : const Color(0xFF5B7FFF),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildHomeScreen() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authViewModel = context.watch<AuthViewModel>();
    final habitViewModel = context.watch<HabitViewModel>();

    // Filtra hábitos do dia selecionado
    final todayHabits = habitViewModel.habits;
    final completedCount = habitViewModel.getCompletedCountForDate(
      _selectedDate,
    );

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(authViewModel, isDark),
          const SizedBox(height: 20),
          DailyProgressCard(
            completedHabits: completedCount,
            totalHabits: todayHabits.length,
          ),
          const SizedBox(height: 20),
          HorizontalCalendar(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
              context.read<HabitViewModel>().loadCompletionsForDate(date);
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: habitViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : todayHabits.isEmpty
                ? _buildEmptyState(isDark)
                : _buildHabitsList(todayHabits, habitViewModel, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthViewModel authViewModel, bool isDark) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMM d').format(now);
    final userName =
        authViewModel.user?.displayName ??
        authViewModel.user?.email?.split('@')[0] ??
        'User';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isDark
                    ? const Color(0xFF1F1B2E)
                    : const Color(0xFFE5E7EB),
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF0F0D15)
                          : const Color(0xFFF8F9FA),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hi, $userName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1B2E) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.notifications,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first habit',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList(
    List<Habit> habits,
    HabitViewModel viewModel,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return _buildHabitCard(habit, viewModel, isDark);
      },
    );
  }

  Widget _buildHabitCard(Habit habit, HabitViewModel viewModel, bool isDark) {
    final isCompleted = viewModel.isHabitCompletedOnDate(
      habit.id,
      _selectedDate,
    );
    final habitColor = habit.habitColor.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: habitColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: habitColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navegar para detalhes do hábito
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    viewModel.toggleHabitCompletion(habit.id, _selectedDate);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCompleted ? habitColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: habitColor, width: 2),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 28)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: habitColor,
                          decorationThickness: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (habit.reminder != null) ...[
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              habit.reminder!.formattedTime,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            habit.frequency.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  onPressed: () {
                    _showHabitOptions(habit, viewModel);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHabitOptions(Habit habit, HabitViewModel viewModel) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F1B2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Habit'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar para edição
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Habit',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _showDeleteConfirmation();
                if (confirmed == true && mounted) {
                  await viewModel.deleteHabit(habit.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Habit deleted'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
