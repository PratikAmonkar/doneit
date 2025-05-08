import 'package:DoneIt/core/Repository/database_repo_impl.dart';
import 'package:DoneIt/domain/todo_bean.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/response_status.dart';
import '../../domain/task_bean.dart';

class AddEditScreenProvider {
  final ResponseStatus respTodoList;
  final ResponseStatus respAddTask;
  final ResponseStatus respAddTodo;
  final ResponseStatus respUpdateTodoStatus;
  final ResponseStatus respDeleteTodo;
  final ResponseStatus respUpdateTaskTitle;

  AddEditScreenProvider({
    required this.respTodoList,
    required this.respAddTask,
    required this.respAddTodo,
    required this.respUpdateTodoStatus,
    required this.respDeleteTodo,
    required this.respUpdateTaskTitle,
  });

  static AddEditScreenProvider get initial => AddEditScreenProvider(
    respTodoList: ResponseStatus.onEmpty(),
    respAddTask: ResponseStatus.onEmpty(),
    respAddTodo: ResponseStatus.onEmpty(),
    respUpdateTodoStatus: ResponseStatus.onEmpty(),
    respDeleteTodo: ResponseStatus.onEmpty(),
    respUpdateTaskTitle: ResponseStatus.onEmpty(),
  );

  AddEditScreenProvider copyWith({
    ResponseStatus? respTodoList,
    ResponseStatus? respAddTask,
    ResponseStatus? respAddTodo,
    ResponseStatus? respUpdateTodoStatus,
    ResponseStatus? respDeleteTodo,
    ResponseStatus? respUpdateTaskTitle,
  }) {
    return AddEditScreenProvider(
      respTodoList: respTodoList ?? this.respTodoList,
      respAddTask: respAddTask ?? this.respAddTask,
      respAddTodo: respAddTodo ?? this.respAddTodo,
      respUpdateTodoStatus: respUpdateTodoStatus ?? this.respUpdateTodoStatus,
      respDeleteTodo: respDeleteTodo ?? this.respDeleteTodo,
      respUpdateTaskTitle: respUpdateTaskTitle ?? this.respUpdateTaskTitle,
    );
  }
}

class AddEditScreenNotifier extends StateNotifier<AddEditScreenProvider> {
  AddEditScreenNotifier() : super(AddEditScreenProvider.initial);

  void resetTodoListState() {
    state = state.copyWith(respTodoList: ResponseStatus.onEmpty());
  }

  void resetAddTaskState() {
    state = state.copyWith(respAddTask: ResponseStatus.onEmpty());
  }

  void resetAddTodoState() {
    state = state.copyWith(respAddTodo: ResponseStatus.onEmpty());
  }

  void resetUpdateTodoStatusState() {
    state = state.copyWith(respUpdateTodoStatus: ResponseStatus.onEmpty());
  }

  void resetDeleteTodoState() {
    state = state.copyWith(respDeleteTodo: ResponseStatus.onEmpty());
  }

  void resetTaskTitleState() {
    state = state.copyWith(respUpdateTaskTitle: ResponseStatus.onEmpty());
  }

  void getTodoList({required String taskId}) async {
    state = state.copyWith(respTodoList: ResponseStatus.onLoading());
    var response = await DatabaseRepository.getTodosByTaskId(taskId);
    if (response.isSuccess) {
      var successState =
          (response.data as List).map((productJson) {
            return TodoBean.fromJson(productJson);
          }).toList();
      state = state.copyWith(
        respTodoList: ResponseStatus.onSuccess(successState),
      );
    } else {
      state = state.copyWith(
        respTodoList: ResponseStatus.onError(response.error),
      );
    }
  }

  void addTask({required TaskBean task}) async {
    state = state.copyWith(respAddTask: ResponseStatus.onLoading());
    var response = await DatabaseRepository.createTask(task);
    if (response.isSuccess) {
      state = state.copyWith(respAddTask: ResponseStatus.onSuccess(task));
    } else {
      state = state.copyWith(
        respAddTask: ResponseStatus.onError(response.error),
      );
    }
  }

  void addTodo({required TodoBean todo}) async {
    state = state.copyWith(respAddTodo: ResponseStatus.onLoading());
    var response = await DatabaseRepository.addTodo(todo);
    if (response.isSuccess) {
      List<TodoBean> updatedTodoList = [];
      updatedTodoList = List<TodoBean>.from(state.respTodoList.data);
      updatedTodoList.add(todo);
      state = state.copyWith(
        respAddTodo: ResponseStatus.onSuccess(todo),
        respTodoList: ResponseStatus.onSuccess(updatedTodoList),
      );
    } else {
      state = state.copyWith(
        respAddTodo: ResponseStatus.onError(response.error),
      );
    }
  }

  void updateTodoStatus({required TodoBean todo}) async {
    state = state.copyWith(respUpdateTodoStatus: ResponseStatus.onLoading());
    var response = await DatabaseRepository.updateTodoStatus(todo);
    if (response.isSuccess) {
      List<TodoBean> currentTodos = List<TodoBean>.from(
        state.respTodoList.data,
      );

      final index = currentTodos.indexWhere(
        (value) => value.title == todo.title,
      );

      if (index != -1) {
        currentTodos[index] = response.data;
        state = state.copyWith(
          respTodoList: ResponseStatus.onSuccess(currentTodos),
          respUpdateTodoStatus: ResponseStatus.onSuccess(currentTodos),
        );
      }
      state = state.copyWith(
        respUpdateTodoStatus: ResponseStatus.onSuccess(todo),
      );
    } else {
      state = state.copyWith(
        respUpdateTodoStatus: ResponseStatus.onError(response.error),
      );
    }
  }

  void deleteTodo({required String todoId}) async {
    var response = await DatabaseRepository.deleteTodo(todoId);
    if (response.isSuccess) {
      List<TodoBean> currentTodos = [];
      currentTodos = List<TodoBean>.from(state.respTodoList.data);
      currentTodos.removeWhere((value) => value.id == todoId);
      state = state.copyWith(
        respTodoList: ResponseStatus.onSuccess(currentTodos),
        respDeleteTodo: ResponseStatus.onSuccess(todoId),
      );
    } else {
      state = state.copyWith(
        respDeleteTodo: ResponseStatus.onError(response.error),
      );
    }
  }

  void updateTaskTitle({required String taskId, required String title}) async {
    var response = await DatabaseRepository.updateTaskTitle(taskId, title);
    if (response.isSuccess) {
      state = state.copyWith(
        respUpdateTaskTitle: ResponseStatus.onSuccess(title),
      );
    } else {
      state = state.copyWith(
        respUpdateTaskTitle: ResponseStatus.onError(response.error),
      );
    }
  }
}

final addEditScreenProvider = StateNotifierProvider.autoDispose<
  AddEditScreenNotifier,
  AddEditScreenProvider
>((ref) {
  return AddEditScreenNotifier();
});
