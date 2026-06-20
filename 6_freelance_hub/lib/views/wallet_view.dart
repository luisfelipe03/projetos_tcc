import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/wallet_service.dart';
import '../models/wallet.dart';

const _primary = Color(0xFF3B309E);
const _surfaceCream = Color(0xFFFBF9F2);
const _slate900 = Color(0xFF0F172A);
const _slate500 = Color(0xFF64748B);
const _slate800 = Color(0xFF1E293B);
const _bgDark = Color(0xFF0B1020);
const _successGreen = Color(0xFF086B53);
const _errorRed = Color(0xFFBA1A1A);
const _amber = Color(0xFFC2410C);

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  Stream<Wallet>? _walletStream;
  Stream<List<WalletTransaction>>? _txStream;
  String? _uid;
  String? _loadError;
  bool _depositing = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    if (Firebase.apps.isEmpty) {
      setState(() => _loadError = 'Sessão expirada.');
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loadError = 'Sessão expirada. Faça login novamente.');
      return;
    }
    _uid = user.uid;
    _walletStream = WalletService.instance.streamWallet(user.uid);
    _txStream = WalletService.instance.streamTransactions(user.uid);
  }

  Future<void> _openDepositSheet() async {
    if (_depositing) return;
    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DepositSheet(),
    );
    if (!mounted || amount == null) return;
    setState(() => _depositing = true);
    try {
      await WalletService.instance.simulateDeposit(amount);
      if (!mounted) return;
      _showSnack(
        '${formatCurrencyBrl(amount)} adicionado à carteira.',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(_humanize(e), success: false);
    } finally {
      if (mounted) setState(() => _depositing = false);
    }
  }

  String _humanize(Object e) {
    if (e is FirebaseFunctionsException) {
      switch (e.code) {
        case 'unauthenticated':
          return 'Sessão expirada. Faça login novamente.';
        case 'invalid-argument':
          return e.message ?? 'Valor inválido.';
        default:
          return 'Falha no depósito: ${e.message ?? e.code}';
      }
    }
    return 'Falha no depósito: $e';
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: success ? _successGreen : _errorRed,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _surfaceCream;
    final cardBg = isDark ? _slate800 : Colors.white;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);

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
          child: _buildBody(
            cardBg: cardBg,
            titleColor: titleColor,
            mutedColor: mutedColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required Color cardBg,
    required Color titleColor,
    required Color mutedColor,
    required Color borderColor,
    required bool isDark,
  }) {
    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: Text(
            _loadError!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Header(titleColor: titleColor),
        ),
        SliverToBoxAdapter(
          child: StreamBuilder<Wallet>(
            stream: _walletStream,
            builder: (context, snap) {
              final wallet = snap.data ?? Wallet.empty(_uid ?? '');
              return _BalanceCard(
                wallet: wallet,
                titleColor: titleColor,
                mutedColor: mutedColor,
                borderColor: borderColor,
                depositing: _depositing,
                onDeposit: _openDepositSheet,
              );
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Histórico',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ),
        ),
        StreamBuilder<List<WalletTransaction>>(
          stream: _txStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: _primary),
                  ),
                ),
              );
            }
            if (snap.hasError) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Text(
                    'Erro ao carregar transações: ${snap.error}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: mutedColor,
                    ),
                  ),
                ),
              );
            }
            final txs = snap.data ?? const <WalletTransaction>[];
            if (txs.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 32, color: mutedColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nenhuma transação ainda. Adicione fundos pra '
                            'aceitar propostas como cliente.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: mutedColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              sliver: SliverList.separated(
                itemCount: txs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _TransactionCard(
                  tx: txs[i],
                  cardBg: cardBg,
                  titleColor: titleColor,
                  mutedColor: mutedColor,
                  borderColor: borderColor,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.titleColor});

  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: Icon(Icons.arrow_back, color: titleColor),
          ),
          Expanded(
            child: Text(
              'Carteira',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: titleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.wallet,
    required this.titleColor,
    required this.mutedColor,
    required this.borderColor,
    required this.depositing,
    required this.onDeposit,
  });

  final Wallet wallet;
  final Color titleColor;
  final Color mutedColor;
  final Color borderColor;
  final bool depositing;
  final VoidCallback onDeposit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B309E), Color(0xFF534AB7)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SALDO DISPONÍVEL',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.75),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatCurrencyBrl(wallet.availableBalance),
              style: GoogleFonts.dmSans(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bloqueado em escrow',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  Text(
                    formatCurrencyBrl(wallet.escrowBalance),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: depositing ? null : onDeposit,
                icon: depositing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(_primary),
                        ),
                      )
                    : const Icon(Icons.add, size: 18),
                label: const Text('Adicionar fundos (modo demo)'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.tx,
    required this.cardBg,
    required this.titleColor,
    required this.mutedColor,
    required this.borderColor,
  });

  final WalletTransaction tx;
  final Color cardBg;
  final Color titleColor;
  final Color mutedColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final positive = tx.balanceDelta > 0;
    final amountColor = positive ? _successGreen : _amber;
    final iconBg = positive
        ? _successGreen.withValues(alpha: 0.15)
        : _amber.withValues(alpha: 0.15);
    final icon = _iconFor(tx.type);

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: amountColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelFor(tx),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                if (tx.projectTitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tx.projectTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: mutedColor,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  _relativeDate(tx.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${positive ? "+" : "−"}${formatCurrencyBrl(tx.amount)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(WalletTransactionType t) {
    switch (t) {
      case WalletTransactionType.deposit:
        return Icons.add;
      case WalletTransactionType.escrowLock:
        return Icons.lock_outline;
      case WalletTransactionType.escrowRelease:
        return Icons.check_circle_outline;
    }
  }

  static String _labelFor(WalletTransaction tx) {
    switch (tx.type) {
      case WalletTransactionType.deposit:
        return 'Depósito (demo)';
      case WalletTransactionType.escrowLock:
        return 'Valor bloqueado em contrato';
      case WalletTransactionType.escrowRelease:
        return tx.balanceDelta > 0
            ? 'Recebimento de ${tx.counterpartyName.isEmpty ? "contrato" : tx.counterpartyName}'
            : 'Pagamento liberado para ${tx.counterpartyName.isEmpty ? "freelancer" : tx.counterpartyName}';
    }
  }

  static String _relativeDate(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inDays >= 30) {
      final m = (diff.inDays / 30).floor();
      return m == 1 ? 'há 1 mês' : 'há $m meses';
    }
    if (diff.inDays >= 1) {
      return diff.inDays == 1 ? 'há 1 dia' : 'há ${diff.inDays} dias';
    }
    if (diff.inHours >= 1) {
      return diff.inHours == 1 ? 'há 1h' : 'há ${diff.inHours}h';
    }
    if (diff.inMinutes >= 1) {
      return 'há ${diff.inMinutes}min';
    }
    return 'agora';
  }
}

class _DepositSheet extends StatefulWidget {
  const _DepositSheet();

  @override
  State<_DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<_DepositSheet> {
  static const _options = [100.0, 500.0, 1000.0, 5000.0];
  double? _selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _slate800 : Colors.white;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final canSubmit = _selected != null;

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
              Text(
                'Adicionar fundos',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Modo demonstração — sem cobrança real. Escolha um valor pra '
                'simular o crédito na carteira.',
                style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _options
                    .map((v) => _AmountChip(
                          value: v,
                          selected: _selected == v,
                          onTap: () => setState(() => _selected = v),
                          isDark: isDark,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canSubmit
                      ? () => Navigator.of(context).pop(_selected)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primary.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(
                    canSubmit
                        ? 'Confirmar depósito de ${formatCurrencyBrl(_selected!)}'
                        : 'Selecione um valor',
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: mutedColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.value,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final double value;
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
    final fg = selected ? Colors.white : (isDark ? Colors.white : _slate900);
    final border = selected
        ? _primary
        : (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : _primary.withValues(alpha: 0.15));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Text(
          formatCurrencyBrl(value),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}
