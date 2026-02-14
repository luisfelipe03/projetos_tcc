import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthViewModel() {
    // Listener para mudanças de estado de autenticação
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Valida o formato do email
  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email';
    }

    return null;
  }

  /// Valida a senha
  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Registra um novo usuário com email e senha
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;

      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'The password is too weak';
          break;
        case 'email-already-in-use':
          _errorMessage = 'An account already exists for this email';
          break;
        case 'invalid-email':
          _errorMessage = 'The email address is invalid';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          _errorMessage = 'An error occurred during sign up: ${e.message}';
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  /// Faz login com email e senha
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;

      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'No user found for this email';
          break;
        case 'wrong-password':
          _errorMessage = 'Wrong password';
          break;
        case 'invalid-email':
          _errorMessage = 'The email address is invalid';
          break;
        case 'user-disabled':
          _errorMessage = 'This user account has been disabled';
          break;
        case 'invalid-credential':
          _errorMessage = 'Invalid email or password';
          break;
        default:
          _errorMessage = 'An error occurred during sign in: ${e.message}';
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  /// Faz logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Faz login com Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Inicia o fluxo de autenticação do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // O usuário cancelou o login
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Obtém os detalhes de autenticação da solicitação
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Cria uma nova credencial
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Faz login no Firebase com a credencial do Google
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;

      switch (e.code) {
        case 'account-exists-with-different-credential':
          _errorMessage =
              'An account already exists with the same email but different sign-in credentials';
          break;
        case 'invalid-credential':
          _errorMessage = 'The credential is malformed or has expired';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Google sign-in is not enabled';
          break;
        case 'user-disabled':
          _errorMessage = 'This user account has been disabled';
          break;
        case 'user-not-found':
          _errorMessage = 'No user found with this credential';
          break;
        case 'wrong-password':
          _errorMessage = 'Wrong password';
          break;
        default:
          _errorMessage =
              'An error occurred during Google sign in: ${e.message}';
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  /// Limpa a mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
