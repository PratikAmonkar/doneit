import 'package:DoneIt/core/Repository/database_repo_impl.dart';
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
      debugPrint("Success data = ${response.data}");
      state = state.copyWith(respTaskList: ResponseStatus.onSuccess("data"));
      /*  var successState = ProductList.fromMap(response.data["data"]);
      state = state.copyWith(
        respTaskList: ResponseStatus.onSuccess(successState),
      );*/
    } else {
      state = state.copyWith(
        respTaskList: ResponseStatus.onError(response.error),
      );
    }
  }
}

final mainScreenProvider =
    StateNotifierProvider<MainScreenNotifier, MainScreenProvider>((ref) {
      return MainScreenNotifier();
    });
