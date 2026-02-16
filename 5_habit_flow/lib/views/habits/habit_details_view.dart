import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';
import '../../models/habit_completion.dart';
import '../../viewmodels/habit_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';

class HabitDetailsView extends StatefulWidget {
  final Habit habit;

  const HabitDetailsView({super.key, required this.habit});

  @override
  State<HabitDetailsView> createState() => _HabitDetailsViewState();
}

class _HabitDetailsViewState extends State<HabitDetailsView> {
  List<HabitCompletion> _completions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletions();
  }

  Future<void> _loadCompletions() async {
    setState(() => _isLoading = true);
    final viewModel = context.read<HabitViewModel>();
    final completions = await viewModel.getHabitCompletions(widget.habit.id);
    setState(() {
      _completions = completions;
      _isLoading = false;
    });
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true && mounted) {
      final viewModel = context.read<HabitViewModel>();
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      await viewModel.deleteHabit(widget.habit.id);

      if (!mounted) return;
      navigator.pop(); // Volta para a tela anterior
      messenger.showSnackBar(
        const SnackBar(content: Text('Habit deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final viewModel = context.watch<HabitViewModel>();

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('HABIT DETAILS'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentStreak = viewModel.getCurrentStreak(
      _completions,
      widget.habit,
    );
    final bestStreak = viewModel.getBestStreak(_completions, widget.habit);
    final totalDays = _completions.length;
    final monthlyRate = viewModel.getMonthlyCompletionRate(
      _completions,
      widget.habit,
      DateTime.now(),
    );

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0D15)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HABIT DETAILS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                // TODO: Navegar para edição
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHabitHeader(isDark),
            const SizedBox(height: 24),
            _buildStreakCard(currentStreak, isDark),
            const SizedBox(height: 24),
            _buildThisWeek(isDark, viewModel),
            const SizedBox(height: 24),
            _buildMonthlyOverview(monthlyRate, isDark),
            const SizedBox(height: 24),
            _buildStatsGrid(totalDays, bestStreak, isDark),
            const SizedBox(height: 32),
            _buildActionButtons(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitHeader(bool isDark) {
    final habitColor = widget.habit.habitColor.color;

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isDark
                ? habitColor.withValues(alpha: 0.2)
                : habitColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(_getCategoryIcon(), size: 50, color: habitColor),
        ),
        const SizedBox(height: 16),
        Text(
          widget.habit.title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.habit.category.name) {
      case 'health':
        return Icons.favorite;
      case 'productivity':
        return Icons.work;
      case 'mindfulness':
        return Icons.self_improvement;
      case 'fitness':
        return Icons.fitness_center;
      case 'learning':
        return Icons.school;
      case 'social':
        return Icons.people;
      default:
        return Icons.star;
    }
  }

  Widget _buildStreakCard(int streak, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CURRENT STREAK',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$streak Days',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThisWeek(bool isDark, HabitViewModel viewModel) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    int completedThisWeek = 0;
    final weekDays = <DateTime>[];

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      weekDays.add(day);

      if (widget.habit.shouldShowOnDate(day) && !day.isAfter(today)) {
        final isCompleted = viewModel.isHabitCompletedOnDate(
          widget.habit.id,
          day,
        );
        if (isCompleted) completedThisWeek++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'This Week',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$completedThisWeek/7',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1625) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.asMap().entries.map((entry) {
              final day = entry.value;
              final dayName = [
                'MON',
                'TUE',
                'WED',
                'THU',
                'FRI',
                'SAT',
                'SUN',
              ][entry.key];

              final shouldShow = widget.habit.shouldShowOnDate(day);
              final isToday =
                  day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              final isFuture = day.isAfter(today);
              final isCompleted =
                  shouldShow &&
                  viewModel.isHabitCompletedOnDate(widget.habit.id, day);
              final isMissed =
                  shouldShow && !isCompleted && !isToday && !isFuture;

              return _buildWeekDayCircle(
                dayName,
                isCompleted,
                isMissed,
                isToday,
                isFuture || !shouldShow,
                isDark,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDayCircle(
    String day,
    bool isCompleted,
    bool isMissed,
    bool isToday,
    bool isDisabled,
    bool isDark,
  ) {
    Color backgroundColor;
    Color borderColor;
    Widget? icon;

    if (isCompleted) {
      backgroundColor = const Color(0xFF3B82F6);
      borderColor = const Color(0xFF3B82F6);
      icon = const Icon(Icons.check, color: Colors.white, size: 18);
    } else if (isMissed) {
      backgroundColor = Colors.transparent;
      borderColor = Colors.grey;
      icon = Icon(Icons.close, color: Colors.grey[600], size: 18);
    } else if (isToday) {
      backgroundColor = Colors.transparent;
      borderColor = const Color(0xFF3B82F6);
      icon = Icon(
        Icons.hourglass_empty,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        size: 18,
      );
    } else {
      backgroundColor = Colors.transparent;
      borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
      icon = null;
    }

    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: icon,
        ),
      ],
    );
  }

  Widget _buildMonthlyOverview(double completionRate, bool isDark) {
    final percentage = (completionRate * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1625) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Completion Rate',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9333EA).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: Color(0xFF9333EA),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${percentage > 0 ? percentage ~/ 7 : 0}%',
                          style: const TextStyle(
                            color: Color(0xFF9333EA),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildCompletionChart(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionChart(bool isDark) {
    // Dados de exemplo para o gráfico (últimos 30 dias)
    final now = DateTime.now();
    final dataPoints = <FlSpot>[];

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final isCompleted = _completions.any(
        (c) =>
            c.completedAt.year == date.year &&
            c.completedAt.month == date.month &&
            c.completedAt.day == date.day,
      );

      dataPoints.add(FlSpot(29 - i.toDouble(), isCompleted ? 1 : 0));
    }

    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  if (value == 0)
                    return const Text('Oct 1', style: TextStyle(fontSize: 10));
                  if (value == 14)
                    return const Text('Oct 15', style: TextStyle(fontSize: 10));
                  if (value == 29)
                    return const Text('Today', style: TextStyle(fontSize: 10));
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 29,
          minY: 0,
          maxY: 1,
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Color(0xFF9333EA), Color(0xFFF59E0B)],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF9333EA),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF9333EA).withValues(alpha: 0.3),
                    const Color(0xFF9333EA).withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(int totalDays, int bestStreak, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            value: totalDays.toString(),
            label: 'TOTAL DAYS',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events,
            value: bestStreak.toString(),
            label: 'BEST STREAK',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1625) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  (icon == Icons.calendar_today
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFF59E0B))
                      .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: icon == Icons.calendar_today
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFF59E0B),
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Navegar para edição
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF3B82F6),
              side: BorderSide(
                color: isDark
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF3B82F6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _deleteHabit,
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
