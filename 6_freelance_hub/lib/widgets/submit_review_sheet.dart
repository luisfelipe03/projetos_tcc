import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'rating_stars.dart';

const _primary = Color(0xFF3B309E);
const _slate900 = Color(0xFF0F172A);
const _slate500 = Color(0xFF64748B);
const _slate800 = Color(0xFF1E293B);

class ReviewDraft {
  const ReviewDraft({required this.rating, required this.comment});
  final int rating;
  final String comment;
}

/// Bottom sheet pra coletar rating (1-5) + comentário opcional. Pop com
/// [ReviewDraft] = confirmou, null = cancelou.
class SubmitReviewSheet extends StatefulWidget {
  const SubmitReviewSheet({super.key, required this.revieweeName});

  final String revieweeName;

  @override
  State<SubmitReviewSheet> createState() => _SubmitReviewSheetState();
}

class _SubmitReviewSheetState extends State<SubmitReviewSheet> {
  static const _maxChars = 500;
  int _rating = 0;
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

  void _setRating(int v) => setState(() => _rating = v);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _slate800 : Colors.white;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final inputBorder = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : const Color(0xFFE2E8F0);
    final canSubmit = _rating > 0;

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
                'Avaliar ${widget.revieweeName}',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sua avaliação é pública e ajuda outros usuários a decidirem '
                'em quem confiar.',
                style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
              ),
              const SizedBox(height: 18),
              Center(
                child: RatingStars(
                  value: _rating,
                  interactive: true,
                  onChanged: _setRating,
                  size: 36,
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  _rating == 0
                      ? 'Toque nas estrelas pra avaliar'
                      : _labelFor(_rating),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: mutedColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 3,
                maxLength: _maxChars,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.inter(fontSize: 14, color: titleColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFFBF9F2),
                  hintText:
                      'Comentário (opcional): conte como foi a experiência…',
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
                    borderSide:
                        const BorderSide(color: _primary, width: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canSubmit
                      ? () => Navigator.of(context).pop(
                            ReviewDraft(
                              rating: _rating,
                              comment: _controller.text.trim(),
                            ),
                          )
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        _primary.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(canSubmit ? 'Enviar avaliação' : 'Escolha as estrelas'),
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

  static String _labelFor(int rating) {
    switch (rating) {
      case 1:
        return 'Péssimo';
      case 2:
        return 'Ruim';
      case 3:
        return 'Razoável';
      case 4:
        return 'Bom';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }
}
