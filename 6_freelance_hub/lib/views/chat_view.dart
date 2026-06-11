import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/auth_service.dart';
import '../core/services/messages_service.dart';
import '../models/chat_message.dart';

const _primary = Color(0xFF3B309E);
const _surfaceCream = Color(0xFFFBF9F2);
const _slate900 = Color(0xFF0F172A);
const _slate500 = Color(0xFF64748B);
const _slate800 = Color(0xFF1E293B);
const _bgDark = Color(0xFF0B1020);

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    required this.otherUid,
    required this.otherName,
  });

  final String otherUid;
  final String otherName;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  Stream<List<ChatMessage>>? _stream;
  String? _viewerUid;
  String? _loadError;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() => setState(() {}));
    _initStream();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initStream() async {
    if (Firebase.apps.isEmpty) {
      setState(() => _stream = Stream<List<ChatMessage>>.value(const []));
      return;
    }
    try {
      final user = await AuthService.instance.currentAppUser();
      if (!mounted) return;
      if (user == null) {
        setState(() => _loadError = 'Sessão expirada. Faça login novamente.');
        return;
      }
      final threadId =
          MessagesService.threadIdFor(user.uid, widget.otherUid);
      setState(() {
        _viewerUid = user.uid;
        _stream = MessagesService.instance.streamMessages(threadId);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'Falha ao carregar mensagens: $e');
    }
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await MessagesService.instance.sendMessage(
        receiverId: widget.otherUid,
        text: text,
      );
      if (!mounted) return;
      _textController.clear();
    } catch (e) {
      if (!mounted) return;
      _showSnack(_humanizeError(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _humanizeError(Object e) {
    if (e is FirebaseFunctionsException) {
      switch (e.code) {
        case 'unauthenticated':
          return 'Sessão expirada. Faça login novamente.';
        case 'invalid-argument':
          return e.message ?? 'Mensagem inválida.';
        case 'not-found':
          return 'Destinatário não encontrado.';
        default:
          return 'Falha ao enviar: ${e.message ?? e.code}';
      }
    }
    return 'Falha ao enviar: $e';
  }

  void _showSnack(String message) {
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
              _TopBar(titleColor: titleColor, name: widget.otherName),
              Expanded(
                child: _buildMessages(titleColor, mutedColor, isDark),
              ),
              _InputBar(
                controller: _textController,
                onSend: _handleSend,
                sending: _sending,
                cardBg: cardBg,
                titleColor: titleColor,
                mutedColor: mutedColor,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessages(Color titleColor, Color mutedColor, bool isDark) {
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _loadError!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
          ),
        ),
      );
    }
    if (_stream == null) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    return StreamBuilder<List<ChatMessage>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Erro: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
              ),
            ),
          );
        }
        final messages = snapshot.data ?? const <ChatMessage>[];
        if (messages.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_outlined, size: 48, color: mutedColor),
                const SizedBox(height: 12),
                Text(
                  'Comece a conversa',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sua mensagem aparece aqui assim que você enviar.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
                ),
              ],
            ),
          );
        }
        final viewer = _viewerUid ?? '';
        return ListView.separated(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          itemCount: messages.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _MessageBubble(
            message: messages[i],
            isMine: messages[i].senderId == viewer,
            isDark: isDark,
            mutedColor: mutedColor,
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.titleColor, required this.name});

  final Color titleColor;
  final String name;

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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(name),
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name.isEmpty ? 'Conversa' : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: titleColor,
              ),
            ),
          ),
        ],
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
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.isDark,
    required this.mutedColor,
  });

  final ChatMessage message;
  final bool isMine;
  final bool isDark;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine
        ? _primary
        : (isDark ? _slate800 : Colors.white);
    final textColor = isMine
        ? Colors.white
        : (isDark ? Colors.white : _slate900);
    final borderColor = isMine
        ? Colors.transparent
        : (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : _primary.withValues(alpha: 0.10));

    return Row(
      mainAxisAlignment:
          isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMine ? 16 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 16),
              ),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textColor,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isMine
                        ? Colors.white.withValues(alpha: 0.7)
                        : mutedColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.sending,
    required this.cardBg,
    required this.titleColor,
    required this.mutedColor,
    required this.isDark,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;
  final Color cardBg;
  final Color titleColor;
  final Color mutedColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;
    final inputBorder = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : _primary.withValues(alpha: 0.10);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: inputBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 120,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFFBF9F2),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: inputBorder),
                  ),
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 5,
                    maxLength: 2000,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    style:
                        GoogleFonts.inter(fontSize: 14, color: titleColor),
                    decoration: InputDecoration(
                      hintText: 'Mensagem',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: mutedColor.withValues(alpha: 0.7),
                      ),
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 44,
                height: 44,
                child: Material(
                  color: hasText && !sending
                      ? _primary
                      : _primary.withValues(alpha: 0.4),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: (hasText && !sending) ? onSend : null,
                    child: Center(
                      child: sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
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
