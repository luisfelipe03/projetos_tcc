import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/auth_service.dart';
import '../core/services/messages_service.dart';
import '../models/chat_thread.dart';
import 'chat_view.dart';
import 'public_profile_view.dart';

const _primary = Color(0xFF3B309E);
const _surfaceCream = Color(0xFFFBF9F2);
const _slate900 = Color(0xFF0F172A);
const _slate500 = Color(0xFF64748B);
const _slate800 = Color(0xFF1E293B);
const _bgDark = Color(0xFF0B1020);

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  Stream<List<ChatThread>>? _stream;
  String? _uid;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  Future<void> _initStream() async {
    if (Firebase.apps.isEmpty) {
      setState(() => _stream = Stream<List<ChatThread>>.value(const []));
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
        _uid = user.uid;
        _stream = MessagesService.instance.streamThreadsByUser(user.uid);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'Falha ao carregar mensagens: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _surfaceCream;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;

    return Container(
      color: bg,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(titleColor: titleColor, mutedColor: mutedColor),
          ),
          if (_loadError != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _StateMessage(
                icon: Icons.error_outline,
                title: 'Erro',
                message: _loadError!,
                titleColor: titleColor,
                mutedColor: mutedColor,
              ),
            )
          else if (_stream == null)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator(color: _primary)),
            )
          else
            StreamBuilder<List<ChatThread>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: _primary),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _StateMessage(
                      icon: Icons.error_outline,
                      title: 'Erro',
                      message: '${snapshot.error}',
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                    ),
                  );
                }
                final threads = snapshot.data ?? const <ChatThread>[];
                if (threads.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _StateMessage(
                      icon: Icons.chat_bubble_outline,
                      title: 'Nenhuma conversa ainda',
                      message:
                          'Inicie um chat tocando em "Mensagem" no card de um '
                          'contrato em "Meus contratos".',
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                    ),
                  );
                }
                final uid = _uid ?? '';
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: threads.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ThreadCard(
                      thread: threads[i],
                      viewerUid: uid,
                      isDark: isDark,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.titleColor, required this.mutedColor});

  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mensagens',
            style: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Suas conversas com clientes e freelancers.',
            style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
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

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({
    required this.thread,
    required this.viewerUid,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
  });

  final ChatThread thread;
  final String viewerUid;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _slate800 : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);

    final otherName = thread.otherName(viewerUid);
    final otherUid = thread.otherUid(viewerUid);
    final youSent = thread.lastMessageSenderId == viewerUid;
    final preview = thread.lastMessageText.isEmpty
        ? 'Sem mensagens.'
        : (youSent ? 'Você: ${thread.lastMessageText}' : thread.lastMessageText);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatView(
            otherUid: otherUid,
            otherName: otherName,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: otherUid.isEmpty
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PublicProfileView(uid: otherUid),
                        ),
                      ),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(otherName),
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _relativeTime(thread.lastMessageAt),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: mutedColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  static String _relativeTime(DateTime? at) {
    if (at == null) return '';
    final diff = DateTime.now().difference(at);
    if (diff.inDays >= 7) {
      return '${(diff.inDays / 7).floor()}sem';
    }
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}min';
    return 'agora';
  }
}
