import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/contract.dart';

const _primary = Color(0xFF3B309E);
const _slate900 = Color(0xFF0F172A);
const _slate500 = Color(0xFF64748B);
const _slate800 = Color(0xFF1E293B);

/// Formata `R$ 3.000` (ou `R$ 80/h` quando isHourly).
String formatContractValue(double value, bool isHourly) {
  final intPart = value.truncate();
  final buf = StringBuffer('R\$ ');
  final str = intPart.toString();
  for (var i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
    buf.write(str[i]);
  }
  if (isHourly) buf.write('/h');
  return buf.toString();
}

/// "iniciado há 1 dia" / "iniciado agora" — usado nos cards e timeline.
String relativeContractDate(DateTime createdAt, {String prefix = 'iniciado'}) {
  final diff = DateTime.now().difference(createdAt);
  if (diff.inDays >= 1) {
    final d = diff.inDays;
    return d == 1 ? '$prefix há 1 dia' : '$prefix há $d dias';
  }
  if (diff.inHours >= 1) {
    final h = diff.inHours;
    return h == 1 ? '$prefix há 1 hora' : '$prefix há $h horas';
  }
  if (diff.inMinutes >= 1) {
    final m = diff.inMinutes;
    return m == 1 ? '$prefix há 1 minuto' : '$prefix há $m minutos';
  }
  return '$prefix agora';
}

class ContractStatusBadge extends StatelessWidget {
  const ContractStatusBadge({super.key, required this.status, this.large = false});

  final ContractStatus status;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: spec.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        spec.label,
        style: GoogleFonts.inter(
          fontSize: large ? 13 : 11,
          fontWeight: FontWeight.w700,
          color: spec.fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static _BadgeSpec _specFor(ContractStatus s) {
    switch (s) {
      case ContractStatus.active:
        return const _BadgeSpec(
          label: 'Em andamento',
          bg: Color(0xFFE0E7FF),
          fg: Color(0xFF3B309E),
        );
      case ContractStatus.delivered:
        return const _BadgeSpec(
          label: 'Entregue',
          bg: Color(0xFFFFF4DC),
          fg: Color(0xFF92571A),
        );
      case ContractStatus.revisionRequested:
        return const _BadgeSpec(
          label: 'Revisão pedida',
          bg: Color(0xFFFFE4E0),
          fg: Color(0xFFC2410C),
        );
      case ContractStatus.completed:
        return const _BadgeSpec(
          label: 'Concluído',
          bg: Color(0xFFD8F5E9),
          fg: Color(0xFF086B53),
        );
      case ContractStatus.disputed:
        return const _BadgeSpec(
          label: 'Em disputa',
          bg: Color(0xFFFADBDB),
          fg: Color(0xFFBA1A1A),
        );
    }
  }
}

class _BadgeSpec {
  const _BadgeSpec({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;
}

/// Viewer fullscreen com pinch-to-zoom pra fotos da entrega.
class ContractPhotoFullscreenView extends StatelessWidget {
  const ContractPhotoFullscreenView({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
            errorBuilder: (_, _, _) => const Text(
              'Falha ao carregar imagem',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet pra compor a entrega: opcionalmente anexa fotos antes de
/// confirmar. Pop com `null` = cancelou, pop com lista (possivelmente vazia)
/// = confirmou.
class DeliveryComposerSheet extends StatefulWidget {
  const DeliveryComposerSheet({super.key, this.isResubmit = false});

  final bool isResubmit;

  @override
  State<DeliveryComposerSheet> createState() => _DeliveryComposerSheetState();
}

class _DeliveryComposerSheetState extends State<DeliveryComposerSheet> {
  static const _maxPhotos = 5;
  final _picker = ImagePicker();
  final List<File> _photos = [];

  Future<void> _pickFromCamera() async {
    if (_photos.length >= _maxPhotos) return;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked == null || !mounted) return;
      setState(() => _photos.add(File(picked.path)));
    } catch (e) {
      if (!mounted) return;
      _showError('Não foi possível abrir a câmera: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_photos.length >= _maxPhotos) return;
    try {
      final remaining = _maxPhotos - _photos.length;
      final picked = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        limit: remaining,
      );
      if (picked.isEmpty || !mounted) return;
      setState(() => _photos.addAll(picked.map((x) => File(x.path))));
    } catch (e) {
      if (!mounted) return;
      _showError('Não foi possível abrir a galeria: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFBA1A1A),
        content: Text(message, style: GoogleFonts.inter(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _slate800 : Colors.white;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final atLimit = _photos.length >= _maxPhotos;

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
                widget.isResubmit ? 'Reenviar entrega' : 'Confirmar entrega',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isResubmit
                    ? 'Anexe as novas fotos do trabalho ajustado. Até $_maxPhotos imagens.'
                    : 'Anexe fotos do trabalho (opcional). Até $_maxPhotos imagens.',
                style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
              ),
              const SizedBox(height: 16),
              if (_photos.isNotEmpty) ...[
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => _ThumbWithRemove(
                      file: _photos[i],
                      onRemove: () => setState(() => _photos.removeAt(i)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: atLimit ? null : _pickFromCamera,
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Câmera'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: BorderSide(
                          color: _primary.withValues(
                            alpha: atLimit ? 0.3 : 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: atLimit ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Galeria'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: BorderSide(
                          color: _primary.withValues(
                            alpha: atLimit ? 0.3 : 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_photos),
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
                  child: Text(
                    _photos.isEmpty
                        ? (widget.isResubmit
                            ? 'Reenviar sem fotos'
                            : 'Confirmar sem fotos')
                        : (widget.isResubmit
                            ? 'Reenviar entrega (${_photos.length})'
                            : 'Confirmar entrega (${_photos.length})'),
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

class _ThumbWithRemove extends StatelessWidget {
  const _ThumbWithRemove({required this.file, required this.onRemove});

  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            file,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFFBA1A1A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet pra capturar o motivo da revisão. Pop com `null` = cancelou,
/// pop com a string trimmed = confirmou. Valida tamanho client-side; o
/// server revalida 10..500 chars.
class RevisionReasonSheet extends StatefulWidget {
  const RevisionReasonSheet({super.key});

  @override
  State<RevisionReasonSheet> createState() => _RevisionReasonSheetState();
}

class _RevisionReasonSheetState extends State<RevisionReasonSheet> {
  static const _minChars = 10;
  static const _maxChars = 500;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _slate800 : Colors.white;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final inputBorder = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : const Color(0xFFE2E8F0);

    final trimmed = _controller.text.trim();
    final canSubmit = trimmed.length >= _minChars;

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
                'Solicitar revisão',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Descreva os ajustes que o freelancer precisa fazer. '
                'Mínimo $_minChars caracteres.',
                style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                maxLines: 5,
                minLines: 4,
                maxLength: _maxChars,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.inter(fontSize: 14, color: titleColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFFBF9F2),
                  hintText: 'Ex.: A paleta de cores está fora do brief — '
                      'usar o roxo da marca em vez do azul.',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: mutedColor.withValues(alpha: 0.7),
                  ),
                  counterStyle:
                      GoogleFonts.inter(fontSize: 11, color: mutedColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFC2410C),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      canSubmit ? () => Navigator.of(context).pop(trimmed) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC2410C),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFC2410C).withValues(alpha: 0.4),
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
                        ? 'Enviar solicitação'
                        : 'Faltam ${(_minChars - trimmed.length).clamp(0, _minChars)} caracteres',
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
