import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/app_user.dart';
import '../../models/user_role.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(displayName);
    final uid = user.uid;
    await _usersCollection.doc(uid).set({
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      role: role,
    );
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _loadUser(cred.user!.uid);
  }

  Future<AppUser?> currentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _loadUser(user.uid);
  }

  /// Carrega o perfil público de qualquer usuário (pra PublicProfileView).
  /// Retorna `null` se o doc não existir (user deletado ou uid inválido).
  Future<AppUser?> fetchUser(String uid) async {
    try {
      return await _loadUser(uid);
    } on StateError {
      return null;
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<AppUser> _loadUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) {
      throw StateError('Documento de usuário não encontrado para uid $uid.');
    }
    final data = doc.data()!;
    final photoUrl = data['photoUrl'] as String?;
    return AppUser(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == (data['role'] as String?),
        orElse: () => UserRole.freelancer,
      ),
      photoUrl: (photoUrl == null || photoUrl.isEmpty) ? null : photoUrl,
      ratingTotal: (data['ratingTotal'] as num?)?.toInt() ?? 0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Atualiza nome e/ou foto do usuário no doc `users/{uid}`.
  /// O server tem um trigger `onUserUpdated` que propaga o displayName novo
  /// pra denormalizações (threads, contracts, proposals) automaticamente.
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) {
      updates['displayName'] = displayName;
    }
    if (photoUrl != null) {
      updates['photoUrl'] = photoUrl;
    }
    if (updates.isEmpty) return;
    await _usersCollection.doc(uid).update(updates);
  }

  String mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Conta desativada.';
      case 'user-not-found':
        return 'E-mail não cadastrado.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'weak-password':
        return 'Senha muito fraca (mínimo 6 caracteres).';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns instantes.';
      case 'network-request-failed':
        return 'Sem conexão. Verifique sua internet.';
      default:
        return e.message ?? 'Falha na autenticação (${e.code}).';
    }
  }
}
