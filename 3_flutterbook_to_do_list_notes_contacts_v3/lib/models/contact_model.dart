class Contact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? avatarPath;
  final DateTime? birthday;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.avatarPath,
    this.birthday,
  });

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarPath,
    DateTime? birthday,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      birthday: birthday ?? this.birthday,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatarPath': avatarPath,
      'birthday': birthday?.millisecondsSinceEpoch,
    };
  }

  factory Contact.fromMap(Map<String, Object?> map) {
    return Contact(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      avatarPath: map['avatarPath'] as String?,
      birthday:
          map['birthday'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['birthday'] as int)
              : null,
    );
  }
}
