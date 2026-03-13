import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../home_view.dart';

class LoginView extends StatefulWidget {
  final int initialTab;

  const LoginView({super.key, this.initialTab = 0});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      setState(() {}); // Atualiza UI quando muda de tab
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleAuth() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    bool success;

    if (_tabController.index == 1) {
      // Sign Up
      success = await authViewModel.signUpWithEmail(
        email: email,
        password: password,
      );

      if (success) {
        _showSuccess(context.l10n.authAccountCreatedSuccess);
      }
    } else {
      // Login
      success = await authViewModel.signInWithEmail(
        email: email,
        password: password,
      );

      if (success) {
        _showSuccess(context.l10n.authWelcomeBackSuccess);
      }
    }

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      // Navegar para home e remover todas as rotas anteriores
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeView()),
        (route) => false,
      );
    } else if (authViewModel.errorMessage != null) {
      _showError(_localizedAuthMessage(authViewModel.errorMessage!));
      authViewModel.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background com imagem
          _buildBackground(),

          // Botão voltar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 12),

                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Título
                      Text(
                        _tabController.index == 0
                            ? context.l10n.authWelcomeBack
                            : context.l10n.authCreateAccount,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtítulo
                      Text(
                        _tabController.index == 0
                            ? context.l10n.authWelcomeSubtitle
                            : context.l10n.authCreateSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.6)
                              : const Color(0xFF6B7280),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tabs
                      _buildTabs(isDarkMode),

                      const SizedBox(height: 32),

                      // Campo Email
                      _buildEmailField(isDarkMode),

                      const SizedBox(height: 20),

                      // Campo Password
                      _buildPasswordField(isDarkMode),

                      const SizedBox(height: 16),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _showInfo(context.l10n.authForgotPasswordSoon);
                          },
                          child: Text(
                            context.l10n.authForgotPassword,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? const Color(0xFF9B6FFF)
                                  : const Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botão Log In
                      _buildLoginButton(),

                      const SizedBox(height: 32),

                      // Divisor
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              context.l10n.authOrContinueWith,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Botões sociais
                      _buildSocialButtons(isDarkMode),

                      const SizedBox(height: 24),

                      // Termos
                      _buildTermsText(isDarkMode),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          // Área do topo com imagem (40% da tela)
          Expanded(
            flex: 4,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                'assets/imgs/grafico_plantas.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          // Área do formulário (60% da tela)
          Expanded(flex: 6, child: Container(color: Colors.transparent)),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF7C3AED),
        indicatorWeight: 3,
        labelColor: isDarkMode
            ? const Color(0xFF9B6FFF)
            : const Color(0xFF7C3AED),
        unselectedLabelColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.4)
            : const Color(0xFF9CA3AF),
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: context.l10n.authTabLogin),
          Tab(text: context.l10n.authTabSignUp),
        ],
      ),
    );
  }

  Widget _buildEmailField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.authEmailLabel,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final message = Provider.of<AuthViewModel>(
              context,
              listen: false,
            ).validateEmail(value);

            return message == null ? null : _localizedAuthMessage(message);
          },
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: 'student@example.com',
            hintStyle: TextStyle(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.3)
                  : const Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.5)
                  : const Color(0xFF6B7280),
            ),
            filled: true,
            fillColor: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.authPasswordLabel,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: (value) {
            final message = Provider.of<AuthViewModel>(
              context,
              listen: false,
            ).validatePassword(value);

            return message == null ? null : _localizedAuthMessage(message);
          },
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.3)
                  : const Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.5)
                  : const Color(0xFF6B7280),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.5)
                    : const Color(0xFF6B7280),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B6FFF), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _tabController.index == 0
                    ? context.l10n.authLoginButton
                    : context.l10n.authSignUpButton,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialButtons(bool isDarkMode) {
    return _buildSocialButton(
      icon: '🇬',
      label: context.l10n.authGoogleButton,
      isDarkMode: isDarkMode,
      onPressed: _handleGoogleSignIn,
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    final success = await authViewModel.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      _showSuccess(context.l10n.authGoogleSuccess);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeView()),
        (route) => false,
      );
    } else if (authViewModel.errorMessage != null) {
      _showError(_localizedAuthMessage(authViewModel.errorMessage!));
      authViewModel.clearError();
    }
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required bool isDarkMode,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsText(bool isDarkMode) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.5)
              : const Color(0xFF6B7280),
        ),
        children: [
          TextSpan(text: context.l10n.authTermsPrefix),
          TextSpan(
            text: context.l10n.authTermsService,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          TextSpan(text: context.l10n.authTermsAnd),
          TextSpan(
            text: context.l10n.authTermsPrivacy,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          TextSpan(text: context.l10n.authTermsSuffix),
        ],
      ),
    );
  }

  String _localizedAuthMessage(String message) {
    final l10n = context.l10n;

    switch (message) {
      case 'Email is required':
        return l10n.authErrorEmailRequired;
      case 'Enter a valid email':
      case 'The email address is invalid':
        return l10n.authErrorInvalidEmail;
      case 'Password is required':
        return l10n.authErrorPasswordRequired;
      case 'Password must be at least 6 characters':
        return l10n.authErrorPasswordMinLength;
      case 'The password is too weak':
        return l10n.authErrorWeakPassword;
      case 'An account already exists for this email':
        return l10n.authErrorEmailAlreadyInUse;
      case 'Email/password accounts are not enabled':
      case 'Google sign-in is not enabled':
        return l10n.authErrorGoogleDisabled;
      case 'No user found for this email':
        return l10n.authErrorUserNotFound;
      case 'Wrong password':
        return l10n.authErrorWrongPassword;
      case 'This user account has been disabled':
        return l10n.authErrorUserDisabled;
      case 'Invalid email or password':
        return l10n.authErrorInvalidCredential;
      case 'An account already exists with the same email but different sign-in credentials':
        return l10n.authErrorAccountExistsDifferentCredential;
      case 'The credential is malformed or has expired':
        return l10n.authErrorGoogleCredentialMalformed;
    }

    if (message.startsWith('An error occurred during sign up:') ||
        message.startsWith('An error occurred during sign in:') ||
        message.startsWith('An error occurred during Google sign in:') ||
        message.startsWith('An unexpected error occurred:')) {
      return l10n.authErrorUnexpected;
    }

    return message;
  }
}
