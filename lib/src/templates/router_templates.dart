const routerExportsTemplate = '''
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:{{project_name}}/app/view/splash.dart';
import 'package:{{project_name}}/config/flavor_config.dart';
import 'package:{{project_name}}/core/app_preferences/app_preferences.dart';
import 'package:{{project_name}}/core/di/injector.dart';
import 'package:{{project_name}}/features/onboarding/presentation/views/login_screen.dart';
// TODO(codeable): Uncomment when adding shell navigation
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
    observers: [
      if (FlavorConfig.isDev()) ChuckerFlutter.navigatorObserver,
    ],
    redirect: (context, state) {
      final isAuthenticated =
          Injector.resolve<AppPreferences>().isAuthenticated;

      // Routes that an unauthenticated user is allowed to view.
      // TODO(codeable): Add your own onboarding/auth routes (e.g. signup, forgot
      // password) to this list as you create them.
      const publicRoutes = <String>[
        AppRoutes.splash,
        AppRoutes.loginScreen,
      ];

      final location = state.matchedLocation;
      final isPublicRoute = publicRoutes.contains(location);

      // Not authenticated and trying to reach a protected route -> login.
      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.loginScreen;
      }

      // Authenticated user landing on splash/login has no home route wired
      // yet, so allow splash to decide (see SplashScreen._navigate).
      // TODO(codeable): Once a post-auth home route exists, redirect authenticated
      // users away from splash/login to it here.

      // No redirect needed.
      return null;
    },
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
      // TODO(codeable): Add more routes here

      // TODO(codeable): Uncomment the StatefulShellRoute below when you are ready
      // to add bottom-tab navigation. Update the branches with your
      // actual screens and import AppNavigation in exports.dart.
      // Also uncomment the matching homeScreen/searchScreen/profileScreen
      // constants in AppRoutes and AppRouteNames below — they are
      // referenced here but defined ~50 lines down in this same file.
      //
      // StatefulShellRoute.indexedStack(
      //   branches: <StatefulShellBranch>[
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: AppRoutes.homeScreen,
      //           name: AppRouteNames.homeScreen,
      //           builder: (context, state) => const Placeholder(), // TODO(codeable): Replace with HomeScreen()
      //         ),
      //       ],
      //     ),
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: AppRoutes.searchScreen,
      //           name: AppRouteNames.searchScreen,
      //           builder: (context, state) => const Placeholder(), // TODO(codeable): Replace with SearchScreen()
      //         ),
      //       ],
      //     ),
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: AppRoutes.profileScreen,
      //           name: AppRouteNames.profileScreen,
      //           builder: (context, state) => const Placeholder(), // TODO(codeable): Replace with ProfileScreen()
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
  // TODO(codeable): Uncomment when adding shell navigation
  // static const homeScreen = '/home';
  // static const searchScreen = '/search';
  // static const profileScreen = '/profile';
}

class AppRouteNames {
  AppRouteNames._();

  static const splash = 'splash';
  static const loginScreen = 'login';
  // TODO(codeable): Uncomment when adding shell navigation
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
import 'package:{{project_name}}/config/flavor_config.dart';
import 'package:{{project_name}}/core/app_preferences/app_preferences.dart';
import 'package:{{project_name}}/core/di/injector.dart';
// TODO(codeable): Uncomment when adding shell navigation
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
    observers: [
      if (FlavorConfig.isDev()) ChuckerFlutter.navigatorObserver,
    ],
    redirect: (context, state) {
      final isAuthenticated =
          Injector.resolve<AppPreferences>().isAuthenticated;

      // Routes that an unauthenticated user is allowed to view. Splash is
      // always public; it then forwards to the correct onboarding flow.
      // TODO(codeable): Add your per-role onboarding/auth route paths (the ones
      // generated for each role) to this list so unauthenticated users can
      // reach them without being bounced back to splash.
      const publicRoutes = <String>[
        AppRoutes.splash,
      ];

      final location = state.matchedLocation;
      final isPublicRoute = publicRoutes.contains(location);

      // Not authenticated and trying to reach a protected route -> send to
      // splash, which routes the user into the appropriate onboarding flow.
      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.splash;
      }

      // No redirect needed.
      return null;
    },
    routes: [
      GoRoute(
        name: AppRouteNames.splash,
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // TODO(codeable): Add more routes here

      // TODO(codeable): Uncomment the StatefulShellRoute below when you are ready
      // to add bottom-tab navigation. Update the branches with your
      // actual screens and import AppNavigation in exports.dart.
      // Also uncomment the matching homeScreen/searchScreen/profileScreen
      // constants in AppRoutes and AppRouteNames below — they are
      // referenced here but defined ~50 lines down in this same file.
      //
      // StatefulShellRoute.indexedStack(
      //   branches: <StatefulShellBranch>[
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: AppRoutes.homeScreen,
      //           name: AppRouteNames.homeScreen,
      //           builder: (context, state) => const Placeholder(), // TODO(codeable): Replace with HomeScreen()
      //         ),
      //       ],
      //     ),
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: AppRoutes.searchScreen,
      //           name: AppRouteNames.searchScreen,
      //           builder: (context, state) => const Placeholder(), // TODO(codeable): Replace with SearchScreen()
      //         ),
      //       ],
      //     ),
      //     StatefulShellBranch(
      //       routes: [
      //         GoRoute(
      //           path: AppRoutes.profileScreen,
      //           name: AppRouteNames.profileScreen,
      //           builder: (context, state) => const Placeholder(), // TODO(codeable): Replace with ProfileScreen()
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
  // TODO(codeable): Uncomment when adding shell navigation
  // static const homeScreen = '/home';
  // static const searchScreen = '/search';
  // static const profileScreen = '/profile';
}

class AppRouteNames {
  AppRouteNames._();

  static const splash = 'splash';
  // TODO(codeable): Uncomment when adding shell navigation
  // static const homeScreen = 'home';
  // static const searchScreen = 'search';
  // static const profileScreen = 'profile';
}
''';
