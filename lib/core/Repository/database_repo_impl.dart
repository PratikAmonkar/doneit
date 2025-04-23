import 'package:DoneIt/domain/task_bean.dart';
import 'package:DoneIt/domain/todo_bean.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../domain/response_status.dart';
import '../configuration/database_config.dart';

class DatabaseRepository {
  static final _uuid = Uuid();

  static Future<ResponseStatus> getAllTasks() async {
    try {
      final db = await DatabaseConfig.initializeDb();
      final result = await db.rawQuery('''
          SELECT 
            tasks.*,
            COUNT(CASE WHEN todos.is_done = 1 THEN 1 END) AS completedTodosCount,
            COUNT(todos.id) AS totalTodosCount
          FROM tasks
          LEFT JOIN todos ON tasks.id = todos.task_id
          GROUP BY tasks.id
          ORDER BY tasks.created DESC;
        ''');

      return ResponseStatus.onSuccess(result);
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to fetch tasks', statusCode: 500),
      );
    }
  }

  static Future<ResponseStatus> getTaskDetail(String id) async {
    try {
      final db = await DatabaseConfig.initializeDb();
      final result = await db.query('tasks', where: 'id = ?', whereArgs: [id]);

      if (result.isNotEmpty) {
        return ResponseStatus.onSuccess(result.first);
      } else {
        return ResponseStatus.onError(
          ApiErrorDetails(message: 'Task not found', statusCode: 404),
        );
      }
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to fetch task', statusCode: 500),
      );
    }
  }

  static Future<ResponseStatus> createTask(TaskBean taskBean) async {
    try {
      final db = await DatabaseConfig.initializeDb();

      await db.insert('tasks', taskBean.toJson());

      return ResponseStatus.onSuccess(taskBean);
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to create task', statusCode: 500),
      );
    }
  }

  static Future<ResponseStatus> deleteTodo(String todoId) async {
    try {
      final db = await DatabaseConfig.initializeDb();
      final rowsDeleted = await db.delete(
        'todos',
        where: 'id = ?',
        whereArgs: [todoId],
      );

      if (rowsDeleted > 0) {
        return ResponseStatus.onSuccess(todoId);
      } else {
        return ResponseStatus.onError(
          ApiErrorDetails(message: 'Todo not found', statusCode: 404),
        );
      }
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to delete todo', statusCode: 500),
      );
    }
  }

  static Future<ResponseStatus> getTodosByTaskId(String taskId) async {
    try {
      final db = await DatabaseConfig.initializeDb();

      final result = await db.query(
        'todos',
        where: 'task_id = ?',
        whereArgs: [taskId],
      );
      return ResponseStatus.onSuccess(result);
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to fetch todos', statusCode: 500),
      );
    }
  }

  static Future<ResponseStatus> addTodo(TodoBean todoBean) async {
    try {
      final db = await DatabaseConfig.initializeDb();

      await db.insert('todos', todoBean.toJson());

      return ResponseStatus.onSuccess(todoBean);
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to add todo', statusCode: 500),
      );
    }
  }

  static Future<ResponseStatus> updateTodoStatus(TodoBean todoBean) async {
    try {
      final db = await DatabaseConfig.initializeDb();

      await db.insert(
        'todos',
        todoBean.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return ResponseStatus.onSuccess(todoBean);
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to update todo', statusCode: 500),
      );
    }
  }

  static Future<ResponseStatus> updateTaskUpdatedAt(
    String taskId,
    String dateTime,
  ) async {
    try {
      final db = await DatabaseConfig.initializeDb();

      await db.update(
        'tasks',
        {'updated': dateTime},
        where: 'id = ?',
        whereArgs: [taskId],
      );

      return ResponseStatus.onSuccess(dateTime);
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(
          message: 'Failed to update todo timestamp',
          statusCode: 500,
        ),
      );
    }
  }

  static Future<ResponseStatus> deleteMultipleTasksByIds(
    List<String> taskIds,
  ) async {
    try {
      final db = await DatabaseConfig.initializeDb();

      final placeholders = List.filled(taskIds.length, '?').join(',');

      await db.delete(
        'tasks',
        where: 'id IN ($placeholders)',
        whereArgs: taskIds,
      );

      return ResponseStatus.onSuccess('Deleted ${taskIds.length} task(s)');
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to delete tasks', statusCode: 500),
      );
    }
  }

  static Future<ResponseStatus> updateTaskTitle(
    String taskId,
    String title,
  ) async {
    try {
      final db = await DatabaseConfig.initializeDb();
      await db.update(
        'tasks',
        {'title': title},
        where: 'id = ?',
        whereArgs: [taskId],
      );
      return ResponseStatus.onSuccess(title);
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(
          message: 'Failed to update task title',
          statusCode: 500,
        ),
      );
    }
  }
}
