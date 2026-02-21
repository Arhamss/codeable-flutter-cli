const routerExportsTemplate = '''
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:{{project_name}}/app/view/splash.dart';
import 'package:{{project_name}}/features/onboarding/presentation/views/login_screen.dart';
// TODO: Uncomment when adding shell navigation
// import 'package:{{project_name}}/features/navigation/presentation/views/app_navigation.dart';

part 'router.dart';
part 'routes.dart';
''';

const routerTemplate = '''
part of 'exports.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static BuildContext? get appContext =>
      _rootNavigatorKey.currentState?.context;

  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    observers: [ChuckerFlutter.navigatorObserver],
    routes: [
      GoRoute(
        name: AppRouteNames.splash,
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRouteNames.loginScreen,
        path: AppRoutes.loginScreen,
        builder: (context, state) => const LoginScreen(),
      ),
      // TODO: Add more routes here

      // TODO: Uncomment the StatefulShellRoute below when you are ready
      // to add bottom-tab navigation. Update the branches with your
      // actual screens and import AppNavigation in exports.dart.
      //
      // StatefulShellRoute.indexedStack(
      //   branches: <StatefulShellBranch>[
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: AppRoutes.homeScreen,
      //           name: AppRouteNames.homeScreen,
      //           builder: (context, state) => const Placeholder(), // TODO: Replace with HomeScreen()
      //         ),
      //       ],
      //     ),
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: AppRoutes.searchScreen,
      //           name: AppRouteNames.searchScreen,
      //           builder: (context, state) => const Placeholder(), // TODO: Replace with SearchScreen()
      //         ),
      //       ],
      //     ),
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: AppRoutes.profileScreen,
      //           name: AppRouteNames.profileScreen,
      //           builder: (context, state) => const Placeholder(), // TODO: Replace with ProfileScreen()
      //         ),
      //       ],
      //     ),
      //   ],
      //   builder: (context, state, shell) {
      //     return AppNavigation(shell: shell);
      //   },
      // ),
    ],
  );

  static String getCurrentLocation() {
    final lastMatch = router.routerDelegate.currentConfiguration.last;
    return lastMatch.matchedLocation;
  }

  static bool isCurrentRoute(String routeName) {
    return getCurrentLocation() == routeName;
  }
}
''';

const routesTemplate = '''
part of 'exports.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const loginScreen = '/login';
  // TODO: Uncomment when adding shell navigation
  // static const homeScreen = '/home';
  // static const searchScreen = '/search';
  // static const profileScreen = '/profile';
}

class AppRouteNames {
  AppRouteNames._();

  static const splash = 'splash';
  static const loginScreen = 'login';
  // TODO: Uncomment when adding shell navigation
  // static const homeScreen = 'home';
  // static const searchScreen = 'search';
  // static const profileScreen = 'profile';
}
''';

// ------------------------------------------------------------------
// Base router templates without onboarding — used when roles are
// specified (onboarding routes are added programmatically per role).
// ------------------------------------------------------------------

const routerExportsBaseTemplate = '''
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:{{project_name}}/app/view/splash.dart';
// TODO: Uncomment when adding shell navigation
// import 'package:{{project_name}}/features/navigation/presentation/views/app_navigation.dart';

part 'router.dart';
part 'routes.dart';
''';

const routerBaseTemplate = '''
part of 'exports.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static BuildContext? get appContext =>
      _rootNavigatorKey.currentState?.context;

  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    observers: [ChuckerFlutter.navigatorObserver],
    routes: [
      GoRoute(
        name: AppRouteNames.splash,
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // TODO: Add more routes here

      // TODO: Uncomment the StatefulShellRoute below when you are ready
      // to add bottom-tab navigation. Update the branches with your
      // actual screens and import AppNavigation in exports.dart.
      //
      // StatefulShellRoute.indexedStack(
      //   branches: <StatefulShellBranch>[
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: AppRoutes.homeScreen,
      //           name: AppRouteNames.homeScreen,
      //           builder: (context, state) => const Placeholder(), // TODO: Replace with HomeScreen()
      //         ),
      //       ],
      //     ),
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: AppRoutes.searchScreen,
      //           name: AppRouteNames.searchScreen,
      //           builder: (context, state) => const Placeholder(), // TODO: Replace with SearchScreen()
      //         ),
      //       ],
      //     ),
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: AppRoutes.profileScreen,
      //           name: AppRouteNames.profileScreen,
      //           builder: (context, state) => const Placeholder(), // TODO: Replace with ProfileScreen()
      //         ),
      //       ],
      //     ),
      //   ],
      //   builder: (context, state, shell) {
      //     return AppNavigation(shell: shell);
      //   },
      // ),
    ],
  );

  static String getCurrentLocation() {
    final lastMatch = router.routerDelegate.currentConfiguration.last;
    return lastMatch.matchedLocation;
  }

  static bool isCurrentRoute(String routeName) {
    return getCurrentLocation() == routeName;
  }
}
''';

const routesBaseTemplate = '''
part of 'exports.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  // TODO: Uncomment when adding shell navigation
  // static const homeScreen = '/home';
  // static const searchScreen = '/search';
  // static const profileScreen = '/profile';
}

class AppRouteNames {
  AppRouteNames._();

  static const splash = 'splash';
  // TODO: Uncomment when adding shell navigation
  // static const homeScreen = 'home';
  // static const searchScreen = 'search';
  // static const profileScreen = 'profile';
}
''';
