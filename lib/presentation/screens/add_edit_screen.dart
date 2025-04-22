import 'package:DoneIt/core/provider/add_edit_screen_provider.dart';
import 'package:DoneIt/core/provider/main_screen_provider.dart';
import 'package:DoneIt/domain/task_bean.dart';
import 'package:DoneIt/domain/todo_bean.dart';
import 'package:DoneIt/presentation/components/CheckBox/checkbox.dart';
import 'package:DoneIt/presentation/components/SnackBar/snackbar_with_action.dart';
import 'package:DoneIt/presentation/components/Spacer/spacer.dart';
import 'package:DoneIt/presentation/components/TextField/textField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../components/System Ui/system_ui.dart';
import '../components/Text/text.dart';

class AddEditScreen extends ConsumerStatefulWidget {
  final String? id;
  final String? name;

  const AddEditScreen({super.key, required this.id, required this.name});

  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  bool editTaskName = true;
  bool editTodoName = false;

  String taskName = "";

  List<TodoBean> todosList = [];

  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController todoNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    systemUiConfig(
      statusBarColor: AppColors.lightBackground,
      navigationColor: AppColors.lightBackground,
    );
  }

  @override
  Widget build(BuildContext context) {
    final addEditProvider = ref.watch(addEditScreenProvider);

    if (addEditProvider.respAddTask.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(mainScreenProvider.notifier)
            .addTaskToList(task: addEditProvider.respAddTask.data);
        ref.read(addEditScreenProvider.notifier).resetAddTaskState();
        GoRouter.of(context).pop();
      });
    }

    if (addEditProvider.respAddTodo.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          todoNameController.text = "";
        });
        showSnackBarMessage(
          context: context,
          primaryTitle: "Todo added!!",
          onCloseAction: () {},
        );
        ref.read(addEditScreenProvider.notifier).resetAddTodoState();
      });
    }
    if (addEditProvider.respAddTodo.isError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarMessage(
          context: context,
          primaryTitle: "Failed to add todo",
          onCloseAction: () {},
        );
        ref.read(addEditScreenProvider.notifier).resetAddTodoState();
      });
    }

    if (widget.id != null) {
      if (addEditProvider.respTodoList.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(addEditScreenProvider.notifier)
              .getTodoList(taskId: widget.id ?? "");
        });
      }
      if (addEditProvider.respTodoList.isError) {
        debugPrint("Error");
      }
      if (addEditProvider.respTodoList.isSuccess) {
        debugPrint("Success");
        setState(() {
          /*  taskName = widget.name ?? "";
          if (editTaskName) {
            editTaskName = false;
          }
          todosList = addEditProvider.respTodoList.data;*/

          taskNameController.text = widget.name ?? "";
          todosList = addEditProvider.respTodoList.data;
        });
      }
    }

    return WillPopScope(
      onWillPop: () async {
        systemUiConfig(
          statusBarColor: AppColors.lightBackground,
          navigationColor: AppColors.lightBackground,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: AppColors.lightBackground,
          surfaceTintColor: AppColors.lightBackground,
          title: textBold(
            title: widget.id == null ? "Add Task" : "Edit Task",
            fontSize: 18.0,
          ),
          actions:
              widget.id != null
                  ? [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          editTaskName = !editTaskName;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(Icons.edit_outlined, size: 24.0),
                      ),
                    ),
                  ]
                  : null,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  taskNameController.text.isEmpty
                      ? textField(
                        controller: taskNameController,
                        backgroundColor: Colors.grey.shade200,
                        fontSize: 16.0,
                        hintText: "Enter task name",
                        imeActionType: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        fontColor: AppColors.fontColor1,
                        maxLines: 3,
                        onSubmitted: (value) {
                          if (widget.id == null) {
                            if (taskNameController.text.isNotEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ref
                                    .read(addEditScreenProvider.notifier)
                                    .addTask(
                                      task: TaskBean(
                                        id: Uuid().v4(),
                                        title: taskNameController.text,
                                        created:
                                            DateTime.now().toIso8601String(),
                                      ),
                                    );
                              });
                            }
                          }
                        },
                      )
                      : textBold(
                        title: taskNameController.text,
                        maxLine: 2,
                        fontSize: 20.0,
                      ),
                  verticalSpacer(),
                  if (widget.id != null) ...[
                    textMedium(
                      title:
                          "Completed ${todosList.where((value) => value.isDone == true).length} out of ${todosList.length} todos",
                      fontSize: 14.0,
                      fontColor: Colors.grey.shade600,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            editTodoName = !editTodoName;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 20.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.lightPurple200,
                          ),
                          child: Icon(
                            Icons.add,
                            color: AppColors.lightBackground,
                            size: 30.0,
                          ),
                        ),
                      ),
                    ),
                    if (editTodoName) ...[
                      textField(
                        controller: todoNameController,
                        backgroundColor: Colors.grey.shade200,
                        fontSize: 16.0,
                        hintText: "Enter todo name",
                        imeActionType: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        fontColor: AppColors.fontColor1,
                        maxLines: 3,
                        onSubmitted: (value) {
                          ref
                              .read(addEditScreenProvider.notifier)
                              .addTodo(
                                todo: TodoBean(
                                  id: Uuid().v4(),
                                  taskId: widget.id ?? "",
                                  isDone: false,
                                  created: DateTime.now().toIso8601String(),
                                  title: todoNameController.text,
                                ),
                              );
                        },
                      ),
                    ],
                    if (addEditProvider.respTodoList.isLoading) ...[
                      Center(child: CircularProgressIndicator()),
                    ],
                    if (addEditProvider.respTodoList.isSuccess) ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: todosList.length,
                        itemBuilder: (BuildContext context, int index) {
                          TodoBean todo = todosList[index];
                          return Container(
                            padding: EdgeInsets.all(10.0),
                            margin: EdgeInsets.only(bottom: 10.0, top: 20.0),
                            decoration: BoxDecoration(
                              color: AppColors.lightPurple100,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          checkBox(
                                            isChecked: todo.isDone,
                                            borderColor:
                                                AppColors.lightPurple200,
                                            onTapAction: () {},
                                            activeColor:
                                                AppColors.lightPurple200,
                                          ),
                                          horizontalSpacer(value: 20.0),
                                          Expanded(
                                            child: textBold(
                                              title: todo.title,
                                              fontSize: 18.0,
                                              maxLine: 2,
                                            ),
                                          ),
                                          horizontalSpacer(value: 20.0),
                                        ],
                                      ),
                                      textMedium(
                                        // title: "created: 20 Apr 25 , 05:26 PM",
                                        title: todo.created,
                                        fontSize: 12.0,
                                        fontColor: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.lightRed100,
                                  size: 24.0,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ] else ...[
                    verticalSpacer(value: 50.0),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/empty_data.png",
                            width: 100.0,
                            height: 100.0,
                          ),
                          verticalSpacer(),
                          textBold(title: "No todo available", fontSize: 14.0),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
