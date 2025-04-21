import 'package:DoneIt/domain/task_bean.dart';
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
        COUNT(todos.id) AS completedTodosCount
      FROM tasks
      LEFT JOIN todos ON tasks.id = todos.task_id AND todos.is_done = 1
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
      final id = _uuid.v4();

      await db.insert('tasks', taskBean.toJson());

      return ResponseStatus.onSuccess(taskBean);
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to create task', statusCode: 500),
      );
    }
  }

  static Future<ResponseStatus> deleteTask(String taskId) async {
    try {
      final db = await DatabaseConfig.initializeDb();
      final rowsDeleted = await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [taskId],
      );

      if (rowsDeleted > 0) {
        return ResponseStatus.onSuccess(taskId);
      } else {
        return ResponseStatus.onError(
          ApiErrorDetails(message: 'Task not found', statusCode: 404),
        );
      }
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to delete task', statusCode: 500),
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
}
