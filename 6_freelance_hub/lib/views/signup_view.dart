import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_role.dart';
import 'home_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  static const _primary = Color(0xFF3B309E);
  static const _slate900 = Color(0xFF0F172A);
  static const _slate700 = Color(0xFF334155);
  static const _slate500 = Color(0xFF64748B);
  static const _slate400 = Color(0xFF94A3B8);
  static const _slate200 = Color(0xFFE2E8F0);
  static const _slate800 = Color(0xFF1E293B);
  static const _bgDark = Color(0xFF0B1020);
  static const _error = Color(0xFFBA1A1A);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole? _selectedRole;
  bool _obscurePassword = true;
  bool _termsAccepted = false;
  bool _showRoleError = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final formValid = _formKey.currentState!.validate();
    final roleValid = _selectedRole != null;
    final termsValid = _termsAccepted;

    setState(() {
      _showRoleError = !roleValid;
      _showTermsError = !termsValid;
    });

    if (!formValid || !roleValid || !termsValid) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeView()),
    );
  }

  void _goToLogin() {
    Navigator.of(context).maybePop();
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu nome';
    if (v.length < 3) return 'Nome muito curto';
    return null;
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu e-mail';
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!emailRegex.hasMatch(v)) return 'E-mail inválido';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Informe sua senha';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : Colors.white;
    final titleColor = isDark ? Colors.white : _slate900;
    final subtitleColor = isDark ? Colors.white70 : _slate500;
    final labelColor = isDark ? Colors.white.withValues(alpha: 0.85) : _slate700;
    final inputBg = isDark ? _slate800 : Colors.white;
    final inputBorder = isDark ? _slate700 : _slate200;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: bg,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _TopBar(titleColor: titleColor),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Crie sua conta',
                          style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            height: 1.15,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Junte-se ao FreelanceHub em poucos passos.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _FieldLabel('Eu sou:', color: labelColor),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _RoleCard(
                                role: UserRole.client,
                                icon: Icons.business_center_outlined,
                                selected: _selectedRole == UserRole.client,
                                onTap: () => setState(() {
                                  _selectedRole = UserRole.client;
                                  _showRoleError = false;
                                }),
                                isDark: isDark,
                                inputBorder: inputBorder,
                                inputBg: inputBg,
                                labelColor: titleColor,
                                taglineColor: subtitleColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RoleCard(
                                role: UserRole.freelancer,
                                icon: Icons.design_services_outlined,
                                selected: _selectedRole == UserRole.freelancer,
                                onTap: () => setState(() {
                                  _selectedRole = UserRole.freelancer;
                                  _showRoleError = false;
                                }),
                                isDark: isDark,
                                inputBorder: inputBorder,
                                inputBg: inputBg,
                                labelColor: titleColor,
                                taglineColor: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                        if (_showRoleError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Text(
                              'Selecione um papel para continuar.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _error,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        _FieldLabel('Nome completo', color: labelColor),
                        const SizedBox(height: 6),
                        _TextInput(
                          controller: _nameController,
                          icon: Icons.person_outline,
                          hint: 'João Silva',
                          keyboardType: TextInputType.name,
                          autofillHints: const [AutofillHints.name],
                          textCapitalization: TextCapitalization.words,
                          validator: _validateName,
                          inputBg: inputBg,
                          inputBorder: inputBorder,
                          titleColor: titleColor,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('E-mail', color: labelColor),
                        const SizedBox(height: 6),
                        _TextInput(
                          controller: _emailController,
                          icon: Icons.mail_outline,
                          hint: 'nome@empresa.com',
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: _validateEmail,
                          inputBg: inputBg,
                          inputBorder: inputBorder,
                          titleColor: titleColor,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Senha', color: labelColor),
                        const SizedBox(height: 6),
                        _TextInput(
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          hint: '••••••••',
                          obscure: _obscurePassword,
                          keyboardType: TextInputType.visiblePassword,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: _validatePassword,
                          inputBg: inputBg,
                          inputBorder: inputBorder,
                          titleColor: titleColor,
                          isDark: isDark,
                          suffix: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: _slate400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _TermsCheckbox(
                          checked: _termsAccepted,
                          onChanged: (v) => setState(() {
                            _termsAccepted = v ?? false;
                            if (_termsAccepted) _showTermsError = false;
                          }),
                          textColor: labelColor,
                          linkColor: _primary,
                          showError: _showTermsError,
                          errorColor: _error,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: _handleSubmit,
                            style: FilledButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _primary.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Criar conta'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Já tem uma conta? ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: subtitleColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: _goToLogin,
                                child: Text(
                                  'Entrar',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                  'Criar conta',
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.isDark,
    required this.inputBorder,
    required this.inputBg,
    required this.labelColor,
    required this.taglineColor,
  });

  final UserRole role;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  final Color inputBorder;
  final Color inputBg;
  final Color labelColor;
  final Color taglineColor;

  static const _primary = Color(0xFF3B309E);
  static const _primaryLight = Color(0xFFE3DFFF);

  @override
  Widget build(BuildContext context) {
    final selectedBg = isDark
        ? _primary.withValues(alpha: 0.18)
        : _primaryLight.withValues(alpha: 0.5);
    final bg = selected ? selectedBg : inputBg;
    final borderColor = selected ? _primary : inputBorder;
    final iconColor = selected
        ? _primary
        : (isDark ? Colors.white70 : const Color(0xFF64748B));
    final titleStyle = GoogleFonts.dmSans(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: selected ? _primary : labelColor,
    );
    final taglineStyle = GoogleFonts.inter(
      fontSize: 11,
      color: taglineColor,
      height: 1.3,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 26, color: iconColor),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 160),
                  opacity: selected ? 1.0 : 0.0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: _primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(role.displayName, style: titleStyle),
            const SizedBox(height: 4),
            Text(role.tagline, style: taglineStyle),
          ],
        ),
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
    required this.icon,
    required this.hint,
    required this.inputBg,
    required this.inputBorder,
    required this.titleColor,
    required this.isDark,
    this.obscure = false,
    this.keyboardType,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.suffix,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final Widget? suffix;
  final Color inputBg;
  final Color inputBorder;
  final Color titleColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hintColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : const Color(0xFF94A3B8);
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      validator: validator,
      cursorColor: const Color(0xFF3B309E),
      style: GoogleFonts.inter(fontSize: 15, color: titleColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: inputBg,
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 15, color: hintColor),
        prefixIcon: Icon(icon, color: hintColor, size: 20),
        suffixIcon: suffix,
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

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.checked,
    required this.onChanged,
    required this.textColor,
    required this.linkColor,
    required this.showError,
    required this.errorColor,
  });

  final bool checked;
  final ValueChanged<bool?> onChanged;
  final Color textColor;
  final Color linkColor;
  final bool showError;
  final Color errorColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: checked,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  color: showError ? errorColor : const Color(0xFF94A3B8),
                  width: 1.5,
                ),
                activeColor: const Color(0xFF3B309E),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: textColor,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'Concordo com os '),
                      TextSpan(
                        text: 'Termos de Uso',
                        style: TextStyle(
                          color: linkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: ' e a '),
                      TextSpan(
                        text: 'Política de Privacidade',
                        style: TextStyle(
                          color: linkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 34),
            child: Text(
              'Você precisa aceitar os termos para continuar.',
              style: GoogleFonts.inter(fontSize: 12, color: errorColor),
            ),
          ),
      ],
    );
  }
}
