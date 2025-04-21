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
      // var successState = TaskBean.fromJson(response.data);
      var successState =
          (response.data as List).map((productJson) {
            return TaskBean.fromJson(productJson);
          }).toList();

      debugPrint("Success data = $successState");

      state = state.copyWith(
        respTaskList: ResponseStatus.onSuccess(successState),
      );
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

  void addTodoToList() async {
    /*  List<CartItemBean> updatedProductList = [];
    if (state.respProductList.isSuccess) {
      updatedProductList =
      List<CartItemBean>.from(state.respProductList.data.cartItemBean);
    }

    if (product.productId.toString() == productId) {
      updatedProductList.removeWhere(
            (product) => product.productId.toString() == productId,
      );
    }
    updatedProductList.add(product);
    CartBean updatedCart = CartBean(
      address: state.respProductList.data?.address,
      cartItemBean: updatedProductList,
    );*/
  }
}

final mainScreenProvider =
    StateNotifierProvider<MainScreenNotifier, MainScreenProvider>((ref) {
      return MainScreenNotifier();
    });
