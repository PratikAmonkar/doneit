import 'package:DoneIt/core/Repository/database_repo_impl.dart';
import 'package:DoneIt/domain/task_bean.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/response_status.dart';

class MainScreenProvider {
  final ResponseStatus respTaskList;

  MainScreenProvider({required this.respTaskList});

  static MainScreenProvider get initial =>
      MainScreenProvider(respTaskList: ResponseStatus.onEmpty());

  MainScreenProvider copyWith({ResponseStatus? respTaskList}) {
    return MainScreenProvider(respTaskList: respTaskList ?? this.respTaskList);
  }
}

class MainScreenNotifier extends StateNotifier<MainScreenProvider> {
  MainScreenNotifier() : super(MainScreenProvider.initial);

  void resetTaskListState() {
    state = state.copyWith(respTaskList: ResponseStatus.onEmpty());
  }

  void getTaskList() async {
    state = state.copyWith(respTaskList: ResponseStatus.onLoading());
    var response = await DatabaseRepository.getAllTasks();
    if (response.isSuccess) {
      debugPrint("Success = ${response.data}");
      var successState =
          (response.data as List).map((productJson) {
            return TaskBean.fromJson(productJson);
          }).toList();

      debugPrint("Success data = $successState");

      state = state.copyWith(
        respTaskList: ResponseStatus.onSuccess(successState),
      );
    } else {
      state = state.copyWith(
        respTaskList: ResponseStatus.onError(response.error),
      );
    }
  }

  void addTaskToList({required TaskBean task}) {
    List<TaskBean> updatedTaskList = List<TaskBean>.from(
      state.respTaskList.data,
    );

    updatedTaskList.insert(0, task);

    state = state.copyWith(
      respTaskList: ResponseStatus.onSuccess(updatedTaskList),
    );
  }

  void updateTodoTotalCount({
    required String taskId,
    required int todosCount,
  }) async {
    List<TaskBean> currentList = List<TaskBean>.from(state.respTaskList.data);
    final index = currentList.indexWhere((task) => task.id == taskId);
    final updatedAt = DateTime.now().toIso8601String();
    var response = await DatabaseRepository.updateTaskUpdatedAt(
      taskId,
      updatedAt,
    );
    if (response.isSuccess) {
      if (index != -1) {
        final updatedTask = currentList[index].copyWith(
          totalTodosCount: todosCount,
          updated: updatedAt,
        );
        currentList[index] = updatedTask;
        state = state.copyWith(
          respTaskList: ResponseStatus.onSuccess(currentList),
        );
      }
    }
  }

  void updateTodoDoneCount({
    required String taskId,
    required int todoDoneCount,
  }) async {
    List<TaskBean> currentList = List<TaskBean>.from(state.respTaskList.data);

    final index = currentList.indexWhere((task) => task.id == taskId);
    final updatedAt = DateTime.now().toIso8601String();
    var response = await DatabaseRepository.updateTaskUpdatedAt(
      taskId,
      updatedAt,
    );
    if (response.isSuccess) {
      if (index != -1) {
        final updatedTask = currentList[index].copyWith(
          todosDoneCount: todoDoneCount,
          updated: updatedAt,
        );
        currentList[index] = updatedTask;
        state = state.copyWith(
          respTaskList: ResponseStatus.onSuccess(currentList),
        );
      }
    }
  }
}

final mainScreenProvider =
    StateNotifierProvider<MainScreenNotifier, MainScreenProvider>((ref) {
      return MainScreenNotifier();
    });
