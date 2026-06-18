import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/auth_service.dart';
import '../core/services/projects_service.dart';
import '../core/text_formatters.dart';
import '../models/project.dart';

enum _BudgetType { fixed, hourly }

class CreateProjectView extends StatefulWidget {
  const CreateProjectView({super.key});

  @override
  State<CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<CreateProjectView> {
  static const _primary = Color(0xFF3B309E);
  static const _surfaceCream = Color(0xFFFBF9F2);
  static const _slate900 = Color(0xFF0F172A);
  static const _slate700 = Color(0xFF334155);
  static const _slate500 = Color(0xFF64748B);
  static const _slate200 = Color(0xFFE2E8F0);
  static const _slate800 = Color(0xFF1E293B);
  static const _bgDark = Color(0xFF0B1020);
  static const _error = Color(0xFFBA1A1A);

  static const _categories = projectCategories;

  static const _skills = [
    'UI/UX',
    'Figma',
    'Branding',
    'Logo Design',
    'Node.js',
    'Python',
    'React',
    'Flutter',
    'AWS',
    'WordPress',
    'PHP',
    'SEO',
    'Copywriting',
    'Social Media',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  final Set<String> _selectedSkills = {};
  _BudgetType _budgetType = _BudgetType.fixed;
  bool _showCategoryError = false;
  bool _showSkillsError = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final formValid = _formKey.currentState!.validate();
    final categoryValid = _selectedCategory != null;
    final skillsValid = _selectedSkills.isNotEmpty;

    setState(() {
      _showCategoryError = !categoryValid;
      _showSkillsError = !skillsValid;
    });

    if (!formValid || !categoryValid || !skillsValid) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      final user = await AuthService.instance.currentAppUser();
      if (user == null) {
        throw StateError('Sessão expirada. Faça login novamente.');
      }
      final minRaw = _minBudgetController.text.replaceAll('.', '');
      final maxRaw = _maxBudgetController.text.replaceAll('.', '');
      await ProjectsService.instance.createProject(
        ownerId: user.uid,
        clientName: user.displayName,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        skills: _selectedSkills.toList(),
        category: _selectedCategory!,
        minBudget: double.parse(minRaw),
        maxBudget: double.parse(maxRaw),
        isHourly: _budgetType == _BudgetType.hourly,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF086B53),
            content: Text(
              'Projeto publicado! Você receberá propostas em breve.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFBA1A1A),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              'Falha ao publicar: $e',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _validateTitle(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe um título';
    if (v.length < 10) return 'Mínimo 10 caracteres';
    if (v.length > 100) return 'Máximo 100 caracteres';
    return null;
  }

  String? _validateMinBudget(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Mínimo obrigatório';
    final n = int.tryParse(v.replaceAll('.', ''));
    if (n == null || n <= 0) return 'Valor inválido';
    return null;
  }

  String? _validateMaxBudget(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Máximo obrigatório';
    final max = int.tryParse(v.replaceAll('.', ''));
    if (max == null || max <= 0) return 'Valor inválido';
    final minStr = _minBudgetController.text.replaceAll('.', '');
    final min = int.tryParse(minStr);
    if (min != null && max < min) return 'Deve ser ≥ mínimo';
    return null;
  }

  String? _validateDescription(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Descreva seu projeto';
    if (v.length < 50) {
      return 'Mínimo de 50 caracteres (atual: ${v.length})';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _surfaceCream;
    final cardBg = isDark ? _slate800 : Colors.white;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final labelColor = isDark ? Colors.white.withValues(alpha: 0.85) : _slate700;
    final inputBorder = isDark ? _slate700 : _slate200;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: cardBg,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
      child: Scaffold(
        backgroundColor: bg,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(titleColor: titleColor),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conte-nos sobre o projeto',
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quanto mais clara a descrição, melhores serão as propostas.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: mutedColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _FieldLabel('Título do projeto', color: labelColor),
                        const SizedBox(height: 6),
                        _TextInput(
                          controller: _titleController,
                          hint: 'Ex.: Redesign do app de delivery',
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          validator: _validateTitle,
                          inputBg: cardBg,
                          inputBorder: inputBorder,
                          titleColor: titleColor,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        _FieldLabel('Categoria', color: labelColor),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories
                              .map(
                                (cat) => _SelectableChip(
                                  label: cat,
                                  selected: _selectedCategory == cat,
                                  onTap: () => setState(() {
                                    _selectedCategory = cat;
                                    _showCategoryError = false;
                                  }),
                                  cardBg: cardBg,
                                  borderColor: borderColor,
                                  isDark: isDark,
                                  labelColor: titleColor,
                                ),
                              )
                              .toList(),
                        ),
                        if (_showCategoryError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Text(
                              'Selecione uma categoria.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _error,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _FieldLabel('Habilidades', color: labelColor),
                            Text(
                              '${_selectedSkills.length} selecionada${_selectedSkills.length == 1 ? '' : 's'}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _skills
                              .map(
                                (skill) => _SelectableChip(
                                  label: skill,
                                  selected: _selectedSkills.contains(skill),
                                  onTap: () => setState(() {
                                    if (!_selectedSkills.add(skill)) {
                                      _selectedSkills.remove(skill);
                                    }
                                    if (_selectedSkills.isNotEmpty) {
                                      _showSkillsError = false;
                                    }
                                  }),
                                  cardBg: cardBg,
                                  borderColor: borderColor,
                                  isDark: isDark,
                                  labelColor: titleColor,
                                  compact: true,
                                ),
                              )
                              .toList(),
                        ),
                        if (_showSkillsError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Text(
                              'Escolha pelo menos uma habilidade.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _error,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        _FieldLabel('Tipo de orçamento', color: labelColor),
                        const SizedBox(height: 8),
                        _BudgetTypeSegmented(
                          selected: _budgetType,
                          onChange: (t) => setState(() => _budgetType = t),
                          cardBg: cardBg,
                          borderColor: inputBorder,
                          labelColor: titleColor,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel(
                          _budgetType == _BudgetType.hourly
                              ? 'Valor por hora (R\$)'
                              : 'Faixa de orçamento (R\$)',
                          color: labelColor,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _TextInput(
                                controller: _minBudgetController,
                                prefixText: 'R\$ ',
                                hint: 'Mínimo',
                                keyboardType: TextInputType.number,
                                inputFormatters: [ThousandsFormatter()],
                                validator: _validateMinBudget,
                                inputBg: cardBg,
                                inputBorder: inputBorder,
                                titleColor: titleColor,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TextInput(
                                controller: _maxBudgetController,
                                prefixText: 'R\$ ',
                                hint: 'Máximo',
                                keyboardType: TextInputType.number,
                                inputFormatters: [ThousandsFormatter()],
                                validator: _validateMaxBudget,
                                inputBg: cardBg,
                                inputBorder: inputBorder,
                                titleColor: titleColor,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _FieldLabel(
                          'Descrição do projeto',
                          color: labelColor,
                        ),
                        const SizedBox(height: 6),
                        _TextInput(
                          controller: _descriptionController,
                          hint:
                              'Descreva o que precisa ser feito, prazos, '
                              'referências e quaisquer requisitos técnicos.',
                          maxLines: 7,
                          minLines: 6,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          validator: _validateDescription,
                          inputBg: cardBg,
                          inputBorder: inputBorder,
                          titleColor: titleColor,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _BottomActionBar(
                navBg: cardBg,
                borderColor: borderColor,
                onSubmit: _isSubmitting ? null : _handleSubmit,
                isSubmitting: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.titleColor});

  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: Icon(Icons.arrow_back, color: titleColor),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Text(
                  'Publicar projeto',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: titleColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.cardBg,
    required this.borderColor,
    required this.isDark,
    required this.labelColor,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color cardBg;
  final Color borderColor;
  final bool isDark;
  final Color labelColor;
  final bool compact;

  static const _primary = Color(0xFF3B309E);

  @override
  Widget build(BuildContext context) {
    final selectedBg = isDark
        ? _primary.withValues(alpha: 0.22)
        : _primary.withValues(alpha: 0.10);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 11 : 14,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: selected ? selectedBg : cardBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? _primary : borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 14, color: _primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: compact ? 12 : 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? _primary : labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetTypeSegmented extends StatelessWidget {
  const _BudgetTypeSegmented({
    required this.selected,
    required this.onChange,
    required this.cardBg,
    required this.borderColor,
    required this.labelColor,
    required this.isDark,
  });

  final _BudgetType selected;
  final ValueChanged<_BudgetType> onChange;
  final Color cardBg;
  final Color borderColor;
  final Color labelColor;
  final bool isDark;

  static const _primary = Color(0xFF3B309E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segment('Preço fixo', _BudgetType.fixed, labelColor),
          ),
          Expanded(
            child: _segment('Por hora', _BudgetType.hourly, labelColor),
          ),
        ],
      ),
    );
  }

  Widget _segment(String label, _BudgetType type, Color labelColor) {
    final isSelected = selected == type;
    return InkWell(
      onTap: () => onChange(type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : labelColor,
          ),
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.hint,
    required this.inputBg,
    required this.inputBorder,
    required this.titleColor,
    required this.isDark,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.maxLines = 1,
    this.minLines,
  });

  final TextEditingController controller;
  final String hint;
  final String? prefixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final int? minLines;
  final Color inputBg;
  final Color inputBorder;
  final Color titleColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hintColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : const Color(0xFF94A3B8);
    final affixStyle = GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white70 : const Color(0xFF334155),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      cursorColor: const Color(0xFF3B309E),
      style: GoogleFonts.inter(fontSize: 15, color: titleColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: inputBg,
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 15, color: hintColor),
        prefixText: prefixText,
        prefixStyle: affixStyle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3B309E), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.navBg,
    required this.borderColor,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final Color navBg;
  final Color borderColor;
  final VoidCallback? onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3B309E),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF3B309E).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Publicar projeto'),
            ),
          ),
        ),
      ),
    );
  }
}
