class Appointment {
  final String id;
  final String title;
  final String description;
  final DateTime date;

  Appointment({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  Appointment copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Appointment.fromMap(Map<String, Object?> map) {
    return Appointment(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }
}
