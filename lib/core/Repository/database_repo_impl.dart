import 'package:DoneIt/domain/task_bean.dart';
import 'package:DoneIt/domain/todo_bean.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/response_status.dart';
import '../configuration/database_config.dart';

class DatabaseRepository {
  static String _getOrderByClause(String sortBy) {
    switch (sortBy) {
      case "Name":
        return "tasks.title COLLATE NOCASE ASC";
      case "Created":
        return "tasks.created DESC";
      case "Updated":
        return "tasks.updated DESC";
      case "Completed":
        return "completedTodosCount DESC";
      default:
        return "tasks.created DESC";
    }
  }

  static Future<ResponseStatus> getAllTasks({required String sortBy}) async {
    try {
      final db = await DatabaseConfig.initializeDb();

      final orderByClause = _getOrderByClause(sortBy);

      final result = await db.rawQuery('''
          SELECT 
            tasks.*,
            COUNT(CASE WHEN todos.is_done = 1 THEN 1 END) AS completedTodosCount,
            COUNT(todos.id) AS totalTodosCount
          FROM tasks
          LEFT JOIN todos ON tasks.id = todos.task_id
          GROUP BY tasks.id
          ORDER BY $orderByClause;
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

      await db.transaction((txn) async {
        final now = DateTime.now().toIso8601String();
        final todo = await txn.query(
          'todos',
          columns: ['task_id', 'is_done'],
          where: 'id = ?',
          whereArgs: [todoId],
          limit: 1,
        );

        if (todo.isEmpty) {
          throw Exception('Todo not found');
        }

        final taskId = todo.first['task_id'];
        final isDone = todo.first['is_done'] == 1;

        final rowsDeleted = await txn.delete(
          'todos',
          where: 'id = ?',
          whereArgs: [todoId],
        );

        if (rowsDeleted == 0) {
          throw Exception('Failed to delete todo');
        }

        final updateQuery = StringBuffer('''
        UPDATE tasks
        SET 
          total_todos_count = CASE WHEN total_todos_count > 0 THEN total_todos_count - 1 ELSE 0 END,
          updated = ?
      ''');

        if (isDone) {
          updateQuery.write('''
          , total_todos_done = CASE WHEN total_todos_done > 0 THEN total_todos_done - 1 ELSE 0 END
        ''');
        }

        updateQuery.write(' WHERE id = ?');
        await txn.rawUpdate(updateQuery.toString(), [now, taskId]);
      });

      return ResponseStatus.onSuccess(todoId);
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

      await db.transaction((txn) async {
        final now = DateTime.now().toIso8601String();
        await txn.insert('todos', todoBean.toJson());
        await txn.rawUpdate(
          '''
        UPDATE tasks
        SET 
          total_todos_count = total_todos_count + 1,
          updated = ?
        WHERE id = ?
        ''',
          [now, todoBean.taskId],
        );
      });

      return ResponseStatus.onSuccess(todoBean);
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to add todo', statusCode: 500),
      );
    }
  }

  static Future<ResponseStatus> updateTodoStatus(TodoBean todoBean) async {
    final now = DateTime.now().toIso8601String();
    try {
      final db = await DatabaseConfig.initializeDb();

      await db.transaction((txn) async {
        final existingTodo = await txn.query(
          'todos',
          columns: ['is_done', 'task_id'],
          where: 'id = ?',
          whereArgs: [todoBean.id],
          limit: 1,
        );
        if (existingTodo.isEmpty) {
          throw Exception('Todo not found');
        }
        final currentIsDone = existingTodo.first['is_done'] == 1;
        final newIsDone = todoBean.isDone == true;
        final taskId = existingTodo.first['task_id'];

        final updatedTodoJson = Map<String, dynamic>.from(todoBean.toJson());
        updatedTodoJson['updated'] = now;

        await txn.insert(
          'todos',
          updatedTodoJson,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        if (currentIsDone != newIsDone) {
          final updateQuery = StringBuffer('''
          UPDATE tasks
          SET total_todos_done = 
        ''');
          if (newIsDone) {
            updateQuery.write('total_todos_done + 1');
          } else {
            updateQuery.write(
              'CASE WHEN total_todos_done > 0 THEN total_todos_done - 1 ELSE 0 END',
            );
          }
          updateQuery.write(', updated = ? WHERE id = ?');
          await txn.rawUpdate(updateQuery.toString(), [now, taskId]);
        }
      });

      return ResponseStatus.onSuccess(todoBean.copyWith(updated: now));
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to update todo', statusCode: 500),
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
        {'title': title, 'updated': DateTime.now().toIso8601String()},
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

  static Future<ResponseStatus> updateReminderTime({
    required String taskId,
    required String? reminderDateTime,
  }) async {
    try {
      final db = await DatabaseConfig.initializeDb();
      final now = DateTime.now().toIso8601String();

      await db.update(
        'tasks',
        {'reminder_date_time': reminderDateTime, 'updated': now},
        where: 'id = ?',
        whereArgs: [taskId],
      );
      return ResponseStatus.onSuccess(taskId);
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to add reminder', statusCode: 500),
      );
    }
  }
}
