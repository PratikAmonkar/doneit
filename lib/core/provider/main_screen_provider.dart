import 'package:DoneIt/core/Repository/database_repo_impl.dart';
import 'package:DoneIt/domain/task_bean.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/response_status.dart';

class MainScreenProvider {
  final ResponseStatus respTaskList;
  final ResponseStatus respDeleteTask;
  final String sortBy;
  final List<String> sortByList;

  MainScreenProvider({
    required this.respTaskList,
    required this.respDeleteTask,
    required this.sortBy,
    required this.sortByList,
  });

  static MainScreenProvider get initial => MainScreenProvider(
    respTaskList: ResponseStatus.onEmpty(),
    respDeleteTask: ResponseStatus.onEmpty(),
    sortBy: "Created",
    sortByList: ["Name", "Created", "Updated", "Completed"],
  );

  MainScreenProvider copyWith({
    ResponseStatus? respTaskList,
    ResponseStatus? respDeleteTask,
    String? sortBy,
    List<String>? sortByList,
  }) {
    return MainScreenProvider(
      respTaskList: respTaskList ?? this.respTaskList,
      respDeleteTask: respDeleteTask ?? this.respDeleteTask,
      sortBy: sortBy ?? this.sortBy,
      sortByList: sortByList ?? this.sortByList,
    );
  }
}

class MainScreenNotifier extends StateNotifier<MainScreenProvider> {
  MainScreenNotifier() : super(MainScreenProvider.initial);

  void changeSortBy({required String sortBy}) {
    state = state.copyWith(sortBy: sortBy);
  }

  void resetTaskListState() {
    state = state.copyWith(respTaskList: ResponseStatus.onEmpty());
  }

  void resetDeleteTaskState() {
    state = state.copyWith(respDeleteTask: ResponseStatus.onEmpty());
  }

  void getTaskList() async {
    state = state.copyWith(respTaskList: ResponseStatus.onLoading());
    var response = await DatabaseRepository.getAllTasks(sortBy: state.sortBy);
    if (response.isSuccess) {
      var successState =
          (response.data as List).map((productJson) {
            return TaskBean.fromJson(productJson);
          }).toList();
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

  void deleteTask({required List<TaskBean> taskBean}) async {
    state = state.copyWith(respDeleteTask: ResponseStatus.onLoading());
    List<String> deletedIds = taskBean.map((task) => task.id).toList();
    var response = await DatabaseRepository.deleteMultipleTasksByIds(
      deletedIds,
    );

    if (response.isSuccess) {
      List<TaskBean> updatedTaskList = List<TaskBean>.from(
        state.respTaskList.data,
      );
      updatedTaskList.removeWhere((task) => deletedIds.contains(task.id));
      state = state.copyWith(
        respTaskList: ResponseStatus.onSuccess(updatedTaskList),
        respDeleteTask: ResponseStatus.onSuccess(updatedTaskList),
      );
    } else {
      state = state.copyWith(
        respDeleteTask: ResponseStatus.onError(response.error),
      );
    }
  }

  void updateTaskTitle({required String taskId, required String title}) async {
    List<TaskBean> currentList = List<TaskBean>.from(state.respTaskList.data);

    final index = currentList.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final updatedTask = currentList[index].copyWith(
        title: title,
        updated: DateTime.now().toIso8601String(),
      );
      currentList[index] = updatedTask;
      state = state.copyWith(
        respTaskList: ResponseStatus.onSuccess(
          getSortedTasks(currentList, state.sortBy),
        ),
      );
    }
  }

  List<TaskBean> getSortedTasks(List<TaskBean> tasks, String sortBy) {
    final sortedList = List<TaskBean>.from(tasks);

    switch (sortBy) {
      case "Name":
        sortedList.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case "Created":
        sortedList.sort(
          (a, b) =>
              DateTime.parse(b.created).compareTo(DateTime.parse(a.created)),
        );
        break;
      case "Updated":
        sortedList.sort(
          (a, b) => DateTime.parse(
            b.updated ?? "",
          ).compareTo(DateTime.parse(a.updated ?? "")),
        );
        break;
      case "Completed":
        sortedList.sort(
          (a, b) => (b.todosDoneCount ?? 0).compareTo(a.todosDoneCount ?? 0),
        );
        break;
      default:
        sortedList.sort(
          (a, b) =>
              DateTime.parse(b.created).compareTo(DateTime.parse(a.created)),
        );
        break;
    }

    return sortedList;
  }
}

final mainScreenProvider =
    StateNotifierProvider<MainScreenNotifier, MainScreenProvider>((ref) {
      return MainScreenNotifier();
    });
