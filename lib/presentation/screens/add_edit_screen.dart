import 'package:DoneIt/core/provider/add_edit_screen_provider.dart';
import 'package:DoneIt/core/provider/main_screen_provider.dart';
import 'package:DoneIt/core/util/common_util.dart';
import 'package:DoneIt/domain/task_bean.dart';
import 'package:DoneIt/domain/todo_bean.dart';
import 'package:DoneIt/presentation/components/CheckBox/checkbox.dart';
import 'package:DoneIt/presentation/components/SnackBar/snackbar_with_action.dart';
import 'package:DoneIt/presentation/components/Spacer/spacer.dart';
import 'package:DoneIt/presentation/components/TextField/textField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/service/notification_service.dart';
import '../../core/service/permission_service.dart';
import '../components/DateTimePicker/date_time_picker.dart';
import '../components/Dialog/dialog.dart';
import '../components/System Ui/system_ui.dart';
import '../components/Text/text.dart';

class AddEditScreen extends ConsumerStatefulWidget {
  final String? id;
  final String name;
  final int? notificationId;

  const AddEditScreen({
    super.key,
    required this.id,
    required this.name,
    this.notificationId,
  });

  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  bool editTaskName = false;
  bool editTodoName = false;

  String taskName = "";

  List<TodoBean> todosList = [];

  // DateTime? selectedDateTime;

  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController todoNameController = TextEditingController();

  final notificationService = NotificationService();
  final permissionService = PermissionService();

  bool isReminderAdd = false;

  @override
  void initState() {
    super.initState();
    systemUiConfig(
      statusBarColor: AppColors.lightBackground,
      navigationColor: AppColors.lightBackground,
    );
    setState(() {
      taskName = widget.name;
      isReminderAdd = widget.notificationId != null;
    });
  }

  /*  Future<void> checkAndRequestNotificationPermission(
    BuildContext context, {
    bool isUpdate = false,
  }) async
  {
    final status = await permissionService.requestPermission(
      Permission.notification,
    );
    debugPrint("Status = $status");
    if (status.isGranted) {
      debugPrint("Notification permission granted");
      _onCustomPick(isUpdate: isUpdate);
    } else if (status.isDenied) {
      debugPrint("else if");
      final shouldShowRationale = await permissionService
          .shouldShowRequestRationale(Permission.notification);

      if (shouldShowRationale) {
        debugPrint("Test 1");
        if (context.mounted) {
          await permissionService.relationalDialog(context, () {
            checkAndRequestNotificationPermission(context, isUpdate: isUpdate);
          });
        }
      } else {
        debugPrint("Test 2");
        await permissionService.openAppSetting();
      }
    } else {
      debugPrint("else");
      if (context.mounted) {
        showCustomDialog(
          context: context,
          title:
              "Notification permission is currently disabled. Please go to settings to enable it and receive task reminders.",
          systemUiColor: AppColors.lightBackground,
          onSuccessAction: () async {
            await permissionService.openAppSetting();
          },
          onDismissAction: () {},
        );
      }
    }
  }*/

  Future<void> checkAndRequestPermissions(
    BuildContext context, {
    bool isUpdate = false,
    List<Permission> permissions = const [
      Permission.notification,
      Permission.scheduleExactAlarm,
    ],
  }) async {
    final Map<Permission, PermissionStatus> statuses = await permissionService
        .requestMultiplePermission(permissions);

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (allGranted) {
      debugPrint("All permissions granted");
      _onCustomPick(isUpdate: isUpdate);
      return;
    }

    for (final permission in permissions) {
      final status = statuses[permission];

      if (status == PermissionStatus.denied) {
        final shouldShowRationale = await permissionService
            .shouldShowRequestRationale(permission);

        if (shouldShowRationale) {
          debugPrint("Rationale required for $permission");
          if (context.mounted) {
            await permissionService.relationalDialog(context, () {
              checkAndRequestPermissions(
                context,
                isUpdate: isUpdate,
                permissions: permissions,
              );
            });
          }
        } else {
          debugPrint("Permission $permission permanently denied");
          await permissionService.openAppSetting();
        }

        return; // Exit early if any permission needs action
      }

      if (status == PermissionStatus.permanentlyDenied) {
        if (context.mounted) {
          showCustomDialog(
            context: context,
            title:
                "Some required permissions are disabled. Please go to settings to enable them.",
            systemUiColor: AppColors.lightBackground,
            onSuccessAction: () async {
              await permissionService.openAppSetting();
            },
            onDismissAction: () {},
          );
        }
        return;
      }
    }
  }

