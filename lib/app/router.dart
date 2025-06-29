import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:trans_bridge/views/app_view.dart';
import 'package:trans_bridge/views/home_view/home_view.dart';
import 'package:trans_bridge/views/live_support_view/live_support_view.dart';
import 'package:trans_bridge/views/past_view/past_view.dart';
import 'package:trans_bridge/views/profile_view/profile_view.dart';

final _routerKey = GlobalKey<NavigatorState>();

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String past = '/past';
  static const String livesupport = '/livesupport';
  static const String profile = '/profile';
}

final router = GoRouter(
  navigatorKey: _routerKey,
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppView(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.past,
              builder: (context, state) => const PastView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.livesupport,
              builder: (context, state) => const LiveSupportView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileView(),
            ),
          ],
        ),
      ],
    ),
  ],
);
