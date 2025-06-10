/*
void systemUiConfig({
  Color statusBarColor = Colors.white,
  Color navigationColor = Colors.white,
  Brightness statusBarIcon = Brightness.dark,
  Brightness navigationBarIcon = Brightness.dark,
}) {
  return SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarIconBrightness: statusBarIcon,
      systemNavigationBarColor: navigationColor,
      systemNavigationBarIconBrightness: navigationBarIcon,
    ),
  );
}
*/

/*
void systemUiConfig({
  bool hideStatusBar = false,
  bool hideNavigationBar = false,
  Color statusBarColor = Colors.transparent,
  Color navigationColor =
      Colors.transparent,
  Brightness statusBarIcon = Brightness.dark,
  Brightness navigationBarIcon =
      Brightness.dark,
}) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarIconBrightness: statusBarIcon,
      systemNavigationBarColor: navigationColor,
      systemNavigationBarIconBrightness: navigationBarIcon,
    ),
  );

  if (hideStatusBar) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.bottom],
    );
  } else if (hideNavigationBar) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  } else {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void systemUiConfig({
  Color statusBarColor = Colors.transparent,
  Color navigationColor = Colors.transparent,
  Brightness statusBarIcon = Brightness.dark,
  Brightness navigationBarIcon = Brightness.dark,
}) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarIconBrightness: statusBarIcon,
      systemNavigationBarColor: navigationColor,
      systemNavigationBarIconBrightness: navigationBarIcon,
    ),
  );
}
