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

    /*GoRoute(
      path: "/category-detail/:type",
      builder: (context, state) {
        final productType = state.pathParameters['type'];
        return CategoryDetailScreen(type: productType);
      },
    ),*/
  ],
);
