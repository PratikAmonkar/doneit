import 'package:DoneIt/core/provider/main_screen_provider.dart';
import 'package:DoneIt/domain/task_bean.dart';
import 'package:DoneIt/presentation/components/Spacer/spacer.dart';
import 'package:DoneIt/presentation/components/Text/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/util/common_util.dart';
import '../components/System Ui/system_ui.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _showFab = true;
  bool _showAppBar = true;

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
      debugPrint("Empty state");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(mainScreenProvider.notifier).getTaskList();
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
                  GoRouter.of(context).push("/add-edit-screen/0/a");
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
              if (mainProvider.respTaskList.isSuccess) ...[
                MainScreenSuccessState(
                  mainScreenProvider: mainProvider,
                  scrollController: _scrollController,
                  showAppBar: _showAppBar,
                ),
              ],
              if (mainProvider.respTaskList.isLoading) ...[
                Center(child: CircularProgressIndicator()),
              ],

              if (mainProvider.respTaskList.isError) ...[
                textBold(title: "Error found"),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreenSuccessState extends ConsumerStatefulWidget {
  final MainScreenProvider mainScreenProvider;
  final bool showAppBar;
  final ScrollController scrollController;

  const MainScreenSuccessState({
    super.key,
    required this.mainScreenProvider,
    required this.showAppBar,
    required this.scrollController,
  });

  @override
  ConsumerState<MainScreenSuccessState> createState() =>
      _MainScreenSuccessStateState();
}

class _MainScreenSuccessStateState
    extends ConsumerState<MainScreenSuccessState> {
  @override
  Widget build(BuildContext context) {
    final List<TaskBean> taskList =
        widget.mainScreenProvider.respTaskList.data ?? List.empty();
    return Column(
      children: [
        AnimatedContainer(
          height: widget.showAppBar ? 56.0 : 0.0,
          duration: Duration(milliseconds: 500),
          child: AnimatedOpacity(
            opacity: widget.showAppBar ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: AppBar(
              backgroundColor: AppColors.lightBackground,
              surfaceTintColor: AppColors.lightBackground,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textBold(title: "Hey Buddy!", fontSize: 22.0),
                  textBold(title: CommonUtil().greetUser(), fontSize: 14.0),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child:
                taskList.isEmpty
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/empty_data.png",
                          width: 100.0,
                          height: 100.0,
                        ),
                        verticalSpacer(),
                        textBold(title: "No task available", fontSize: 14.0),
                      ],
                    )
                    : SingleChildScrollView(
                      controller: widget.scrollController,
                      child: Column(
                        children: [
                          /*
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  textBold(
                                    title: "Sort by : All",
                                    fontSize: 14.0,
                                  ),
                                  PopupMenuButton(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: 20.0,
                                    ),
                                    onSelected: (value) {},
                                    itemBuilder:
                                        (BuildContext context) => [
                                          PopupMenuItem(
                                            value: 'option1',
                                            child: textBold(
                                              title: 'Option 1',
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  textBold(
                                    title: "Priority by : All",
                                    fontSize: 14.0,
                                  ),
                                  PopupMenuButton(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: 20.0,
                                    ),
                                    onSelected: (value) {},
                                    itemBuilder:
                                        (BuildContext context) => [
                                          PopupMenuItem(
                                            value: 'option1',
                                            child: textBold(
                                              title: 'Option 1',
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                  ),
                                ],
                              ),
                            ],
                          ),
*/
                          verticalSpacer(value: 10.0),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: taskList.length,
                            itemBuilder: (BuildContext context, int index) {
                              final TaskBean taskBean = taskList[index];

                              return GestureDetector(
                                onTap: () {
                                  GoRouter.of(context).push(
                                    "/add-edit-screen/${taskBean.id}/${taskBean.title}",
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20.0),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: AppColors.lightPurple100,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      textBold(
                                        title: taskBean.title,
                                        fontSize: 18.0,
                                      ),
                                      /*      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          textBold(
                                            title:
                                                "Completed ${taskBean.todosDoneCount} out of ${taskBean.totalTodosCount}",
                                            fontSize: 10.0,
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 5.0,
                                              horizontal: 10.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.lightRed100,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: textBold(
                                              title: taskBean.priority ?? "Low",
                                              fontSize: 10.0,
                                              fontColor:
                                                  AppColors.lightBackground,
                                            ),
                                          ),
                                        ],
                                      ),*/
                                      textBold(
                                        title:
                                            "Completed ${taskBean.todosDoneCount} out of ${taskBean.totalTodosCount}",
                                        fontSize: 10.0,
                                      ),
                                      textMedium(
                                        title:
                                            "${taskBean.updated != null ? "Last updated :" : "created :"} ${taskBean.updated != null ? CommonUtil().getDate(option: 1, value: taskBean.updated ?? "") : CommonUtil().getDate(option: 1, value: taskBean.created)}",
                                        fontSize: 10.0,
                                        fontColor: Colors.grey.shade900,
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
    );
  }
}
