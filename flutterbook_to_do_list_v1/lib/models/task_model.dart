class Task {
  final String id;
  final String description;
  final DateTime dueDate;

  Task({required this.id, required this.description, required this.dueDate});

  Task copyWith({String? id, String? description, DateTime? dueDate}) {
    return Task(
      id: id ?? this.id,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
