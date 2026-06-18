import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/auth_service.dart';
import '../core/services/reviews_service.dart';
import '../models/app_user.dart';
import '../models/review.dart';
import '../widgets/rating_stars.dart';
import 'chat_view.dart';

const _primary = Color(0xFF3B309E);
const _surfaceCream = Color(0xFFFBF9F2);
const _slate900 = Color(0xFF0F172A);
const _slate500 = Color(0xFF64748B);
const _slate800 = Color(0xFF1E293B);
const _bgDark = Color(0xFF0B1020);

/// Tela de perfil público de qualquer usuário (freelancer ou cliente).
/// Acessível tocando no avatar/nome em ContractDetailView, ChatView,
/// MessagesView, ReceivedProposalsView etc.
class PublicProfileView extends StatefulWidget {
  const PublicProfileView({super.key, required this.uid});

  final String uid;

  @override
  State<PublicProfileView> createState() => _PublicProfileViewState();
}

class _PublicProfileViewState extends State<PublicProfileView> {
  AppUser? _user;
  String? _loadError;
  String? _viewerUid;
  Stream<List<Review>>? _reviewsStream;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (Firebase.apps.isEmpty) {
      setState(() => _loadError = 'Sessão expirada.');
      return;
    }
    try {
      final viewer = FirebaseAuth.instance.currentUser;
      final user = await AuthService.instance.fetchUser(widget.uid);
      if (!mounted) return;
      if (user == null) {
        setState(() => _loadError = 'Usuário não encontrado.');
        return;
      }
      setState(() {
        _user = user;
        _viewerUid = viewer?.uid;
        _reviewsStream =
            ReviewsService.instance.streamReviewsByUser(widget.uid);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'Falha ao carregar perfil: $e');
    }
  }

  void _openChat() {
    final user = _user;
    if (user == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatView(
          otherUid: user.uid,
          otherName:
              user.displayName.isEmpty ? 'Usuário' : user.displayName,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: mutedColor),
              const SizedBox(height: 12),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
              ),
            ],
          ),
        ),
      );
    }
    if (_user == null) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }

    final user = _user!;
    final viewerIsSelf = _viewerUid == user.uid;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Header(
            user: user,
            titleColor: titleColor,
            mutedColor: mutedColor,
            cardBg: cardBg,
            borderColor: borderColor,
            viewerIsSelf: viewerIsSelf,
            onOpenChat: _openChat,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Avaliações recebidas',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ),
        ),
        StreamBuilder<List<Review>>(
          stream: _reviewsStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
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
                    'Erro ao carregar avaliações: ${snap.error}',
                    style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
                  ),
                ),
              );
            }
            final reviews = snap.data ?? const <Review>[];
            if (reviews.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_outline_rounded,
                            size: 32, color: mutedColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nenhuma avaliação ainda. As avaliações aparecem '
                            'aqui depois de contratos concluídos.',
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
                itemCount: reviews.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _ReviewCard(
                  review: reviews[i],
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
  const _Header({
    required this.user,
    required this.titleColor,
    required this.mutedColor,
    required this.cardBg,
    required this.borderColor,
    required this.viewerIsSelf,
    required this.onOpenChat,
  });

  final AppUser user;
  final Color titleColor;
  final Color mutedColor;
  final Color cardBg;
  final Color borderColor;
  final bool viewerIsSelf;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    final avg = user.ratingAverage;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: Icon(Icons.arrow_back, color: titleColor),
                style: IconButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: _BigAvatar(
              name: user.displayName,
              photoUrl: user.photoUrl,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              user.displayName.isEmpty ? 'Usuário' : user.displayName,
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: titleColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.displayName,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (avg != null) ...[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingStars(value: avg.round(), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${avg.toStringAsFixed(1)} '
                    '(${user.ratingCount} '
                    '${user.ratingCount == 1 ? "avaliação" : "avaliações"})',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Center(
              child: Text(
                'Sem avaliações ainda',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: mutedColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (!viewerIsSelf) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenChat,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Enviar mensagem'),
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
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BigAvatar extends StatelessWidget {
  const _BigAvatar({required this.name, required this.photoUrl});

  final String name;
  final String? photoUrl;

  static const _size = 110.0;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: _size,
          height: _size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initialsFallback(),
        ),
      );
    }
    return _initialsFallback();
  }

  Widget _initialsFallback() {
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _primary.withValues(alpha: 0.18),
        border: Border.all(color: _primary, width: 2),
      ),
      child: Text(
        _initialsOf(name),
        style: GoogleFonts.dmSans(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: _primary,
        ),
      ),
    );
  }

  static String _initialsOf(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.cardBg,
    required this.titleColor,
    required this.mutedColor,
    required this.borderColor,
  });

  final Review review;
  final Color cardBg;
  final Color titleColor;
  final Color mutedColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingStars(value: review.rating, size: 16),
                    const SizedBox(height: 4),
                    Text(
                      review.reviewerName.isEmpty
                          ? 'Usuário'
                          : review.reviewerName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _relativeDate(review.createdAt),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: mutedColor,
                ),
              ),
            ],
          ),
          if (review.projectTitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.projectTitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: mutedColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: titleColor,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _relativeDate(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inDays >= 30) {
      final m = (diff.inDays / 30).floor();
      return m == 1 ? 'há 1 mês' : 'há $m meses';
    }
    if (diff.inDays >= 7) {
      final w = (diff.inDays / 7).floor();
      return w == 1 ? 'há 1 sem.' : 'há $w sem.';
    }
    if (diff.inDays >= 1) {
      return diff.inDays == 1 ? 'há 1 dia' : 'há ${diff.inDays} dias';
    }
    if (diff.inHours >= 1) {
      return diff.inHours == 1 ? 'há 1h' : 'há ${diff.inHours}h';
    }
    return 'agora';
  }
}
