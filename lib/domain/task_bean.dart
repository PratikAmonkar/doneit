class TaskBean {
  final String id;
  final String title;
  final String? priority;
  final String created;
  final String? updated;
  final int? todosDoneCount;
  final int? totalTodosCount;
  final String? notificationId;

  TaskBean({
    required this.id,
    required this.title,
    this.priority = "Low",
    required this.created,
    this.updated,
    this.todosDoneCount,
    this.totalTodosCount,
    this.notificationId,
  });

  TaskBean copyWith({
    String? id,
    String? title,
    String? priority,
    String? created,
    String? updated,
    int? todosDoneCount,
    int? totalTodosCount,
    String? notificationId,
  }) {
    return TaskBean(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      todosDoneCount: todosDoneCount ?? this.todosDoneCount,
      totalTodosCount: totalTodosCount ?? this.totalTodosCount,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  factory TaskBean.fromJson(Map<String, dynamic> json) {
    return TaskBean(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: json['priority'] as String?,
      created: json['created'] as String,
      updated: json['updated'] as String?,
      todosDoneCount: json['total_todos_done'] ?? 0,
      totalTodosCount: json['total_todos_count'] ?? 0,
      notificationId: json['notification_id'] ?? "-1",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'created': created,
      'updated': updated,
      'total_todos_done': todosDoneCount,
      'total_todos_count': totalTodosCount,
      'notification_id': notificationId,
    };
  }
}
