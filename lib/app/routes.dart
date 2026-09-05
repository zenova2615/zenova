import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/shell_screen.dart';
import '../features/app_clone/screens/app_clone_screen.dart';
import '../features/share/screens/share_screen.dart';
import '../features/player/screens/player_home_screen.dart';
import '../features/downloader/screens/downloader_screen.dart';
import '../features/other_tools/screens/other_tools_screen.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/player',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app-clone',
                name: 'app-clone',
                builder: (context, state) => const AppCloneScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/share',
                name: 'share',
                builder: (context, state) => const ShareScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/player',
                name: 'player',
                builder: (context, state) => const PlayerHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/downloader',
                name: 'downloader',
                builder: (context, state) => const DownloaderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tools',
                name: 'tools',
                builder: (context, state) => const OtherToolsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
