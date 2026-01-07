import 'package:go_router/go_router.dart';
import 'screens/home_page.dart';
import 'screens/thinking_page.dart';
import 'screens/response_page.dart';
import 'screens/history_page.dart';
import 'screens/settings_page.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (_, __) =>
        const NoTransitionPage(child: HomePage()),
      ),
      GoRoute(
        path: AppRoutes.thinking,
        pageBuilder: (_, state) {
          final spokenText = state.extra as String;
          return NoTransitionPage(
            child: ThinkingPage(userText: spokenText),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.response,
        pageBuilder: (_, state) {
          final spokenText = state.extra as String;
          return NoTransitionPage(
            child: ResponsePage(text: spokenText),
          );
        },
      ),

      GoRoute(
        path: '/history',
        pageBuilder: (_, __) =>
        const NoTransitionPage(child: HistoryPage()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (_, __) =>
        const NoTransitionPage(child: SettingsPage()),
      ),


    ],
  );
}

class AppRoutes {
  static const home = '/';
  static const thinking = '/thinking';
  static const response = '/response';
}
