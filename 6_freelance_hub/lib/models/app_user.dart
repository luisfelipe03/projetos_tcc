import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? photoUrl;
}
