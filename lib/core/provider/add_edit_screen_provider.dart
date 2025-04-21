import 'package:DoneIt/core/Repository/database_repo_impl.dart';
import 'package:DoneIt/domain/todo_bean.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/response_status.dart';
import '../../domain/task_bean.dart';

class AddEditScreenProvider {
  final ResponseStatus respTodoList;
  final ResponseStatus respAddTask;

  AddEditScreenProvider({
    required this.respTodoList,
    required this.respAddTask,
  });

  static AddEditScreenProvider get initial => AddEditScreenProvider(
    respTodoList: ResponseStatus.onEmpty(),
    respAddTask: ResponseStatus.onEmpty(),
  );

  AddEditScreenProvider copyWith({
    ResponseStatus? respTodoList,
    ResponseStatus? respAddTask,
  }) {
    return AddEditScreenProvider(
      respTodoList: respTodoList ?? this.respTodoList,
      respAddTask: respAddTask ?? this.respAddTask,
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
}

final addEditScreenProvider = StateNotifierProvider.autoDispose<
  AddEditScreenNotifier,
  AddEditScreenProvider
>((ref) {
  return AddEditScreenNotifier();
});