  void _onCustomPick({bool isUpdate = false}) async {
    final selected = await pickCustomDateTime(context: context);
    final int notificationId = (Uuid().v4().hashCode & 0x7fffffff);

    if (isUpdate) {
      await notificationService.cancelNotification(widget.notificationId ?? 0);
    }
    notificationService.scheduleNotification(
      title: 'Heads up! Your task is due: $taskName',
      body: 'Let\'s work on those to-dos for it!',
      notificationId: notificationId,
      //hashCode may return a negative number. You can wrap it to make it positive:
      channelId: 'task_channel',
      category: 'reminder',
      scheduleDateTime: selected ?? DateTime.now().add(Duration(seconds: 10)),
    );

    if (selected != null &&
        await notificationService.isNotificationScheduled(notificationId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(addEditScreenProvider.notifier)
            .addNotificationData(
              reminderDateTime: selected.toIso8601String(),
              taskId: widget.id ?? "",
              notificationId: notificationId,
            );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarMessage(
          context: context,
          primaryTitle: "Unable to set reminder",
          onCloseAction: () {},
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final addEditProvider = ref.watch(addEditScreenProvider);

    if (widget.id != null) {
      if (addEditProvider.respTodoList.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(addEditScreenProvider.notifier)
              .getTodoList(taskId: widget.id ?? "");
        });
      }
      if (addEditProvider.respTodoList.isSuccess) {
        setState(() {
          todosList = addEditProvider.respTodoList.data;
        });
      }
    }

    if (addEditProvider.respAddReminder.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarMessage(
          context: context,
          primaryTitle: "Reminder added successfully",
          onCloseAction: () {},
        );
        setState(() {
          isReminderAdd = true;
        });
        ref.read(mainScreenProvider.notifier).getTaskList();
        ref.read(addEditScreenProvider.notifier).resetReminderState();
      });
    }

