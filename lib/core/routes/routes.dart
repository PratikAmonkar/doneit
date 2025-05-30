import 'package:DoneIt/presentation/screens/add_edit_screen.dart';
import 'package:DoneIt/presentation/screens/main_screen.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/splash_screen.dart';

final router = GoRouter(
  initialLocation: "/splash",
  routes: [
    GoRoute(path: "/splash", builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: "/main-screen",
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: "/add-edit-screen/:id/:name/:notifyId",
      builder: (context, state) {
        var id = state.pathParameters['id'];
        var name = state.pathParameters['name'];
        var notifyId = state.pathParameters['notifyId'];
        return AddEditScreen(
          id: id == "0" ? null : id,
          notificationId: notifyId == "-1" ? null : int.parse(notifyId!),
          name: name == "a" ? "" : name ?? "",
        );
      },
    ),
  ],
);
