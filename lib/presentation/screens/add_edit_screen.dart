import 'package:DoneIt/presentation/components/CheckBox/checkbox.dart';
import 'package:DoneIt/presentation/components/Spacer/spacer.dart';
import 'package:DoneIt/presentation/components/TextField/textField.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../components/System Ui/system_ui.dart';
import '../components/Text/text.dart';

class AddEditScreen extends StatefulWidget {
  final String type;

  const AddEditScreen({super.key, required this.type});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  bool editTaskName = true;
  bool editTodoName = false;

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
            title: widget.type == "1" ? "Add Task" : "Edit Task",
            fontSize: 18.0,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  editTaskName
                      ? textField(
                        controller: taskNameController,
                        backgroundColor: Colors.grey.shade200,
                        fontSize: 16.0,
                        hintText: "Enter task name",
                        imeActionType: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        fontColor: AppColors.fontColor1,
                        maxLines: 3,
                      )
                      : textBold(
                        title: "Add Task name",
                        maxLine: 2,
                        fontSize: 20.0,
                      ),
                  verticalSpacer(),
                  textMedium(
                    title: "Completed 0 out of 10 todos",
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
                    ),
                  ],

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 20,
                    itemBuilder: (BuildContext context, int index) {
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      checkBox(
                                        isChecked: true,
                                        borderColor: AppColors.lightPurple200,
                                        onTapAction: () {},
                                        activeColor: AppColors.lightPurple200,
                                      ),
                                      horizontalSpacer(value: 20.0),
                                      Expanded(
                                        child: textBold(
                                          title: "First Todo",
                                          fontSize: 18.0,
                                          maxLine: 2,
                                        ),
                                      ),
                                      horizontalSpacer(value: 20.0),
                                    ],
                                  ),
                                  textMedium(
                                    title: "created: 20 Apr 25 , 05:26 PM",
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
