import 'package:DoneIt/core/Repository/database_repo_impl.dart';
import 'package:DoneIt/domain/task_bean.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/response_status.dart';

class MainScreenProvider {
  final ResponseStatus respTaskList;
  final ResponseStatus respDeleteTask;
  final String sortBy;
  final String priorityBy;
  final List<String> sortByList;
  final List<String> priorityByList;

  MainScreenProvider({
    required this.respTaskList,
    required this.respDeleteTask,
    required this.sortBy,
    required this.priorityBy,
    required this.sortByList,
    required this.priorityByList,
  });

  static MainScreenProvider get initial => MainScreenProvider(
    respTaskList: ResponseStatus.onEmpty(),
    respDeleteTask: ResponseStatus.onEmpty(),
    sortBy: "Created",
    sortByList: ["Name", "Created", "Updated", "Completed"],
    priorityBy: "None",
    priorityByList: ["None", "Low", "Medium", "High"],
  );

  MainScreenProvider copyWith({
    ResponseStatus? respTaskList,
    ResponseStatus? respDeleteTask,
    String? sortBy,
    List<String>? sortByList,
    String? priorityBy,
    List<String>? priorityByList,
  }) {
    return MainScreenProvider(
      respTaskList: respTaskList ?? this.respTaskList,
      respDeleteTask: respDeleteTask ?? this.respDeleteTask,
      sortBy: sortBy ?? this.sortBy,
      sortByList: sortByList ?? this.sortByList,
      priorityBy: priorityBy ?? this.priorityBy,
      priorityByList: priorityByList ?? this.priorityByList,
    );
  }
}

class MainScreenNotifier extends StateNotifier<MainScreenProvider> {
  MainScreenNotifier() : super(MainScreenProvider.initial);

  void changeSortBy({required String sortBy}) {
    state = state.copyWith(sortBy: sortBy);
  }

  void changePriorityBy({required String priorityBy}) {
    state = state.copyWith(priorityBy: priorityBy);
  }

  void resetTaskListState() {
    state = state.copyWith(respTaskList: ResponseStatus.onEmpty());
  }

  void resetDeleteTaskState() {
    state = state.copyWith(respDeleteTask: ResponseStatus.onEmpty());
  }

  void getTaskList() async {
    state = state.copyWith(respTaskList: ResponseStatus.onLoading());
    var response = await DatabaseRepository.getAllTasks(
      sortBy: state.sortBy,
      priorityBy: state.priorityBy,
    );
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
      respTaskList: ResponseStatus.onSuccess(
        getSortedTasks(updatedTaskList, state.sortBy, state.priorityBy),
      ),
    );
  }

  void deleteTask({required List<TaskBean> taskBean}) async {
    debugPrint("function called");
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

  List<TaskBean> getSortedTasks(
    List<TaskBean> tasks,
    String sortBy,
    String priorityBy,
  ) {
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
