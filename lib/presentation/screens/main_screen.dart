import 'package:DoneIt/core/provider/main_screen_provider.dart';
import 'package:DoneIt/domain/task_bean.dart';
import 'package:DoneIt/presentation/components/Text/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/service/permission_service.dart';
import '../../core/util/common_util.dart';
import '../components/Buttons/button.dart';
import '../components/CheckBox/checkbox.dart';
import '../components/Dialog/dialog.dart';
import '../components/SnackBar/snackbar_with_action.dart';
import '../components/Spacer/spacer.dart';
import '../components/System Ui/system_ui.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final ScrollController _scrollController = ScrollController();
  final permissionService = PermissionService();

  bool _showFab = true;
  bool _showAppBar = true;

  bool showCheckBox = false;

  List<TaskBean> deleteTaskList = [];

  @override
  void initState() {
    super.initState();

    systemUiConfig(
      statusBarColor: AppColors.lightBackground,
      navigationColor: AppColors.lightBackground,
    );
    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse) {
        if (_showFab) {
          setState(() {
            _showFab = false;
            _showAppBar = false;
          });
        }
      } else if (direction == ScrollDirection.forward) {
        if (!_showFab) {
          setState(() {
            _showFab = true;
            _showAppBar = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(mainScreenProvider);

    if (mainProvider.respTaskList.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(mainScreenProvider.notifier).getTaskList();
      });
    }

    if (mainProvider.respDeleteTask.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarMessage(
          context: context,
          primaryTitle: "Task deleted successfully",
          onCloseAction: () {},
        );
        ref.read(mainScreenProvider.notifier).resetDeleteTaskState();
      });
    }

    if (mainProvider.respDeleteTask.isError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarMessage(
          context: context,
          primaryTitle: "Failed to delete task",
          onCloseAction: () {},
        );
        ref.read(mainScreenProvider.notifier).resetDeleteTaskState();
      });
    }

    return WillPopScope(
      onWillPop: () async {
        systemUiConfig();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        floatingActionButton: AnimatedSlide(
          offset: _showFab ? Offset.zero : const Offset(0, 2),
          duration: const Duration(milliseconds: 1000),
          child: AnimatedOpacity(
            opacity: _showFab ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: FloatingActionButton(
                backgroundColor: AppColors.lightPurple200,
                onPressed: () {
                  setState(() {
                    showCheckBox = false;
                    deleteTaskList = [];
                  });
                  GoRouter.of(context).push("/add-edit-screen/0/a/-1/a");
                },
                child: const Icon(
                  Icons.add,
                  color: AppColors.lightBackground,
                  size: 30.0,
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: SafeArea(
          child: Stack(
            children: [
              if (mainProvider.respTaskList.isError) ...[
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/caution.png",
                        width: 100.0,
                        height: 100.0,
                      ),
                      textMedium(
                        title:
                            mainProvider.respTaskList.error?.message ??
                            "Something went wrong",
                        fontSize: 14.0,
                      ),
                      button(
                        text: "Retry",
                        width: 150.0,
                        height: 45.0,
                        backgroundColor: AppColors.lightRed100,
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(mainScreenProvider.notifier).getTaskList();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],

              if (mainProvider.respTaskList.isSuccess) ...[
                Column(
                  children: [
                    AnimatedContainer(
                      height: _showAppBar ? 56.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: AnimatedOpacity(
                        opacity: _showAppBar ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: AppBar(
                          backgroundColor: AppColors.lightBackground,
                          surfaceTintColor: AppColors.lightBackground,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              textBold(title: "Hey Buddy!", fontSize: 22.0),
                              textBold(
                                title: CommonUtil().greetUser(),
                                fontSize: 14.0,
                              ),
                            ],
                          ),
                          actions:
                              (mainProvider.respTaskList.data ?? List.empty())
                                      .isNotEmpty
                                  ? [
                                    GestureDetector(
                                      onTap: () {
                                        if (showCheckBox &&
                                            deleteTaskList.isNotEmpty) {
                                          showCustomDialog(
                                            context: context,
                                            title:
                                                "Are you sure want to delete?",
                                            systemUiColor:
                                                AppColors.lightBackground,
                                            onSuccessAction: () {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                    ref
                                                        .read(
                                                          mainScreenProvider
                                                              .notifier,
                                                        )
                                                        .deleteTask(
                                                          taskBean:
                                                              deleteTaskList,
                                                        );
                                                    setState(() {
                                                      deleteTaskList = [];
                                                    });
                                                  });
                                            },
                                            onDismissAction: () {
                                              setState(() {
                                                deleteTaskList = [];
                                              });
                                            },
                                          );
                                        }
                                        setState(() {
                                          showCheckBox = !showCheckBox;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                        ),
                                        child: Icon(
                                          Icons.delete_outline_rounded,
                                          color: AppColors.lightRed100,
                                          size: 24.0,
                                        ),
                                      ),
                                    ),
                                  ]
                                  : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      textBold(
                                        title:
                                            "Sort by : ${mainProvider.sortBy}",
                                        fontSize: 12.0,
                                      ),
                                      PopupMenuButton(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          size: 20.0,
                                          color: Colors.black,
                                        ),
                                        onSelected: (value) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                ref
                                                    .read(
                                                      mainScreenProvider
                                                          .notifier,
                                                    )
                                                    .changeSortBy(
                                                      sortBy: value,
                                                    );
                                                ref
                                                    .read(
                                                      mainScreenProvider
                                                          .notifier,
                                                    )
                                                    .resetTaskListState();
                                              });
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return mainProvider.sortByList.map((
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
                                                      mainProvider.sortBy ==
                                                              option
                                                          ? AppColors
                                                              .lightPurple200
                                                          : Colors.black,
                                                ),
                                              ),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      textBold(
                                        title:
                                            "Priority by : ${mainProvider.priorityBy}",
                                        fontSize: 12.0,
                                      ),
                                      PopupMenuButton(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          size: 20.0,
                                          color: Colors.black,
                                        ),
                                        onSelected: (value) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                ref
                                                    .read(
                                                      mainScreenProvider
                                                          .notifier,
                                                    )
                                                    .changePriorityBy(
                                                      priorityBy: value,
                                                    );
                                                ref
                                                    .read(
                                                      mainScreenProvider
                                                          .notifier,
                                                    )
                                                    .resetTaskListState();
                                              });
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return mainProvider.priorityByList.map(
                                            (String option) {
                                              return PopupMenuItem(
                                                value: option,
                                                child: Text(
                                                  option,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.0,
                                                    color:
                                                        mainProvider.sortBy ==
                                                                option
                                                            ? AppColors
                                                                .lightPurple200
                                                            : Colors.black,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).toList();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              verticalSpacer(value: 10.0),
                              (mainProvider.respTaskList.data ?? List.empty())
                                      .isEmpty
                                  ? SizedBox(
                                    width: double.infinity,
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.8,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/empty_data.png",
                                          width: 100.0,
                                          height: 100.0,
                                        ),
                                        verticalSpacer(),
                                        textBold(
                                          title: "No task available",
                                          fontSize: 14.0,
                                        ),
                                      ],
                                    ),
                                  )
                                  : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        (mainProvider.respTaskList.data ??
                                                List.empty())
                                            .length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final TaskBean taskBean =
                                          (mainProvider.respTaskList.data ??
                                              List.empty())[index];
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showCheckBox = false;
                                            deleteTaskList = [];
                                          });
                                          GoRouter.of(context).push(
                                            "/add-edit-screen/${taskBean.id}/${taskBean.title}/${taskBean.notificationId}/${taskBean.priority}",
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 20.0,
                                          ),
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                            color: AppColors.lightPurple100,
                                          ),
                                          child: Row(
                                            children: [
                                              if (showCheckBox) ...[
                                                checkBox(
                                                  isChecked: deleteTaskList
                                                      .contains(taskBean),
                                                  borderColor:
                                                      AppColors.lightPurple200,
                                                  onTapAction: () {
                                                    setState(() {
                                                      if (deleteTaskList
                                                              .contains(
                                                                taskBean,
                                                              ) !=
                                                          true) {
                                                        deleteTaskList.add(
                                                          taskBean,
                                                        );
                                                      } else {
                                                        deleteTaskList
                                                            .removeWhere(
                                                              (t) =>
                                                                  t.id ==
                                                                  taskBean.id,
                                                            );
                                                      }
                                                    });
                                                  },
                                                  activeColor:
                                                      AppColors.lightPurple200,
                                                ),
                                                horizontalSpacer(value: 20.0),
                                              ],
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    textBold(
                                                      title: taskBean.title,
                                                      fontSize: 18.0,
                                                    ),
                                                    textBold(
                                                      title:
                                                          "Completed ${taskBean.todosDoneCount} out of ${taskBean.totalTodosCount}",
                                                      fontSize: 10.0,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        textMedium(
                                                          title:
                                                              "${taskBean.updated != null ? "Last updated :" : "created :"} ${taskBean.updated != null ? CommonUtil().getDate(option: 1, value: taskBean.updated ?? "") : CommonUtil().getDate(option: 1, value: taskBean.created)}",
                                                          fontSize: 10.0,
                                                          fontColor:
                                                              Colors
                                                                  .grey
                                                                  .shade900,
                                                        ),
                                                        if (taskBean.priority !=
                                                            null) ...[
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      8.0,
                                                                  vertical: 2.0,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: CommonUtil()
                                                                  .getPriorityColor(
                                                                    priority:
                                                                        taskBean
                                                                            .priority!,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10.0,
                                                                  ),
                                                            ),
                                                            child: textMedium(
                                                              title:
                                                                  taskBean
                                                                      .priority!,
                                                              fontSize: 8.0,
                                                              fontColor:
                                                                  AppColors
                                                                      .white1,
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (mainProvider.respTaskList.isLoading) ...[
                Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
