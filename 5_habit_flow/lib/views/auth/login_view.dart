import 'package:flutter/material.dart';

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
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
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
            initialChildSize: 0.75,
            minChildSize: 0.75,
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
                              ? Colors.white.withOpacity(0.3)
                              : Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Título
                    Text(
                      _tabController.index == 0
                          ? 'Welcome Back'
                          : 'Create Account',
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
                          ? 'Let\'s continue your habit journey'
                          : 'Start building your habits today',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.6)
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
                          // TODO: Implementar recuperação de senha
                        },
                        child: Text(
                          'Forgot Password?',
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
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.5)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C5F54), Color(0xFF1A3A32)],
        ),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Image.asset(
            'assets/imgs/grafico_plantas.png',
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
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
            ? Colors.white.withOpacity(0.4)
            : const Color(0xFF9CA3AF),
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Sign Up'),
        ],
      ),
    );
  }

  Widget _buildEmailField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: 'student@example.com',
            hintStyle: TextStyle(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.3)
                  : const Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: isDarkMode
                  ? Colors.white.withOpacity(0.5)
                  : const Color(0xFF6B7280),
            ),
            filled: true,
            fillColor: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
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
          'Password',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.3)
                  : const Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: isDarkMode
                  ? Colors.white.withOpacity(0.5)
                  : const Color(0xFF6B7280),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.5)
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
                ? Colors.white.withOpacity(0.05)
                : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
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
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implementar login
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Log In',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtons(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: '🇬',
            label: 'Google',
            isDarkMode: isDarkMode,
            onPressed: () {
              // TODO: Implementar login com Google
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSocialButton(
            icon: '',
            label: 'Apple',
            isDarkMode: isDarkMode,
            onPressed: () {
              // TODO: Implementar login com Apple
            },
          ),
        ),
      ],
    );
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
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
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
              decoration: BoxDecoration(
                color: label == 'Google'
                    ? Colors.white
                    : (isDarkMode ? Colors.white : const Color(0xFF1F2937)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: label == 'Google'
                    ? const Text(
                        'G',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4285F4),
                        ),
                      )
                    : Icon(
                        Icons.apple,
                        color: isDarkMode
                            ? const Color(0xFF1F2937)
                            : Colors.white,
                        size: 16,
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
              ? Colors.white.withOpacity(0.5)
              : const Color(0xFF6B7280),
        ),
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
