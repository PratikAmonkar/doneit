import 'dart:async';

import 'package:DoneIt/presentation/components/Text/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/util/app_info_util.dart' show AppInfoUtil;
import '../components/System Ui/system_ui.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;
  String packageVersion = "";

  @override
  void initState() {
    super.initState();
    getPackageVersion();
    systemUiConfig(
      statusBarColor: AppColors.lightBackground,
      navigationColor: AppColors.lightBackground,
    );
    _timer = Timer(const Duration(seconds: 3), () {
      GoRouter.of(context).pushReplacement("/main-screen");
    });
  }

  void getPackageVersion() async {
    String version = await AppInfoUtil.getVersion();
    setState(() {
      packageVersion = version;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/app_logo.png",
                        width: 300.0,
                        height: 300.0,
                        // fit: BoxFit.fill,
                      ),
                    ],
                  ),
                ),
                if (packageVersion.isNotEmpty) ...[
                  textBold(title: "Version $packageVersion", fontSize: 14.0),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
