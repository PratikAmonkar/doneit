import 'package:DoneIt/presentation/components/Spacer/spacer.dart';
import 'package:DoneIt/presentation/components/Text/text.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../components/System Ui/system_ui.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
    return WillPopScope(
      onWillPop: () async {
        systemUiConfig();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: AppColors.lightBackground,
          surfaceTintColor: AppColors.lightBackground,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textBold(title: "Hey Buddy!", fontSize: 20.0),
              textMedium(title: "Good Morning", fontSize: 14.0),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 32.0), // adjust this
          child: FloatingActionButton(
            backgroundColor: AppColors.lightPurple200,
            onPressed: () {},
            child: const Icon(
              Icons.add,
              color: AppColors.lightBackground,
              size: 30.0,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
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
                                  PopupMenuItem(
                                    value: 'option1',
                                    child: textBold(
                                      title: 'Option 1',
                                      fontSize: 12.0,
                                    ),
                                  ),
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
                          textBold(title: "Priority by : All", fontSize: 14.0),
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
                                  PopupMenuItem(
                                    value: 'option1',
                                    child: textBold(
                                      title: 'Option 1',
                                      fontSize: 12.0,
                                    ),
                                  ),
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 10,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: AppColors.lightPurple100,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textBold(title: "First task title", fontSize: 18.0),
                            textBold(
                              title: "First task description",
                              fontSize: 14.0,
                              fontColor: AppColors.lightGrey100,
                            ),
                            textBold(title: "Low", fontSize: 10.0),
                            textBold(title: "Completed", fontSize: 10.0),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
