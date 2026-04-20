class TaskCategory {
  final String id;
  final String name;
  final String colorHex;

  TaskCategory({
    required this.id,
    required this.name,
    this.colorHex = '#3F51B5', // Default Indigo
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
    };
  }

  factory TaskCategory.fromMap(Map<String, dynamic> map) {
    return TaskCategory(
      id: map['id'],
      name: map['name'],
      colorHex: map['colorHex'],
    );
  }
}

class TaskItem {
  final String id;
  final String name;
  final String? description;
  final String categoryId;
  final DateTime? deadline;
  final String priority; // 'Low', 'Medium', 'High'
  final bool isCompleted;
  final DateTime createdAt;

  TaskItem({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    this.deadline,
    required this.priority,
    this.isCompleted = false,
    required this.createdAt,
  });

  TaskItem copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    DateTime? deadline,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'deadline': deadline?.millisecondsSinceEpoch,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      categoryId: map['categoryId'],
      deadline: map['deadline'] != null ? DateTime.fromMillisecondsSinceEpoch(map['deadline']) : null,
      priority: map['priority'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}
