import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/project.dart';

const _primary = Color(0xFF3B309E);
const _slate900 = Color(0xFF0F172A);
const _slate500 = Color(0xFF64748B);
const _slate800 = Color(0xFF1E293B);

/// Bottom sheet pra editar [ProjectFilters]. Pop com `null` = cancelou,
/// pop com [ProjectFilters] = aplicou (pode ser estado vazio = limpou tudo).
class FeedFiltersSheet extends StatefulWidget {
  const FeedFiltersSheet({super.key, required this.initial});

  final ProjectFilters initial;

  @override
  State<FeedFiltersSheet> createState() => _FeedFiltersSheetState();
}

class _FeedFiltersSheetState extends State<FeedFiltersSheet> {
  late Set<String> _categories;
  late Set<BudgetRange> _budgetRanges;
  late BudgetTypeFilter _budgetType;

  @override
  void initState() {
    super.initState();
    _categories = {...widget.initial.categories};
    _budgetRanges = {...widget.initial.budgetRanges};
    _budgetType = widget.initial.budgetType;
  }

  void _toggleCategory(String c) {
    setState(() {
      if (!_categories.add(c)) _categories.remove(c);
    });
  }

  void _toggleBudgetRange(BudgetRange r) {
    setState(() {
      if (!_budgetRanges.add(r)) _budgetRanges.remove(r);
    });
  }

  void _setBudgetType(BudgetTypeFilter t) {
    setState(() => _budgetType = t);
  }

  void _clearAll() {
    setState(() {
      _categories = {};
      _budgetRanges = {};
      _budgetType = BudgetTypeFilter.any;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      widget.initial.copyWith(
        categories: _categories,
        budgetRanges: _budgetRanges,
        budgetType: _budgetType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _slate800 : Colors.white;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: mutedColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filtros',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAll,
                    child: Text(
                      'Limpar',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'Categoria', color: mutedColor),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: projectCategories
                            .map((c) => _MultiChip(
                                  label: c,
                                  selected: _categories.contains(c),
                                  onTap: () => _toggleCategory(c),
                                  isDark: isDark,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      _SectionLabel(label: 'Orçamento', color: mutedColor),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: BudgetRange.values
                            .map((r) => _MultiChip(
                                  label: r.label,
                                  selected: _budgetRanges.contains(r),
                                  onTap: () => _toggleBudgetRange(r),
                                  isDark: isDark,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      _SectionLabel(label: 'Tipo', color: mutedColor),
                      const SizedBox(height: 10),
                      _TypeSegmented(
                        value: _budgetType,
                        onChanged: _setBudgetType,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _apply,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Aplicar filtros'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _MultiChip extends StatelessWidget {
  const _MultiChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? _primary
        : (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : _primary.withValues(alpha: 0.06));
    final fg = selected
        ? Colors.white
        : (isDark ? Colors.white : _slate900);
    final border = selected
        ? _primary
        : (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : _primary.withValues(alpha: 0.15));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 14, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSegmented extends StatelessWidget {
  const _TypeSegmented({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  final BudgetTypeFilter value;
  final ValueChanged<BudgetTypeFilter> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : _primary.withValues(alpha: 0.06);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _segment('Todos', BudgetTypeFilter.any),
          _segment('Preço fixo', BudgetTypeFilter.fixed),
          _segment('Por hora', BudgetTypeFilter.hourly),
        ],
      ),
    );
  }

  Widget _segment(String label, BudgetTypeFilter target) {
    final active = value == target;
    final fg = active ? Colors.white : (isDark ? Colors.white70 : _slate500);
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(target),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
