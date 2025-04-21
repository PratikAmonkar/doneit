import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/response_status.dart';
import '../configuration/database_config.dart';
/*

class DatabaseRepoImpl {
  final DatabaseConfig _dbInit = DatabaseConfig();

  final _uuid = Uuid();

  Future<String> insertTask(String title) async {
    final db = await _dbInit.database;
    final id = _uuid.v4();
    await db.insert('tasks', {'id': id, 'title': title});
    return id;
  }

  Future<String> insertTodo(String taskId, String description) async {
    final db = await _dbInit.database;
    final id = _uuid.v4();
    await db.insert('todos', {
      'id': id,
      'task_id': taskId,
      'description': description,
      'is_done': 0,
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> getTasksWithTodos() async {
    final db = await _dbInit.database;
    final tasks = await db.query('tasks');

    List<Map<String, dynamic>> result = [];

    for (var task in tasks) {
      final todos = await db.query(
        'todos',
        where: 'task_id = ?',
        whereArgs: [task['id']],
      );

      result.add({'task': task, 'todos': todos});
    }

    return result;
  }

  Future<int> deleteTask(int id) async {
    final db = await _dbInit.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTodo(int id) async {
    final db = await _dbInit.database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> markTodoDone(int id, bool isDone) async {
    final db = await _dbInit.database;
    return await db.update(
      'todos',
      {'is_done': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
*/

// lib/data/db/task_repository_impl.dart

/*
class DatabaseRepositoryImpl {
  final dbInit = DatabaseConfig();
  final uuid = const Uuid();

  Future<ResponseStatus<dynamic>> getAllTasks() async {
    try {
      final db = await dbInit.database;
      final result = await db.query('tasks');
      debugPrint("Result data = $result");
      return ResponseStatus.onSuccess(result);
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to fetch tasks', statusCode: 500),
      );
    }
  }

  Future<ResponseStatus<dynamic>> getTaskDetail(String id) async {
    try {
      final db = await dbInit.database;
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

  Future<ResponseStatus<dynamic>> createTask(String title) async {
    try {
      final db = await dbInit.database;
      final id = uuid.v4();
      await db.insert('tasks', {'id': id, 'title': title});
      return ResponseStatus.onSuccess({'id': id, 'title': title});
    } catch (e) {
      return ResponseStatus.onError(
        ApiErrorDetails(message: 'Failed to create task', statusCode: 500),
      );
    }
  }
}
*/

class DatabaseRepository {
  static final _uuid = Uuid();

  static Future<ResponseStatus> getAllTasks() async {
    try {
      final db = await DatabaseConfig.initializeDb();
      final result = await db.query('tasks');
      debugPrint("Result data = $result");

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

  static Future<ResponseStatus> createTask(String title) async {
    try {
      final db = await DatabaseConfig.initializeDb();
      final id = _uuid.v4();

      await db.insert('tasks', {'id': id, 'title': title});

      return ResponseStatus.onSuccess({'id': id, 'title': title});
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
}
