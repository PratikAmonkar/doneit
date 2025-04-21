class TaskBean {
  final String id;
  final String title;
  final String priority;
  final String created;
  final String? updated;
  final int? todosCount;

  TaskBean({
    required this.id,
    required this.title,
    required this.priority,
    required this.created,
    this.updated,
    this.todosCount,
  });

  TaskBean copyWith({
    String? id,
    String? title,
    String? priority,
    String? created,
    String? updated,
    int? todosCount,
  }) {
    return TaskBean(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      todosCount: todosCount ?? this.todosCount,
    );
  }

  factory TaskBean.fromJson(Map<String, dynamic> json) {
    return TaskBean(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: json['priority'] as String,
      created: json['created'] as String,
      updated: json['updated'] as String?,
      todosCount: json['completedTodosCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'created': created,
      'updated': updated,
    };
  }
}
