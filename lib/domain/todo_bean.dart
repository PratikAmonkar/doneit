class TodoBean {
  final String id;
  final String taskId;
  final bool isDone;
  final String title;
  final String created;
  final String? updated;

  TodoBean({
    required this.id,
    required this.taskId,
    required this.isDone,
    required this.created,
    required this.title,
    this.updated,
  });

  TodoBean copyWith({
    String? id,
    String? taskId,
    bool? isDone,
    String? created,
    String? updated,
    String? title,
  }) {
    return TodoBean(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      isDone: isDone ?? this.isDone,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      title: title ?? this.title,
    );
  }

  factory TodoBean.fromJson(Map<String, dynamic> json) {
    return TodoBean(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      isDone: (json['is_done'] as int) == 1,
      created: json['created'] as String,
      updated: json['updated'] as String?,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'is_done': isDone ? 1 : 0,
      'created': created,
      'updated': updated,
      'title': title,
    };
  }
}
