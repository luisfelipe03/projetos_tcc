import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/project.dart';

class SendProposalView extends StatefulWidget {
  const SendProposalView({super.key, required this.project});

  final Project project;

  @override
  State<SendProposalView> createState() => _SendProposalViewState();
}

class _SendProposalViewState extends State<SendProposalView> {
  static const _primary = Color(0xFF3B309E);
  static const _surfaceCream = Color(0xFFFBF9F2);
  static const _slate900 = Color(0xFF0F172A);
  static const _slate700 = Color(0xFF334155);
  static const _slate500 = Color(0xFF64748B);
  static const _slate200 = Color(0xFFE2E8F0);
  static const _slate800 = Color(0xFF1E293B);
  static const _bgDark = Color(0xFF0B1020);

  static const _minMessageChars = 30;
  static const _maxMessageChars = 1000;

  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _daysController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onMessageChanged);
  }

  @override
  void dispose() {
    _valueController.dispose();
    _daysController.dispose();
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _onMessageChanged() => setState(() {});

  void _handleSubmit() {
    final ok = _formKey.currentState!.validate();
    if (!ok) return;

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF086B53),
          content: Text(
            'Proposta enviada com sucesso! Você será notificado se for aceita.',
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
  }

  String? _validateValue(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe o valor da proposta';
    final n = int.tryParse(v.replaceAll('.', ''));
    if (n == null || n <= 0) return 'Valor inválido';
    return null;
  }

  String? _validateDays(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe o prazo estimado';
    final n = int.tryParse(v);
    if (n == null || n <= 0) return 'Prazo inválido';
    if (n > 365) return 'Prazo máximo de 365 dias';
    return null;
  }

  String? _validateMessage(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Escreva uma mensagem ao cliente';
    if (v.length < _minMessageChars) {
      return 'Mínimo de $_minMessageChars caracteres (atual: ${v.length})';
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
                        _ProjectRecap(
                          project: widget.project,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          titleColor: titleColor,
                          mutedColor: mutedColor,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Sua proposta',
                          style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Capriche na mensagem — clientes pulam propostas genéricas.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: mutedColor,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _FieldLabel('Valor da proposta', color: labelColor),
                        const SizedBox(height: 6),
                        _TextInput(
                          controller: _valueController,
                          prefixText: 'R\$ ',
                          suffixText: widget.project.isHourly ? '/h' : null,
                          hint: '0',
                          keyboardType: TextInputType.number,
                          inputFormatters: [_ThousandsFormatter()],
                          validator: _validateValue,
                          inputBg: cardBg,
                          inputBorder: inputBorder,
                          titleColor: titleColor,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Prazo estimado', color: labelColor),
                        const SizedBox(height: 6),
                        _TextInput(
                          controller: _daysController,
                          icon: Icons.event_outlined,
                          suffixText: 'dias',
                          hint: '14',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _validateDays,
                          inputBg: cardBg,
                          inputBorder: inputBorder,
                          titleColor: titleColor,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _FieldLabel(
                              'Mensagem ao cliente',
                              color: labelColor,
                            ),
                            Text(
                              '${_messageController.text.length} / $_maxMessageChars',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: _messageController.text.length <
                                        _minMessageChars
                                    ? mutedColor
                                    : const Color(0xFF086B53),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _TextInput(
                          controller: _messageController,
                          hint:
                              'Apresente-se em poucas linhas, descreva sua '
                              'abordagem para este projeto e o que torna você '
                              'a melhor escolha.',
                          maxLines: 7,
                          minLines: 6,
                          maxLength: _maxMessageChars,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          validator: _validateMessage,
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
                onSubmit: _handleSubmit,
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
                  'Enviar proposta',
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

class _ProjectRecap extends StatelessWidget {
  const _ProjectRecap({
    required this.project,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
  });

  final Project project;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;

  static const _primary = Color(0xFF3B309E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _primary.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.work_outline,
              color: _primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Propondo para',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: mutedColor,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${project.formattedBudget()} · ${project.budgetTypeLabel()}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: mutedColor,
                  ),
                ),
              ],
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

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.hint,
    required this.inputBg,
    required this.inputBorder,
    required this.titleColor,
    required this.isDark,
    this.icon,
    this.prefixText,
    this.suffixText,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final String? prefixText;
  final String? suffixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
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
      maxLength: maxLength,
      cursorColor: const Color(0xFF3B309E),
      style: GoogleFonts.inter(fontSize: 15, color: titleColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: inputBg,
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 15, color: hintColor),
        prefixIcon: icon != null
            ? Icon(icon, color: hintColor, size: 20)
            : null,
        prefixText: prefixText,
        prefixStyle: affixStyle,
        suffixText: suffixText,
        suffixStyle: affixStyle,
        counterText: '',
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
  });

  final Color navBg;
  final Color borderColor;
  final VoidCallback onSubmit;

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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Enviar proposta'),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