    if (addEditProvider.respAddReminder.isError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarMessage(
          context: context,
          primaryTitle: "Failed to add reminder",
          onCloseAction: () {},
        );
        ref.read(addEditScreenProvider.notifier).resetReminderState();
      });
    }

    if (addEditProvider.respUpdateTaskTitle.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarMessage(
          context: context,
          primaryTitle: "Task title change successfully",
          onCloseAction: () {},
        );
        setState(() {
          editTaskName = false;
          taskName = taskNameController.text;
        });
        ref.read(mainScreenProvider.notifier).getTaskList();
        ref.read(addEditScreenProvider.notifier).resetTaskTitleState();
      });
    }

    if (addEditProvider.respUpdateTaskTitle.isError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarMessage(
          context: context,
          primaryTitle: "Failed to update task title",
          onCloseAction: () {},
        );
        setState(() {
          editTaskName = false;
        });
        ref.read(addEditScreenProvider.notifier).resetTaskTitleState();
      });
    }

    if (addEditProvider.respAddTask.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(mainScreenProvider.notifier).getTaskList();
        ref.read(addEditScreenProvider.notifier).resetAddTaskState();
        GoRouter.of(context).pop();
      });
    }

    if (addEditProvider.respDeleteTodo.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarMessage(
          context: context,
          primaryTitle: "Todo delete successfully",
          onCloseAction: () {},
        );
        ref.read(mainScreenProvider.notifier).getTaskList();
        ref.read(addEditScreenProvider.notifier).resetDeleteTodoState();
      });
    }

    if (addEditProvider.respDeleteTodo.isError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarMessage(
          context: context,
          primaryTitle: "Failed to delete todo",
          onCloseAction: () {},
        );
        ref.read(addEditScreenProvider.notifier).resetDeleteTodoState();
      });
    }

    if (addEditProvider.respUpdateTodoStatus.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(mainScreenProvider.notifier).getTaskList();
        ref.read(addEditScreenProvider.notifier).resetUpdateTodoStatusState();
      });
    }

    if (addEditProvider.respUpdateTodoStatus.isError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarMessage(
          context: context,
          primaryTitle: "Failed to update todo",
          onCloseAction: () {},
        );
        ref.read(addEditScreenProvider.notifier).resetUpdateTodoStatusState();
      });
    }

    if (addEditProvider.respAddTodo.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          todoNameController.text = "";
        });
        showSnackBarMessage(
          context: context,
          primaryTitle: "New Todo added!!",
          onCloseAction: () {},
        );
        ref.read(mainScreenProvider.notifier).getTaskList();
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

    if (addEditProvider.respAddPriority.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(mainScreenProvider.notifier).getTaskList();
        ref.read(addEditScreenProvider.notifier).resetReminderState();
      });
    }

    if (addEditProvider.respAddPriority.isError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarMessage(
          context: context,
          primaryTitle: "Failed to set priority",
          onCloseAction: () {},
        );
        ref.read(addEditScreenProvider.notifier).resetReminderState();
      });
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
                  if (widget.name.isEmpty || editTaskName) ...[
                    textField(
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
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(addEditScreenProvider.notifier)
                                .addTask(
                                  task: TaskBean(
                                    id: Uuid().v4(),
                                    title: taskNameController.text,
                                    created: DateTime.now().toIso8601String(),
                                    todosDoneCount: 0,
                                    totalTodosCount: 0,
                                  ),
                                );
                          });
                        } else {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(addEditScreenProvider.notifier)
                                .updateTaskTitle(
                                  taskId: widget.id ?? "",
                                  title: taskNameController.text,
                                );
                          });
                        }
                      },
                    ),
                  ] else ...[
                    textBold(title: taskName, maxLine: 2, fontSize: 20.0),
                  ],
                  verticalSpacer(),
                  if (widget.id != null) ...[
                    textMedium(
                      title:
                          "Completed ${todosList.where((value) => value.isDone == true).length} out of ${todosList.length} todos",
                      fontSize: 14.0,
                      fontColor: Colors.grey.shade600,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            textMedium(
                              title: "Reminder",
                              fontSize: 14.0,
                              fontColor: Colors.grey.shade600,
                            ),
                            IconButton(
                              onPressed: () {
                                if (isReminderAdd) {
                                  showCustomDialog(
                                    context: context,
                                    title:
                                        "A reminder already exists. Do you want to change it?",
                                    systemUiColor: AppColors.lightBackground,
                                    onSuccessAction: () {
                                      checkAndRequestPermissions(
                                        context,
                                        isUpdate: true,
                                      );
                                    },
                                    onDismissAction: () {},
                                  );
                                } else {
                                  checkAndRequestPermissions(context);
                                }
                              },
                              icon: Icon(
                                isReminderAdd
                                    ? Icons.alarm_on_outlined
                                    : Icons.alarm_add_rounded,
                                size: 20.0,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            textMedium(
                              title: "Priority : ${addEditProvider.priority}",
                              fontSize: 14.0,
                              fontColor: Colors.grey.shade600,
                            ),
                            PopupMenuButton(
                              icon: const Icon(
                                Icons.more_vert,
                                size: 20.0,
                                color: Colors.black,
                              ),
                              onSelected: (value) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  ref
                                      .read(addEditScreenProvider.notifier)
                                      .addTaskPriority(
                                        priorityBy: value,
                                        taskId: widget.id ?? "",
                                      );
                                  ref
                                      .read(mainScreenProvider.notifier)
                                      .resetTaskListState();
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return addEditProvider.priorityByList.map((
                                  String option,
                                ) {
                                  return PopupMenuItem(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0,
                                        color:
                                            addEditProvider.priority == option
                                                ? AppColors.lightPurple200
                                                : Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ],
                        ),
                      ],
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
                          if (value.isNotEmpty) {
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
                          }
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
                              color:
                                  todo.isDone
                                      ? Colors.grey.shade300
                                      : AppColors.lightPurple100,
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
                                            onTapAction: () {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                    ref
                                                        .read(
                                                          addEditScreenProvider
                                                              .notifier,
                                                        )
                                                        .updateTodoStatus(
                                                          todo: todo.copyWith(
                                                            isDone:
                                                                !todo.isDone,
                                                          ),
                                                        );
                                                  });
                                            },
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
                                          GestureDetector(
                                            onTap: () {
                                              ref
                                                  .read(
                                                    addEditScreenProvider
                                                        .notifier,
                                                  )
                                                  .deleteTodo(todoId: todo.id);
                                            },
                                            child: Icon(
                                              Icons.delete_outline_rounded,
                                              color: AppColors.lightRed100,
                                              size: 24.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: textMedium(
                                          title:
                                              "${todo.updated != null ? "Last updated :" : "created :"} ${todo.updated != null ? CommonUtil().getDate(option: 1, value: todo.updated ?? "") : CommonUtil().getDate(option: 1, value: todo.created)}",
                                          fontSize: 10.0,
                                          fontColor: Colors.grey.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
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
