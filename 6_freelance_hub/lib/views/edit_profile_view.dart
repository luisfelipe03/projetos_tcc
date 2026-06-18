import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../models/app_user.dart';

const _primary = Color(0xFF3B309E);
const _surfaceCream = Color(0xFFFBF9F2);
const _slate900 = Color(0xFF0F172A);
const _slate500 = Color(0xFF64748B);
const _slate200 = Color(0xFFE2E8F0);
const _slate800 = Color(0xFF1E293B);
const _bgDark = Color(0xFF0B1020);
const _errorRed = Color(0xFFBA1A1A);
const _successGreen = Color(0xFF086B53);

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  static const _minNameChars = 2;
  static const _maxNameChars = 60;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _picker = ImagePicker();

  AppUser? _user;
  String? _loadError;
  bool _isSaving = false;
  File? _newPhotoFile;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await AuthService.instance.currentAppUser();
      if (!mounted) return;
      if (user == null) {
        setState(() => _loadError = 'Sessão expirada. Faça login novamente.');
        return;
      }
      setState(() {
        _user = user;
        _nameController.text = user.displayName;
        _currentPhotoUrl = user.photoUrl;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'Falha ao carregar perfil: $e');
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() => _newPhotoFile = File(picked.path));
    } catch (e) {
      if (!mounted) return;
      _showSnack('Falha ao escolher foto: $e', success: false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _user;
    if (user == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      String? newPhotoUrl;
      if (_newPhotoFile != null) {
        newPhotoUrl = await StorageService.instance.uploadProfilePhoto(
          uid: user.uid,
          file: _newPhotoFile!,
        );
      }
      final newName = _nameController.text.trim();
      final nameChanged = newName != user.displayName;
      final photoChanged = newPhotoUrl != null;
      if (!nameChanged && !photoChanged) {
        if (!mounted) return;
        _showSnack('Nada para salvar.', success: false);
        setState(() => _isSaving = false);
        return;
      }
      await AuthService.instance.updateProfile(
        uid: user.uid,
        displayName: nameChanged ? newName : null,
        photoUrl: photoChanged ? newPhotoUrl : null,
      );
      if (!mounted) return;
      _showSnack('Perfil atualizado!', success: true);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Falha ao salvar: $e', success: false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
    final inputBorder = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : _slate200;

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
        appBar: AppBar(
          backgroundColor: bg,
          surfaceTintColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: titleColor),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Editar perfil',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _buildBody(
            cardBg: cardBg,
            titleColor: titleColor,
            mutedColor: mutedColor,
            inputBorder: inputBorder,
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
    required Color inputBorder,
    required bool isDark,
  }) {
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
    if (_user == null) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    final user = _user!;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(child: _avatar(titleColor: titleColor)),
          const SizedBox(height: 14),
          Center(
            child: TextButton.icon(
              onPressed: _isSaving ? null : _pickPhoto,
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: Text(
                _newPhotoFile != null || _currentPhotoUrl != null
                    ? 'Trocar foto'
                    : 'Adicionar foto',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(foregroundColor: _primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nome',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            enabled: !_isSaving,
            maxLength: _maxNameChars,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.inter(fontSize: 14, color: titleColor),
            decoration: InputDecoration(
              hintText: 'Como você quer ser chamado',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: mutedColor.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: cardBg,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
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
                borderSide: const BorderSide(color: _primary, width: 1.4),
              ),
            ),
            validator: (raw) {
              final v = (raw ?? '').trim();
              if (v.length < _minNameChars) {
                return 'Nome muito curto (mínimo $_minNameChars caracteres).';
              }
              if (v.length > _maxNameChars) {
                return 'Nome muito longo.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          _readOnlyField(
            label: 'E-mail',
            value: user.email,
            titleColor: titleColor,
            mutedColor: mutedColor,
            cardBg: cardBg,
            inputBorder: inputBorder,
          ),
          const SizedBox(height: 12),
          _readOnlyField(
            label: 'Tipo de conta',
            value: user.role.displayName,
            titleColor: titleColor,
            mutedColor: mutedColor,
            cardBg: cardBg,
            inputBorder: inputBorder,
          ),
          const SizedBox(height: 6),
          Text(
            'E-mail e tipo de conta não podem ser alterados.',
            style: GoogleFonts.inter(fontSize: 11, color: mutedColor),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _isSaving ? null : _handleSave,
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      'Salvar alterações',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar({required Color titleColor}) {
    final size = 110.0;
    final initials = _initialsOf(_nameController.text.trim().isEmpty
        ? (_user?.displayName ?? '')
        : _nameController.text);
    Widget child;
    if (_newPhotoFile != null) {
      child = Image.file(
        _newPhotoFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      child = Image.network(
        _currentPhotoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initialsAvatar(initials, size),
      );
    } else {
      child = _initialsAvatar(initials, size);
    }
    return GestureDetector(
      onTap: _isSaving ? null : _pickPhoto,
      child: Stack(
        children: [
          ClipOval(child: child),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: _primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsAvatar(String initials, double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: _primary, width: 2),
      ),
      child: Text(
        initials,
        style: GoogleFonts.dmSans(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: _primary,
        ),
      ),
    );
  }

  Widget _readOnlyField({
    required String label,
    required String value,
    required Color titleColor,
    required Color mutedColor,
    required Color cardBg,
    required Color inputBorder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: inputBorder),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: mutedColor,
            ),
          ),
        ),
      ],
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
