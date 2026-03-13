import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/habit_viewmodel.dart';
import '../../models/habit.dart';
import '../../models/habit_frequency.dart';
import '../../models/habit_category.dart';
import '../../models/habit_color.dart';
import '../../models/habit_reminder.dart';
import '../../models/reminder_repeat.dart';
import '../../models/day_of_week.dart';
import '../../l10n/l10n.dart';

class CreateHabitView extends StatefulWidget {
  final Habit? habit; // Habit opcional para edição

  const CreateHabitView({super.key, this.habit});

  @override
  State<CreateHabitView> createState() => _CreateHabitViewState();
}

class _CreateHabitViewState extends State<CreateHabitView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  HabitCategory _selectedCategory = HabitCategory.health;
  HabitColor _selectedColor = HabitColor.green;

  bool _reminderEnabled = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  ReminderRepeat _reminderRepeat = ReminderRepeat.daily;
  List<DayOfWeek> _selectedDays = []; // Para reminder
  List<DayOfWeek> _habitWeekDays = []; // Para hábitos semanais

  bool get _isEditMode => widget.habit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadHabitData();
    }
  }

  void _loadHabitData() {
    final habit = widget.habit!;
    _titleController.text = habit.title;
    _selectedFrequency = habit.frequency;
    _selectedCategory = habit.category;
    _selectedColor = habit.habitColor;

    // Carrega dias da semana para hábitos semanais
    if (habit.frequency == HabitFrequency.weekly &&
        habit.selectedWeekDays.isNotEmpty) {
      _habitWeekDays = habit.selectedWeekDays
          .map((dayNum) => DayOfWeek.fromWeekdayNumber(dayNum))
          .toList();
    }

    // Carrega reminder se existir
    if (habit.reminder != null) {
      final reminder = habit.reminder!;
      _reminderEnabled = true;
      _selectedTime = reminder.time;
      _reminderRepeat = reminder.repeat;
      _selectedDays = reminder.daysOfWeek;
    } else {
      _reminderEnabled = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    setState(() {
      _selectedFrequency = HabitFrequency.daily;
      _selectedCategory = HabitCategory.health;
      _selectedColor = HabitColor.green;
      _reminderEnabled = true;
      _selectedTime = const TimeOfDay(hour: 7, minute: 0);
      _reminderRepeat = ReminderRepeat.daily;
      _selectedDays = [];
      _habitWeekDays = [];
    });
  }

  String _localizedHabitError(String? rawError) {
    final l10n = context.l10n;
    final normalizedError = rawError?.replaceFirst('Exception: ', '').trim();

    switch (normalizedError) {
      case 'User not authenticated':
        return l10n.habitErrorUnauthenticated;
      case 'Habit title cannot be empty':
        return l10n.habitFormNameRequired;
      case 'Habit not found':
        return l10n.habitErrorNotFound;
      default:
        return _isEditMode
            ? l10n.habitFormUpdateFailed
            : l10n.habitFormCreateFailed;
    }
  }

  String _dayChipLabel(DayOfWeek day) {
    final label = day.localizedShortLabel(context.l10n).toUpperCase();
    return label.length <= 3 ? label : label.substring(0, 3);
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              dialBackgroundColor: Theme.of(context).cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final habitViewModel = context.read<HabitViewModel>();
    final l10n = context.l10n;

    // Cria o reminder se estiver ativo
    HabitReminder? reminder;
    if (_reminderEnabled) {
      // Para weekly, garantir que há dias selecionados
      if (_reminderRepeat == ReminderRepeat.weekly) {
        if (_selectedDays.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.habitFormWeeklyReminderDaysError),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        reminder = HabitReminder(
          time: _selectedTime,
          repeat: _reminderRepeat,
          daysOfWeek: _selectedDays,
        );
      } else {
        reminder = HabitReminder(time: _selectedTime, repeat: _reminderRepeat);
      }
    }

    final weekDays = _habitWeekDays.map((day) => day.weekdayNumber).toList();

    bool success;
    if (_isEditMode) {
      // Modo de edição
      success = await habitViewModel.updateHabit(
        habitId: widget.habit!.id,
        title: _titleController.text,
        frequency: _selectedFrequency,
        category: _selectedCategory,
        habitColor: _selectedColor,
        reminder: reminder,
        selectedWeekDays: weekDays,
      );
    } else {
      // Modo de criação
      success = await habitViewModel.createHabit(
        title: _titleController.text,
        frequency: _selectedFrequency,
        category: _selectedCategory,
        habitColor: _selectedColor,
        reminder: reminder,
        selectedWeekDays: weekDays,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? l10n.habitFormUpdatedSuccess
                : l10n.habitFormCreatedSuccess,
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.of(context).pop(true); // Retorna true para indicar sucesso
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizedHabitError(habitViewModel.error)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0D15)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.commonCancel,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        ),
        leadingWidth: 108,
        title: Text(
          _isEditMode ? l10n.habitFormTitleEdit : l10n.habitFormTitleCreate,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetForm,
            child: Text(
              l10n.commonReset,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFA855F7)
                    : const Color(0xFF10B981),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionLabel(l10n.habitFormSectionName),
            const SizedBox(height: 12),
            _buildTitleField(),
            const SizedBox(height: 28),
            _buildSectionLabel(l10n.habitFormSectionFrequency),
            const SizedBox(height: 12),
            _buildFrequencySelector(),
            if (_selectedFrequency == HabitFrequency.weekly) ...[
              const SizedBox(height: 12),
              _buildHabitWeekDaySelector(),
            ],
            const SizedBox(height: 28),
            _buildSectionLabel(l10n.habitFormSectionCategory),
            const SizedBox(height: 12),
            _buildCategorySelector(),
            const SizedBox(height: 28),
            _buildSectionLabel(l10n.habitFormSectionReminder),
            const SizedBox(height: 12),
            _buildReminderCard(),
            if (_reminderEnabled &&
                _reminderRepeat == ReminderRepeat.weekly) ...[
              const SizedBox(height: 12),
              _buildWeekDaySelector(),
            ],
            const SizedBox(height: 28),
            _buildSectionLabel(l10n.habitFormSectionColor),
            const SizedBox(height: 12),
            _buildColorSelector(),
            const SizedBox(height: 40),
            _buildSaveButton(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Colors.grey[500],
      ),
    );
  }

  Widget _buildTitleField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1625) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: _titleController,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: l10n.habitFormNameHint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          suffixIcon: Icon(Icons.edit_outlined, color: Colors.grey[400]),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.habitFormNameRequired;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildFrequencySelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1625) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFrequencyButton(
              HabitFrequency.daily,
              Icons.calendar_today,
            ),
          ),
          Expanded(
            child: _buildFrequencyButton(
              HabitFrequency.weekly,
              Icons.view_week,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyButton(HabitFrequency frequency, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedFrequency == frequency;
    final l10n = context.l10n;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFrequency = frequency;
          // Ajusta o reminder repeat quando mudar a frequência
          if (frequency == HabitFrequency.daily) {
            _reminderRepeat = ReminderRepeat.daily;
            _selectedDays = [];
          } else if (frequency == HabitFrequency.weekly) {
            _reminderRepeat = ReminderRepeat.weekly;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? const Color(0xFFA855F7).withValues(alpha: 0.15)
                    : const Color(0xFF10B981).withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? (isDark ? const Color(0xFFA855F7) : const Color(0xFF10B981))
                  : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              frequency.localizedLabel(l10n),
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark
                          ? const Color(0xFFA855F7)
                          : const Color(0xFF10B981))
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryCard(
            HabitCategory.health,
            Icons.favorite,
            const Color(0xFFEF4444),
          ),
          _buildCategoryCard(
            HabitCategory.study,
            Icons.school,
            const Color(0xFF3B82F6),
          ),
          _buildCategoryCard(
            HabitCategory.finance,
            Icons.attach_money,
            const Color(0xFF10B981),
          ),
          _buildCategoryCard(
            HabitCategory.personal,
            Icons.person,
            const Color(0xFFA855F7),
          ),
          _buildCategoryCard(
            HabitCategory.social,
            Icons.people,
            const Color(0xFFF97316),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    HabitCategory category,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedCategory == category;
    final l10n = context.l10n;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (isDark ? const Color(0xFF1A1625) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              category.localizedLabel(l10n),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final materialL10n = MaterialLocalizations.of(context);
    final use24HourFormat = MediaQuery.alwaysUse24HourFormatOf(context);
    final periodLabel = _selectedTime.period == DayPeriod.am
        ? materialL10n.anteMeridiemAbbreviation
        : materialL10n.postMeridiemAbbreviation;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1625) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications,
              color: Color(0xFFF97316),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: _reminderEnabled ? _selectTime : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!use24HourFormat)
                    Text(
                      periodLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Switch(
            value: _reminderEnabled,
            onChanged: (value) {
              setState(() {
                _reminderEnabled = value;
              });
            },
            activeTrackColor: isDark
                ? const Color(0xFFA855F7)
                : const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaySelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1625) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.habitFormRepeatOn,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: DayOfWeek.values.map((day) {
              final isSelected = _selectedDays.contains(day);
              final color = isDark
                  ? const Color(0xFFA855F7)
                  : const Color(0xFF10B981);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(day);
                    } else {
                      _selectedDays.add(day);
                    }
                  });
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : Colors.grey[400]!,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _dayChipLabel(day),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitWeekDaySelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1625) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.habitFormWeeklyDaysPrompt,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: DayOfWeek.values.map((day) {
              final isSelected = _habitWeekDays.contains(day);
              final color = isDark
                  ? const Color(0xFFA855F7)
                  : const Color(0xFF10B981);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _habitWeekDays.remove(day);
                    } else {
                      _habitWeekDays.add(day);
                    }
                  });
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : Colors.grey[400]!,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _dayChipLabel(day),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: HabitColor.values.map((color) {
        final isSelected = _selectedColor == color;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.color.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 30)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return Consumer<HabitViewModel>(
      builder: (context, viewModel, child) {
        final l10n = context.l10n;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFFA855F7), const Color(0xFF9333EA)]
                  : [const Color(0xFF10B981), const Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    (isDark ? const Color(0xFFA855F7) : const Color(0xFF10B981))
                        .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: viewModel.isLoading ? null : _saveHabit,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _isEditMode
                                ? l10n.habitFormUpdateAction
                                : l10n.habitFormSaveAction,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
