import 'package:DoneIt/presentation/components/Text/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../components/System Ui/system_ui.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
                  GoRouter.of(context).push("/add-edit-screen/1");
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
          child: Column(
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
                        textBold(title: "Good morning", fontSize: 14.0),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              textBold(title: "Sort by : All", fontSize: 14.0),
                              PopupMenuButton(
                                icon: const Icon(Icons.more_vert, size: 20.0),
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
                                icon: const Icon(Icons.more_vert, size: 20.0),
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
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 10,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              GoRouter.of(context).push("/add-edit-screen/2");
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: AppColors.lightPurple100,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  textBold(
                                    title: "First task title",
                                    fontSize: 18.0,
                                  ),
                                  textBold(
                                    title: "First task description",
                                    fontSize: 14.0,
                                    fontColor: AppColors.lightGrey100,
                                  ),
                                  textBold(title: "Low", fontSize: 10.0),
                                  textBold(title: "Completed", fontSize: 10.0),
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
            ],
          ),
        ),
      ),
    );
  }
}
