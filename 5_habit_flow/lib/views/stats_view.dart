import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../models/habit_category.dart';
import '../models/habit_completion.dart';
import '../viewmodels/habit_viewmodel.dart';

enum _StatsRange {
  last7Days(7, 'Last 7 Days'),
  last30Days(30, 'Last 30 Days'),
  last90Days(90, 'Last 90 Days');

  final int days;
  final String label;

  const _StatsRange(this.days, this.label);
}

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  _StatsRange _selectedRange = _StatsRange.last30Days;
  late Future<_StatsData> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<_StatsData> _loadStats() async {
    final viewModel = context.read<HabitViewModel>();
    return _buildStatsData(viewModel, _selectedRange);
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _loadStats();
    });
    await _statsFuture;
  }

  Future<_StatsData> _buildStatsData(
    HabitViewModel viewModel,
    _StatsRange range,
  ) async {
    if (viewModel.habits.isEmpty) {
      await viewModel.loadHabits();
    }

    final habits = List<Habit>.from(viewModel.habits);
    if (habits.isEmpty) {
      return const _StatsData.empty();
    }

    final now = _normalizeDate(DateTime.now());
    final startDate = now.subtract(Duration(days: range.days - 1));
    final previousEndDate = startDate.subtract(const Duration(days: 1));
    final previousStartDate = previousEndDate.subtract(
      Duration(days: range.days - 1),
    );

    final currentCompletions = await viewModel.getCompletionsInRange(
      startDate,
      now,
    );
    final previousCompletions = await viewModel.getCompletionsInRange(
      previousStartDate,
      previousEndDate,
    );

    final groupedCurrent = _groupByHabit(currentCompletions);
    final groupedPrevious = _groupByHabit(previousCompletions);

    final performances = <_HabitPerformance>[];
    final categoryAccumulator = <HabitCategory, _CategoryAccumulator>{};

    int totalExpected = 0;
    int totalCompleted = 0;
    int bestStreakOverall = 0;

    for (final habit in habits) {
      final expectedCount = _calculateExpectedCount(habit, startDate, now);
      if (expectedCount == 0) {
        continue;
      }

      final habitCompletions = _deduplicateByDay(
        groupedCurrent[habit.id] ?? [],
      );
      final completedCount = habitCompletions.length;
      final completionRate = _safeRate(completedCount, expectedCount);
      final bestStreak = viewModel.getBestStreak(habitCompletions, habit);

      totalExpected += expectedCount;
      totalCompleted += completedCount;
      bestStreakOverall = math.max(bestStreakOverall, bestStreak);

      performances.add(
        _HabitPerformance(
          habit: habit,
          completionRate: completionRate,
          completedCount: completedCount,
          expectedCount: expectedCount,
          bestStreak: bestStreak,
        ),
      );

      final accumulator = categoryAccumulator.putIfAbsent(
        habit.category,
        () => _CategoryAccumulator(),
      );
      accumulator.expected += expectedCount;
      accumulator.completed += completedCount;
    }

    final categoryMetrics =
        categoryAccumulator.entries
            .map(
              (entry) => _CategoryMetric(
                category: entry.key,
                completionRate: _safeRate(
                  entry.value.completed,
                  entry.value.expected,
                ),
                completedCount: entry.value.completed,
                expectedCount: entry.value.expected,
              ),
            )
            .toList()
          ..sort((a, b) => b.completionRate.compareTo(a.completionRate));

    performances.sort((a, b) {
      final byRate = b.completionRate.compareTo(a.completionRate);
      if (byRate != 0) return byRate;

      final byStreak = b.bestStreak.compareTo(a.bestStreak);
      if (byStreak != 0) return byStreak;

      return b.completedCount.compareTo(a.completedCount);
    });

    final currentRate = _safeRate(totalCompleted, totalExpected);

    int previousExpected = 0;
    int previousCompleted = 0;
    for (final habit in habits) {
      final expected = _calculateExpectedCount(
        habit,
        previousStartDate,
        previousEndDate,
      );

      if (expected == 0) {
        continue;
      }

      final deduplicated = _deduplicateByDay(groupedPrevious[habit.id] ?? []);
      previousExpected += expected;
      previousCompleted += deduplicated.length;
    }

    final previousRate = _safeRate(previousCompleted, previousExpected);

    return _StatsData(
      completionRate: currentRate,
      completionDelta: currentRate - previousRate,
      bestStreak: bestStreakOverall,
      totalCompletedCheckIns: totalCompleted,
      totalTrackedHabits: performances.length,
      topPerforming: performances.take(5).toList(),
      categoryMetrics: categoryMetrics,
    );
  }

  Map<String, List<HabitCompletion>> _groupByHabit(
    List<HabitCompletion> completions,
  ) {
    final grouped = <String, List<HabitCompletion>>{};

    for (final completion in completions) {
      grouped.putIfAbsent(completion.habitId, () => []);
      grouped[completion.habitId]!.add(completion);
    }

    return grouped;
  }

  List<HabitCompletion> _deduplicateByDay(List<HabitCompletion> completions) {
    final byDay = <String, HabitCompletion>{};

    for (final completion in completions) {
      byDay[_dateKey(completion.completedAt)] = completion;
    }

    return byDay.values.toList();
  }

  int _calculateExpectedCount(
    Habit habit,
    DateTime startDate,
    DateTime endDate,
  ) {
    int expected = 0;
    final today = _normalizeDate(DateTime.now());

    for (
      var date = _normalizeDate(startDate);
      !date.isAfter(endDate);
      date = date.add(const Duration(days: 1))
    ) {
      if (date.isAfter(today)) {
        break;
      }

      if (habit.shouldShowOnDate(date)) {
        expected++;
      }
    }

    return expected;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  double _safeRate(int completed, int expected) {
    if (expected <= 0) {
      return 0;
    }

    return completed / expected;
  }

  Color _pageBackground(bool isDark) {
    return isDark ? const Color(0xFF071533) : const Color(0xFFF3F4F8);
  }

  Color _surfaceColor(bool isDark) {
    return isDark ? const Color(0xFF1C2944) : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: _pageBackground(isDark),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            Expanded(
              child: FutureBuilder<_StatsData>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(isDark);
                  }

                  final stats = snapshot.data ?? const _StatsData.empty();

                  if (!stats.hasHabits) {
                    return _buildEmptyState(isDark);
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshStats,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 18, bottom: 24),
                      children: [
                        _buildMetricsCarousel(stats, isDark),
                        const SizedBox(height: 24),
                        _buildCategoryBreakdownCard(stats, isDark),
                        const SizedBox(height: 22),
                        _buildTopPerformingSection(stats, isDark),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
      child: Row(
        children: [
          const Text(
            'Statistics',
            style: TextStyle(fontSize: 48 / 1.5, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          PopupMenuButton<_StatsRange>(
            onSelected: (value) {
              setState(() {
                _selectedRange = value;
                _statsFuture = _loadStats();
              });
            },
            color: isDark ? const Color(0xFF1E2A45) : const Color(0xFFE8ECF2),
            itemBuilder: (context) => _StatsRange.values
                .map(
                  (range) => PopupMenuItem<_StatsRange>(
                    value: range,
                    child: Text(range.label),
                  ),
                )
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A2741)
                    : const Color(0xFFE3E8EF),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedRange.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF344054),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF344054),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCarousel(_StatsData stats, bool isDark) {
    final completionPercent = (stats.completionRate * 100).round();
    final deltaPercent = (stats.completionDelta * 100).round();
    final deltaPrefix = deltaPercent > 0 ? '+' : '';
    final trendSubtitle = '$deltaPrefix$deltaPercent% vs previous period';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildMetricCard(
            isDark: isDark,
            width: 244,
            title: 'Completion',
            value: '$completionPercent%',
            subtitle: trendSubtitle,
            icon: Icons.donut_large_rounded,
            accent: const Color(0xFF1FC997),
          ),
          const SizedBox(width: 16),
          _buildMetricCard(
            isDark: isDark,
            width: 244,
            title: 'Best Streak',
            value: stats.bestStreak.toString(),
            subtitle: '${stats.bestStreak} days in a row',
            icon: Icons.local_fire_department_rounded,
            accent: const Color(0xFFFF8A1E),
          ),
          const SizedBox(width: 16),
          _buildMetricCard(
            isDark: isDark,
            width: 244,
            title: 'Check-ins',
            value: stats.totalCompletedCheckIns.toString(),
            subtitle: '${stats.totalTrackedHabits} habits tracked',
            icon: Icons.task_alt_rounded,
            accent: const Color(0xFF4B8DFF),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required bool isDark,
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    final background = isDark
        ? Color.alphaBlend(
            accent.withValues(alpha: 0.12),
            _surfaceColor(isDark),
          )
        : accent.withValues(alpha: 0.10);

    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.30 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 32 / 2,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 52 / 2,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(_StatsData stats, bool isDark) {
    final categories = stats.categoryMetrics.take(4).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        color: _surfaceColor(isDark),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Category Breakdown',
                style: TextStyle(
                  fontSize: 22 / 1.1,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Text(
                'Weekly Avg',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.42)
                      : const Color(0xFF98A2B3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 320,
            child: categories.isEmpty
                ? Center(
                    child: Text(
                      'No category data for this period',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : _buildCategoryChart(categories, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(List<_CategoryMetric> categories, bool isDark) {
    final maxPercent = categories
        .map((c) => c.completionRate * 100)
        .fold<double>(0, (prev, next) => math.max(prev, next));

    final maxY = math.max(100, ((maxPercent / 10).ceil() * 10) + 10).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.08),
              strokeWidth: 1,
              dashArray: const [5, 4],
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.20)
                  : Colors.black.withValues(alpha: 0.12),
              width: 1.2,
            ),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= categories.length) {
                  return const SizedBox.shrink();
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    categories[index].category.displayName,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.58)
                          : const Color(0xFF667085),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final metric = entry.value;
          final barColor = _categoryColor(metric.category);

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: metric.completionRate * 100,
                width: 52,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                color: barColor,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopPerformingSection(_StatsData stats, bool isDark) {
    final items = stats.topPerforming.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Top Performing',
                style: TextStyle(
                  fontSize: 40 / 1.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1FC997),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surfaceColor(isDark),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Complete your first habit to see performance insights.',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : const Color(0xFF667085),
                ),
              ),
            )
          else
            ...items.map((item) {
              final accent = _categoryColor(item.habit.category);
              final icon = _categoryIcon(item.habit.category);
              final percent = (item.completionRate * 100).round();

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _surfaceColor(isDark),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isDark ? 0.22 : 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icon, color: accent, size: 34),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.habit.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 36 / 2,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.habit.category.displayName} • ${item.bestStreak} day streak',
                            style: TextStyle(
                              fontSize: 18 / 1.3,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.58)
                                  : const Color(0xFF98A2B3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$percent%',
                          style: TextStyle(
                            fontSize: 34 / 1.7,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          percent >= 70
                              ? Icons.trending_up_rounded
                              : Icons.trending_flat_rounded,
                          color: accent,
                          size: 22,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights_rounded,
              size: 70,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
            const SizedBox(height: 14),
            Text(
              'No habits yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create habits to unlock your performance stats and trend charts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.55)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: isDark ? Colors.orange[300] : Colors.orange[700],
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load statistics',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to try again.',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshStats,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return const Color(0xFF1FC997);
      case HabitCategory.study:
        return const Color(0xFF8B6CF5);
      case HabitCategory.personal:
        return const Color(0xFFF43F5E);
      case HabitCategory.social:
        return const Color(0xFF4B8DFF);
      case HabitCategory.finance:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _categoryIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return Icons.directions_run_rounded;
      case HabitCategory.study:
        return Icons.calculate_rounded;
      case HabitCategory.personal:
        return Icons.menu_book_rounded;
      case HabitCategory.social:
        return Icons.people_alt_rounded;
      case HabitCategory.finance:
        return Icons.account_balance_wallet_rounded;
    }
  }
}

class _StatsData {
  final double completionRate;
  final double completionDelta;
  final int bestStreak;
  final int totalCompletedCheckIns;
  final int totalTrackedHabits;
  final List<_CategoryMetric> categoryMetrics;
  final List<_HabitPerformance> topPerforming;

  const _StatsData({
    required this.completionRate,
    required this.completionDelta,
    required this.bestStreak,
    required this.totalCompletedCheckIns,
    required this.totalTrackedHabits,
    required this.categoryMetrics,
    required this.topPerforming,
  });

  const _StatsData.empty()
    : completionRate = 0,
      completionDelta = 0,
      bestStreak = 0,
      totalCompletedCheckIns = 0,
      totalTrackedHabits = 0,
      categoryMetrics = const [],
      topPerforming = const [];

  bool get hasHabits => totalTrackedHabits > 0;
}

class _HabitPerformance {
  final Habit habit;
  final double completionRate;
  final int completedCount;
  final int expectedCount;
  final int bestStreak;

  const _HabitPerformance({
    required this.habit,
    required this.completionRate,
    required this.completedCount,
    required this.expectedCount,
    required this.bestStreak,
  });
}

class _CategoryMetric {
  final HabitCategory category;
  final double completionRate;
  final int completedCount;
  final int expectedCount;

  const _CategoryMetric({
    required this.category,
    required this.completionRate,
    required this.completedCount,
    required this.expectedCount,
  });
}

class _CategoryAccumulator {
  int expected = 0;
  int completed = 0;
}
