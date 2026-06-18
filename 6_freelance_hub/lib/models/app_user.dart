import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoUrl,
    this.ratingTotal = 0,
    this.ratingCount = 0,
  });

  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? photoUrl;
  final int ratingTotal;
  final int ratingCount;

  /// Média 1-5; null se ainda não houver avaliação.
  double? get ratingAverage {
    if (ratingCount == 0) return null;
    return ratingTotal / ratingCount;
  }
}
