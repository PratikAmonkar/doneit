import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../presentation/components/Dialog/dialog.dart';
import '../constants/app_colors.dart';

class PermissionService {
  Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  Future<bool> shouldShowRequestRationale(Permission permission) async {
    return await permission.shouldShowRequestRationale;
  }

  Future<Map<Permission, PermissionStatus>> requestMultiplePermission(
    List<Permission> permissionList,
  ) async {
    Map<Permission, PermissionStatus> permissionStatus =
        await permissionList.request();

    return permissionStatus;
  }

  Future<bool> openAppSetting() async {
    var result = openAppSettings();
    return await result;
  }

  Future<void> relationalDialog(
    BuildContext context,
    Function successAction,
  ) async {
    return showCustomDialog(
      context: context,
      title:
          "To remind you about your tasks, we need permission to send notifications. Please grant permission.",
      systemUiColor: AppColors.lightBackground,
      onSuccessAction: () {
        successAction();
      },
      onDismissAction: () {},
    );
  }
}
