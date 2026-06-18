import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/auth_service.dart';
import '../core/services/contracts_service.dart';
import '../models/contract.dart';
import '../models/user_role.dart';
import '../widgets/contract_widgets.dart';
import 'contract_detail_view.dart';

const _primary = Color(0xFF3B309E);
const _surfaceCream = Color(0xFFFBF9F2);
const _slate900 = Color(0xFF0F172A);
const _slate500 = Color(0xFF64748B);
const _slate800 = Color(0xFF1E293B);
const _bgDark = Color(0xFF0B1020);

class MyContractsView extends StatefulWidget {
  const MyContractsView({super.key});

  @override
  State<MyContractsView> createState() => _MyContractsViewState();
}

class _MyContractsViewState extends State<MyContractsView> {
  Stream<List<Contract>>? _stream;
  UserRole? _role;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  Future<void> _initStream() async {
    if (Firebase.apps.isEmpty) {
      setState(() {
        _stream = Stream<List<Contract>>.value(const []);
        _role = UserRole.freelancer;
      });
      return;
    }
    try {
      final user = await AuthService.instance.currentAppUser();
      if (!mounted) return;
      if (user == null) {
        setState(() => _loadError = 'Sessão expirada. Faça login novamente.');
        return;
      }
      setState(() {
        _role = user.role;
        _stream = user.role == UserRole.freelancer
            ? ContractsService.instance.streamContractsByFreelancer(user.uid)
            : ContractsService.instance.streamContractsByClient(user.uid);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'Falha ao carregar contratos: $e');
    }
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _loadError = null);
    await _initStream();
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  void _openDetail(Contract c) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContractDetailView(contractId: c.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _surfaceCream;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final cardBg = isDark ? _slate800 : Colors.white;

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
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(titleColor: titleColor),
              Expanded(
                child: _buildContent(titleColor, mutedColor, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color titleColor, Color mutedColor, bool isDark) {
    if (_loadError != null) {
      return RefreshIndicator(
        color: _primary,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _StateMessage(
                icon: Icons.error_outline,
                title: 'Erro',
                message: _loadError!,
                titleColor: titleColor,
                mutedColor: mutedColor,
              ),
            ),
          ],
        ),
      );
    }
    if (_stream == null) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    return RefreshIndicator(
      color: _primary,
      onRefresh: _refresh,
      child: StreamBuilder<List<Contract>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }
          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: _StateMessage(
                    icon: Icons.error_outline,
                    title: 'Erro',
                    message: '${snapshot.error}',
                    titleColor: titleColor,
                    mutedColor: mutedColor,
                  ),
                ),
              ],
            );
          }
          final contracts = snapshot.data ?? const <Contract>[];
          if (contracts.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: _StateMessage(
                    icon: Icons.assignment_outlined,
                    title: 'Nenhum contrato ainda',
                    message: _role == UserRole.client
                        ? 'Quando você aceitar propostas, os contratos aparecem aqui.'
                        : 'Quando um cliente aceitar uma de suas propostas, o contrato aparece aqui.',
                    titleColor: titleColor,
                    mutedColor: mutedColor,
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: contracts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ContractCard(
              contract: contracts[i],
              viewerRole: _role ?? UserRole.freelancer,
              isDark: isDark,
              titleColor: titleColor,
              mutedColor: mutedColor,
              onTap: () => _openDetail(contracts[i]),
            ),
          );
        },
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
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
                  'Meus contratos',
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

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.titleColor,
    required this.mutedColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: mutedColor),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
          ),
        ],
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  const _ContractCard({
    required this.contract,
    required this.viewerRole,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.onTap,
  });

  final Contract contract;
  final UserRole viewerRole;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _slate800 : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);

    final counterpartyLabel =
        viewerRole == UserRole.client ? 'Freelancer' : 'Cliente';
    final rawCounterpartyName = viewerRole == UserRole.client
        ? contract.freelancerName
        : contract.clientName;
    final counterpartyName = rawCounterpartyName.isEmpty
        ? counterpartyLabel
        : rawCounterpartyName;

    final photoCount = contract.deliveryPhotoUrls.length;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      contract.projectTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ContractStatusBadge(status: contract.status),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Meta(
                    icon: Icons.attach_money,
                    label: formatContractValue(
                      contract.value,
                      contract.isHourly,
                    ),
                    color: mutedColor,
                  ),
                  const SizedBox(width: 14),
                  _Meta(
                    icon: Icons.event_outlined,
                    label: contract.daysEstimate == 1
                        ? '1 dia'
                        : '${contract.daysEstimate} dias',
                    color: mutedColor,
                  ),
                  if (photoCount > 0) ...[
                    const SizedBox(width: 14),
                    _Meta(
                      icon: Icons.attach_file_outlined,
                      label: photoCount == 1
                          ? '1 anexo'
                          : '$photoCount anexos',
                      color: mutedColor,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: mutedColor),
                  const SizedBox(width: 4),
                  Text(
                    '$counterpartyLabel: ',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: mutedColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      counterpartyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: mutedColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                relativeContractDate(contract.createdAt),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: mutedColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
