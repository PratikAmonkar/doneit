import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showMyDialog({
  required BuildContext context,
  required Widget child,
  bool shouldDismiss = true,
  bool useSafeArea = false,
  Widget? header,
  List<Widget>? action,
  Color containerBgColor = Colors.white,
  double containerBorderRadius = 20.0,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: shouldDismiss,
    useSafeArea: useSafeArea,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        backgroundColor: containerBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(containerBorderRadius),
          ),
        ),
        title: header,
        content: child,
        actions: action,
      );
    },
  );
}

Future<void> showCustomDialog({required BuildContext context}) async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Align(
          alignment: Alignment.center,
          child: IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.only(top: 35.0),
              width: double.infinity,
              // height: 400.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      "textToShow",
                      style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          SystemChrome.setSystemUIOverlayStyle(
                            SystemUiOverlayStyle(
                              statusBarColor: Colors.transparent,
                              statusBarIconBrightness: Brightness.light,
                              systemNavigationBarColor: Colors.transparent,
                              systemNavigationBarIconBrightness:
                                  Brightness.light,
                            ),
                          );
                          // onDismiss();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          padding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 20.0,
                          ),
                        ),
                        child: Text("cancelText"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          SystemChrome.setSystemUIOverlayStyle(
                            SystemUiOverlayStyle(
                              statusBarColor: Colors.transparent,
                              statusBarIconBrightness: Brightness.light,
                              systemNavigationBarColor: Colors.transparent,
                              systemNavigationBarIconBrightness:
                                  Brightness.light,
                            ),
                          );
                          // onSuccess();
                          // onDismiss();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Success button color
                          padding: EdgeInsets.symmetric(
                            // vertical: successBtnVerticalPadding,
                            horizontal: 20.0,
                          ),
                          textStyle: TextStyle(fontSize: 12.0),
                        ),
                        child: Text("btnText"),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  // CircleAvatar(
                  //   backgroundColor: Colors.white,
                  //   radius: 25.0,
                  //   child: Image.asset(
                  //     icon,
                  //     height: 40.0,
                  //     width: 40.0,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/*
class DialogWithTopIcon extends StatelessWidget {
  final String title;
  final String cancelText;
  final String btnText;
  final String textToShow;
  final String icon;
  final double btnFontSize;
  final double successBtnVerticalPadding;
  final Function onDismiss;
  final Function onSuccess;

  const DialogWithTopIcon({
    super.key,
    required this.title,
    this.cancelText = "No",
    this.btnText = "OK",
    required this.textToShow,
    required this.icon,
    this.btnFontSize = 18.0,
    this.successBtnVerticalPadding = 6.0,
    required this.onDismiss,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ,
    );
  }
}
*/
