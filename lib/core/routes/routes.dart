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
      path: "/add-edit-screen/:type",
      builder: (context, state) {
        final type = state.pathParameters['type'];
        return AddEditScreen(type: type ?? "1");
      },
    ),
  ],
);
